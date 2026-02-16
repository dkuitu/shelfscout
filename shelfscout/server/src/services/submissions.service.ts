import db from '../config/database';
import { ValidationError, NotFoundError } from '../utils/errors';
import { STORE_PROXIMITY_RADIUS } from '../utils/constants';
import { BadgesService } from './badges.service';

const badgesService = new BadgesService();

export class SubmissionsService {
  async create(
    userId: string,
    storeId: string,
    itemId: string,
    price: number,
    photoUrl: string,
    gpsLat: number,
    gpsLng: number
  ) {
    // Verify active cycle exists
    const cycle = await db('weekly_cycles').where({ active: true }).first();
    if (!cycle) {
      throw new ValidationError('No active weekly cycle');
    }

    // Verify item is in this cycle's rotation
    const weeklyItem = await db('weekly_items')
      .where({ cycle_id: cycle.id, item_id: itemId })
      .first();
    if (!weeklyItem) {
      throw new ValidationError('Item is not in this week\'s rotation');
    }

    // Verify GPS proximity to store (within 150m)
    const store = await db('stores')
      .where({ id: storeId })
      .whereRaw(
        `ST_Distance(location, ST_GeogFromText('SRID=4326;POINT(${gpsLng} ${gpsLat})')) <= ?`,
        [STORE_PROXIMITY_RADIUS]
      )
      .first();

    if (!store) {
      throw new ValidationError(
        `You must be within ${STORE_PROXIMITY_RADIUS}m of the store to submit a price`
      );
    }

    const [submission] = await db('submissions')
      .insert({
        user_id: userId,
        store_id: storeId,
        item_id: itemId,
        cycle_id: cycle.id,
        price,
        photo_url: photoUrl,
        gps_lat: gpsLat,
        gps_lng: gpsLng,
        status: 'pending',
      })
      .returning('*');

    // Check for First Submission badge
    const badgesAwarded = await badgesService.checkAndAward(userId);

    return { ...submission, badgesAwarded };
  }

  async getById(id: string) {
    const submission = await db('submissions').where({ id }).first();
    if (!submission) {
      throw new NotFoundError('Submission');
    }
    return submission;
  }

  async getByStore(storeId: string) {
    return db('submissions')
      .where({ store_id: storeId })
      .orderBy('submitted_at', 'desc');
  }

  async getByUser(userId: string) {
    return db('submissions')
      .where({ user_id: userId })
      .orderBy('submitted_at', 'desc');
  }

  async updateStatus(id: string, status: 'pending' | 'verified' | 'rejected') {
    const updates: Record<string, unknown> = { status };
    if (status === 'verified') {
      updates.verified_at = db.fn.now();
    }

    const [submission] = await db('submissions')
      .where({ id })
      .update(updates)
      .returning('*');

    if (!submission) {
      throw new NotFoundError('Submission');
    }

    return submission;
  }
}
