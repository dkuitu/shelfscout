import db from '../config/database';

export class LeaderboardsService {
  async getRegional(regionId: string, limit = 20) {
    // Rank by: active crowns held in this region, then total verified submissions
    return db('users')
      .leftJoin(
        db('crowns')
          .where({ 'crowns.region_id': regionId, status: 'active' })
          .groupBy('holder_id')
          .select('holder_id', db.raw('COUNT(*) as crown_count'))
          .as('c'),
        'users.id',
        'c.holder_id'
      )
      .leftJoin(
        db('submissions')
          .where({ status: 'verified' })
          .groupBy('user_id')
          .select('user_id', db.raw('COUNT(*) as submission_count'))
          .as('s'),
        'users.id',
        's.user_id'
      )
      .where({ 'users.region_id': regionId })
      .select(
        'users.id',
        'users.username',
        'users.trust_score',
        db.raw('COALESCE(c.crown_count, 0)::int as crown_count'),
        db.raw('COALESCE(s.submission_count, 0)::int as submission_count')
      )
      .orderBy('crown_count', 'desc')
      .orderBy('submission_count', 'desc')
      .limit(limit);
  }

  async getNational(limit = 50) {
    // Rank by total active crowns across all regions
    return db('users')
      .leftJoin(
        db('crowns')
          .where({ status: 'active' })
          .groupBy('holder_id')
          .select('holder_id', db.raw('COUNT(*) as crown_count'))
          .as('c'),
        'users.id',
        'c.holder_id'
      )
      .leftJoin(
        db('submissions')
          .where({ status: 'verified' })
          .groupBy('user_id')
          .select('user_id', db.raw('COUNT(*) as submission_count'))
          .as('s'),
        'users.id',
        's.user_id'
      )
      .select(
        'users.id',
        'users.username',
        'users.trust_score',
        db.raw('COALESCE(c.crown_count, 0)::int as crown_count'),
        db.raw('COALESCE(s.submission_count, 0)::int as submission_count')
      )
      .orderBy('crown_count', 'desc')
      .orderBy('submission_count', 'desc')
      .limit(limit);
  }

  async getWeekly(limit = 20) {
    // Rank by verified submissions in the current active cycle
    const activeCycle = await db('weekly_cycles').where({ active: true }).first();
    if (!activeCycle) {
      return [];
    }

    return db('users')
      .join('submissions', 'users.id', 'submissions.user_id')
      .where({ 'submissions.cycle_id': activeCycle.id, 'submissions.status': 'verified' })
      .groupBy('users.id', 'users.username')
      .select(
        'users.id',
        'users.username',
        db.raw('COUNT(submissions.id)::int as verified_submissions'),
        db.raw('MIN(submissions.price)::numeric as best_price')
      )
      .orderBy('verified_submissions', 'desc')
      .limit(limit);
  }
}
