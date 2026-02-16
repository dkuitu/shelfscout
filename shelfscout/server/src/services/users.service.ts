import db from '../config/database';
import { NotFoundError, ValidationError } from '../utils/errors';

export class UsersService {
  async getProfile(userId: string) {
    const user = await db('users')
      .leftJoin('regions', 'users.region_id', 'regions.id')
      .where({ 'users.id': userId })
      .select(
        'users.id',
        'users.email',
        'users.username',
        'users.trust_score',
        'users.region_id',
        'regions.name as region_name',
        'users.created_at'
      )
      .first();

    if (!user) {
      throw new NotFoundError('User');
    }

    return user;
  }

  async updateProfile(userId: string, updates: { username?: string }) {
    if (updates.username) {
      const existing = await db('users')
        .where({ username: updates.username })
        .whereNot({ id: userId })
        .first();
      if (existing) {
        throw new ValidationError('Username already taken');
      }
    }

    const [user] = await db('users')
      .where({ id: userId })
      .update({ ...updates, updated_at: db.fn.now() })
      .returning(['id', 'email', 'username', 'trust_score', 'region_id', 'created_at']);

    if (!user) {
      throw new NotFoundError('User');
    }

    return user;
  }

  async getBadges(userId: string) {
    return db('user_badges')
      .join('badges', 'user_badges.badge_id', 'badges.id')
      .where({ 'user_badges.user_id': userId })
      .select(
        'badges.id',
        'badges.name',
        'badges.description',
        'badges.rarity',
        'badges.icon_url',
        'user_badges.earned_at'
      )
      .orderBy('user_badges.earned_at', 'desc');
  }

  async getStats(userId: string) {
    const [crowns, submissions, validations, badges] = await Promise.all([
      db('crowns')
        .where({ holder_id: userId })
        .count('id as count')
        .first(),
      db('submissions')
        .where({ user_id: userId })
        .select(
          db.raw("COUNT(*) as total"),
          db.raw("COUNT(*) FILTER (WHERE status = 'verified') as verified"),
          db.raw("COUNT(*) FILTER (WHERE status = 'rejected') as rejected"),
          db.raw("COUNT(*) FILTER (WHERE status = 'pending') as pending")
        )
        .first(),
      db('validations')
        .where({ validator_id: userId })
        .select(
          db.raw("COUNT(*) as total"),
          db.raw("COUNT(*) FILTER (WHERE vote = 'confirm') as confirms"),
          db.raw("COUNT(*) FILTER (WHERE vote = 'flag') as flags")
        )
        .first(),
      db('user_badges')
        .where({ user_id: userId })
        .count('id as count')
        .first(),
    ]);

    return {
      active_crowns: parseInt(crowns?.count as string) || 0,
      submissions: {
        total: parseInt(submissions?.total as string) || 0,
        verified: parseInt(submissions?.verified as string) || 0,
        rejected: parseInt(submissions?.rejected as string) || 0,
        pending: parseInt(submissions?.pending as string) || 0,
      },
      validations: {
        total: parseInt(validations?.total as string) || 0,
        confirms: parseInt(validations?.confirms as string) || 0,
        flags: parseInt(validations?.flags as string) || 0,
      },
      badges_earned: parseInt(badges?.count as string) || 0,
    };
  }
}
