import db from '../config/database';

export class TrustService {
  /**
   * Recalculate and persist a user's trust score.
   *
   * Formula (0.00 – 2.00):
   *   base 1.0
   *   + submission accuracy bonus (up to +0.5)
   *   + validation accuracy bonus (up to +0.3)
   *   - flags received penalty  (up to -0.8)
   *
   * Clamped to [0.10, 2.00] — never fully zero to allow recovery.
   */
  async recalculate(userId: string): Promise<number> {
    const [submissionStats, validationAccuracy, flagsReceived] = await Promise.all([
      this.getSubmissionAccuracy(userId),
      this.getValidationAccuracy(userId),
      this.getFlagsReceived(userId),
    ]);

    let score = 1.0;

    // Submission accuracy: verified / total (only count resolved)
    if (submissionStats.resolved > 0) {
      const ratio = submissionStats.verified / submissionStats.resolved;
      score += ratio * 0.5; // max +0.5
    }

    // Validation accuracy: votes that matched final outcome / total resolved votes
    if (validationAccuracy.resolved > 0) {
      const ratio = validationAccuracy.accurate / validationAccuracy.resolved;
      score += ratio * 0.3; // max +0.3
    }

    // Flags received penalty: each flag on your submissions costs -0.08, max -0.8
    const flagPenalty = Math.min(flagsReceived * 0.08, 0.8);
    score -= flagPenalty;

    // Clamp
    score = Math.max(0.10, Math.min(2.00, score));
    score = Math.round(score * 100) / 100;

    await db('users').where({ id: userId }).update({ trust_score: score });

    return score;
  }

  private async getSubmissionAccuracy(userId: string) {
    const result = await db('submissions')
      .where({ user_id: userId })
      .whereIn('status', ['verified', 'rejected'])
      .select(
        db.raw('COUNT(*)::int as resolved'),
        db.raw("COUNT(*) FILTER (WHERE status = 'verified')::int as verified")
      )
      .first();

    return {
      resolved: result?.resolved || 0,
      verified: result?.verified || 0,
    };
  }

  private async getValidationAccuracy(userId: string) {
    const result = await db('validations')
      .join('submissions', 'validations.submission_id', 'submissions.id')
      .where({ 'validations.validator_id': userId })
      .whereIn('submissions.status', ['verified', 'rejected'])
      .select(
        db.raw('COUNT(*)::int as resolved'),
        db.raw(`COUNT(*) FILTER (WHERE
          (validations.vote = 'confirm' AND submissions.status = 'verified') OR
          (validations.vote = 'flag' AND submissions.status = 'rejected')
        )::int as accurate`)
      )
      .first();

    return {
      resolved: result?.resolved || 0,
      accurate: result?.accurate || 0,
    };
  }

  private async getFlagsReceived(userId: string): Promise<number> {
    const result = await db('validations')
      .join('submissions', 'validations.submission_id', 'submissions.id')
      .where({ 'submissions.user_id': userId, 'validations.vote': 'flag' })
      .count('validations.id as count')
      .first();

    return parseInt(result?.count as string) || 0;
  }
}
