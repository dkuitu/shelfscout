import db from '../config/database';
import { ValidationError, NotFoundError } from '../utils/errors';
import { ITEM_APPROVAL_THRESHOLD } from '../utils/constants';

export class ItemsService {
  async getWeeklyItems() {
    const cycle = await db('weekly_cycles').where({ active: true }).first();
    if (!cycle) {
      return [];
    }

    return db('weekly_items')
      .join('items', 'weekly_items.item_id', 'items.id')
      .leftJoin('categories', 'items.category_id', 'categories.id')
      .where({ 'weekly_items.cycle_id': cycle.id })
      .select(
        'items.id',
        'items.name',
        'items.unit',
        'items.status',
        'categories.id as category_id',
        'categories.name as category_name',
        'categories.icon as category_icon',
        'categories.color as category_color'
      );
  }

  async search(query?: string, categoryId?: string) {
    const qb = db('items')
      .leftJoin('categories', 'items.category_id', 'categories.id')
      .where({ 'items.status': 'active' })
      .select(
        'items.id',
        'items.name',
        'items.unit',
        'items.status',
        'categories.id as category_id',
        'categories.name as category_name',
        'categories.icon as category_icon',
        'categories.color as category_color'
      )
      .orderBy('items.name', 'asc')
      .limit(50);

    if (query && query.trim().length > 0) {
      qb.whereRaw('items.name ILIKE ?', [`%${query.trim()}%`]);
    }

    if (categoryId) {
      qb.where({ 'items.category_id': categoryId });
    }

    return qb;
  }

  async create(name: string, categoryId: string, unit: string, userId: string) {
    // Check for duplicate name (case-insensitive)
    const existing = await db('items')
      .whereRaw('LOWER(name) = LOWER(?)', [name])
      .first();
    if (existing) {
      throw new ValidationError('An item with this name already exists');
    }

    // Verify category exists
    const category = await db('categories').where({ id: categoryId }).first();
    if (!category) {
      throw new NotFoundError('Category');
    }

    const [item] = await db('items')
      .insert({
        name,
        category_id: categoryId,
        unit,
        status: 'pending',
        created_by: userId,
      })
      .returning('*');

    return item;
  }

  async vote(itemId: string, userId: string, vote: 'approve' | 'reject') {
    const item = await db('items').where({ id: itemId }).first();
    if (!item) {
      throw new NotFoundError('Item');
    }

    if (item.status !== 'pending') {
      throw new ValidationError('Item is not pending approval');
    }

    if (item.created_by === userId) {
      throw new ValidationError('Cannot vote on your own item');
    }

    // Check for duplicate vote
    const existing = await db('item_votes')
      .where({ item_id: itemId, user_id: userId })
      .first();
    if (existing) {
      throw new ValidationError('You have already voted on this item');
    }

    const [itemVote] = await db('item_votes')
      .insert({ item_id: itemId, user_id: userId, vote })
      .returning('*');

    // Check consensus
    const votes = await db('item_votes')
      .where({ item_id: itemId })
      .select('vote');

    const approvals = votes.filter((v) => v.vote === 'approve').length;
    const rejections = votes.filter((v) => v.vote === 'reject').length;

    let newStatus: string | null = null;

    if (approvals >= ITEM_APPROVAL_THRESHOLD) {
      await db('items').where({ id: itemId }).update({ status: 'active' });
      newStatus = 'active';
    } else if (rejections >= ITEM_APPROVAL_THRESHOLD) {
      await db('items').where({ id: itemId }).update({ status: 'rejected' });
      newStatus = 'rejected';
    }

    return { vote: itemVote, newStatus };
  }

  async getPendingItems(userId: string) {
    return db('items')
      .leftJoin('categories', 'items.category_id', 'categories.id')
      .where({ 'items.status': 'pending' })
      .whereNot({ 'items.created_by': userId })
      .whereNotIn(
        'items.id',
        db('item_votes').where({ user_id: userId }).select('item_id')
      )
      .select(
        'items.id',
        'items.name',
        'items.unit',
        'items.status',
        'items.created_by',
        'categories.id as category_id',
        'categories.name as category_name',
        'categories.icon as category_icon',
        'categories.color as category_color'
      )
      .orderBy('items.created_at', 'desc');
  }

  async getById(id: string) {
    const item = await db('items')
      .leftJoin('categories', 'items.category_id', 'categories.id')
      .where({ 'items.id': id })
      .select(
        'items.id',
        'items.name',
        'items.unit',
        'items.status',
        'items.created_by',
        'categories.id as category_id',
        'categories.name as category_name',
        'categories.icon as category_icon',
        'categories.color as category_color'
      )
      .first();

    if (!item) {
      throw new NotFoundError('Item');
    }

    return item;
  }
}
