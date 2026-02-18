import db from '../config/database';
import { NotFoundError } from '../utils/errors';
import { CROWN_CONTEST_THRESHOLD } from '../utils/constants';

export class CrownsService {
  async checkAndTransfer(
    itemId: string,
    regionId: string,
    cycleId: string,
    userId: string,
    submissionId: string,
    price: number
  ) {
    return db.transaction(async (trx) => {
      // Lock the row if it exists (SELECT FOR UPDATE)
      const existingCrown = await trx('crowns')
        .where({ item_id: itemId, region_id: regionId, cycle_id: cycleId })
        .forUpdate()
        .first();

      if (!existingCrown) {
        // Create new crown
        const [crown] = await trx('crowns')
          .insert({
            item_id: itemId,
            region_id: regionId,
            cycle_id: cycleId,
            holder_id: userId,
            submission_id: submissionId,
            lowest_price: price,
            status: 'active',
          })
          .returning('*');

        // Log the initial claim
        await trx('crown_transfers').insert({
          crown_id: crown.id,
          from_user_id: null,
          to_user_id: userId,
          price,
        });

        return { crown, transferred: true, isNew: true };
      }

      const currentPrice = parseFloat(existingCrown.lowest_price);

      // If new price is lower, transfer the crown
      if (price < currentPrice) {
        const previousHolder = existingCrown.holder_id;

        await trx('crowns')
          .where({ id: existingCrown.id })
          .update({
            holder_id: userId,
            submission_id: submissionId,
            lowest_price: price,
            status: 'active',
            claimed_at: trx.fn.now(),
          });

        await trx('crown_transfers').insert({
          crown_id: existingCrown.id,
          from_user_id: previousHolder,
          to_user_id: userId,
          price,
        });

        return { crown: { ...existingCrown, holder_id: userId, lowest_price: price }, transferred: true, isNew: false };
      }

      // If within contest threshold, mark as contested
      if (Math.abs(price - currentPrice) <= CROWN_CONTEST_THRESHOLD) {
        await trx('crowns')
          .where({ id: existingCrown.id })
          .update({ status: 'contested' });

        return { crown: { ...existingCrown, status: 'contested' }, transferred: false, contested: true };
      }

      // Price not low enough — no change
      return { crown: existingCrown, transferred: false, contested: false };
    });
  }

  async getCrowns(regionId: string, cycleId?: string) {
    const query = db('crowns')
      .join('items', 'crowns.item_id', 'items.id')
      .join('users', 'crowns.holder_id', 'users.id')
      .join('submissions', 'crowns.submission_id', 'submissions.id')
      .where({ 'crowns.region_id': regionId })
      .select(
        'crowns.id',
        'crowns.item_id',
        'items.name as item_name',
        'crowns.holder_id',
        'users.username as holder_username',
        'crowns.lowest_price',
        'crowns.status',
        'crowns.claimed_at',
        'crowns.cycle_id',
        'submissions.store_id'
      );

    if (cycleId) {
      query.where({ 'crowns.cycle_id': cycleId });
    }

    return query;
  }

  async getUserCrowns(userId: string) {
    return db('crowns')
      .join('items', 'crowns.item_id', 'items.id')
      .join('regions', 'crowns.region_id', 'regions.id')
      .where({ holder_id: userId })
      .select(
        'crowns.id',
        'crowns.item_id',
        'items.name as item_name',
        'crowns.region_id',
        'regions.name as region_name',
        'crowns.lowest_price',
        'crowns.status',
        'crowns.claimed_at',
        'crowns.cycle_id'
      );
  }

  async getHistory(crownId: string) {
    const crown = await db('crowns').where({ id: crownId }).first();
    if (!crown) {
      throw new NotFoundError('Crown');
    }

    const transfers = await db('crown_transfers')
      .where({ crown_id: crownId })
      .leftJoin('users as from_user', 'crown_transfers.from_user_id', 'from_user.id')
      .join('users as to_user', 'crown_transfers.to_user_id', 'to_user.id')
      .select(
        'crown_transfers.id',
        'crown_transfers.from_user_id',
        'from_user.username as from_username',
        'crown_transfers.to_user_id',
        'to_user.username as to_username',
        'crown_transfers.price',
        'crown_transfers.transferred_at'
      )
      .orderBy('crown_transfers.transferred_at', 'asc');

    return { crown, transfers };
  }
}
