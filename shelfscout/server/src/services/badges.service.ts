import db from '../config/database';

export class BadgesService {
  async checkAndAward(userId: string) {
    const awarded: string[] = [];

    // Get all badges user doesn't have yet
    const unearned = await db('badges')
      .whereNotIn(
        'badges.id',
        db('user_badges').where({ user_id: userId }).select('badge_id')
      )
      .select('id', 'name', 'criteria');

    if (unearned.length === 0) return awarded;

    // Gather user stats in parallel
    const [submissionCount, crownCount, accurateValidations, weeklyDefenses] =
      await Promise.all([
        db('submissions')
          .where({ user_id: userId })
          .count('id as count')
          .first()
          .then((r) => parseInt(r?.count as string) || 0),
        db('crowns')
          .where({ holder_id: userId, status: 'active' })
          .count('id as count')
          .first()
          .then((r) => parseInt(r?.count as string) || 0),
        this.getAccurateValidationCount(userId),
        this.getWeeklyCrownDefenses(userId),
      ]);

    const crownsEarned = await db('crown_transfers')
      .where({ to_user_id: userId })
      .count('id as count')
      .first()
      .then((r) => parseInt(r?.count as string) || 0);

    for (const badge of unearned) {
      let earned = false;

      switch (badge.criteria) {
        case 'submissions_count >= 1':
          earned = submissionCount >= 1;
          break;
        case 'crowns_earned >= 1':
          earned = crownsEarned >= 1;
          break;
        case 'accurate_validations >= 50':
          earned = accurateValidations >= 50;
          break;
        case 'crown_defenses_weekly >= 5':
          earned = weeklyDefenses >= 5;
          break;
        case 'active_crowns >= 10':
          earned = crownCount >= 10;
          break;
      }

      if (earned) {
        await db('user_badges')
          .insert({ user_id: userId, badge_id: badge.id })
          .onConflict(['user_id', 'badge_id'])
          .ignore();
        awarded.push(badge.name);
      }
    }

    return awarded;
  }

  private async getAccurateValidationCount(userId: string): Promise<number> {
    // A validation is "accurate" if the validator's vote matched the final outcome
    const result = await db('validations')
      .join('submissions', 'validations.submission_id', 'submissions.id')
      .where({ 'validations.validator_id': userId })
      .whereIn('submissions.status', ['verified', 'rejected'])
      .whereRaw(`(
        (validations.vote = 'confirm' AND submissions.status = 'verified') OR
        (validations.vote = 'flag' AND submissions.status = 'rejected')
      )`)
      .count('validations.id as count')
      .first();

    return parseInt(result?.count as string) || 0;
  }

  private async getWeeklyCrownDefenses(userId: string): Promise<number> {
    // Count submissions in the current active cycle where user held the crown
    // and someone tried to beat them but failed (crown still held by user)
    const activeCycle = await db('weekly_cycles').where({ active: true }).first();
    if (!activeCycle) return 0;

    // Count crown_transfers where from_user_id is NOT this user (they didn't lose it)
    // but there were attempts (submissions for the same item/region) by others
    const result = await db('crowns')
      .where({ 'crowns.holder_id': userId, 'crowns.cycle_id': activeCycle.id })
      .join('submissions', function () {
        this.on('submissions.item_id', '=', 'crowns.item_id')
          .andOn('submissions.cycle_id', '=', 'crowns.cycle_id')
          .andOnVal('submissions.status', '=', 'verified');
      })
      .join('stores', 'submissions.store_id', 'stores.id')
      .whereRaw('stores.region_id = crowns.region_id')
      .whereNot({ 'submissions.user_id': userId })
      .where('submissions.price', '>=', db.raw('crowns.lowest_price'))
      .count('submissions.id as count')
      .first();

    return parseInt(result?.count as string) || 0;
  }
}
