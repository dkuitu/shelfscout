import db from '../config/database';

export class ItemsService {
  async getWeeklyItems() {
    const cycle = await db('weekly_cycles').where({ active: true }).first();
    if (!cycle) {
      return [];
    }

    return db('weekly_items')
      .join('items', 'weekly_items.item_id', 'items.id')
      .where({ 'weekly_items.cycle_id': cycle.id })
      .select(
        'items.id',
        'items.name',
        'items.category',
        'items.unit'
      );
  }
}
