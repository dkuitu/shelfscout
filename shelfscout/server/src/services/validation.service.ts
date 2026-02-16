import db from '../config/database';
import { ValidationError, NotFoundError } from '../utils/errors';
import { VALIDATION_THRESHOLD } from '../utils/constants';
import { CrownsService } from './crowns.service';
import { SubmissionsService } from './submissions.service';

const crownsService = new CrownsService();
const submissionsService = new SubmissionsService();

export class ValidationService {
  async getQueue(userId: string, limit = 5) {
    // Random pending submissions, excluding user's own and already voted on
    const submissions = await db('submissions')
      .where({ status: 'pending' })
      .whereNot({ user_id: userId })
      .whereNotIn(
        'submissions.id',
        db('validations').where({ validator_id: userId }).select('submission_id')
      )
      .select(
        'submissions.*',
      )
      .orderByRaw('RANDOM()')
      .limit(limit);

    return submissions;
  }

  async submitVote(
    submissionId: string,
    validatorId: string,
    vote: 'confirm' | 'flag',
    reason?: string
  ) {
    const submission = await db('submissions').where({ id: submissionId }).first();
    if (!submission) {
      throw new NotFoundError('Submission');
    }

    if (submission.status !== 'pending') {
      throw new ValidationError('Submission is no longer pending');
    }

    if (submission.user_id === validatorId) {
      throw new ValidationError('Cannot validate your own submission');
    }

    // Check for duplicate vote
    const existing = await db('validations')
      .where({ submission_id: submissionId, validator_id: validatorId })
      .first();
    if (existing) {
      throw new ValidationError('You have already voted on this submission');
    }

    const [validation] = await db('validations')
      .insert({
        submission_id: submissionId,
        validator_id: validatorId,
        vote,
        reason: reason ?? null,
      })
      .returning('*');

    const consensus = await this.checkConsensus(submissionId);

    return { validation, ...consensus };
  }

  async checkConsensus(submissionId: string) {
    const votes = await db('validations')
      .where({ submission_id: submissionId })
      .select('vote');

    const confirms = votes.filter((v) => v.vote === 'confirm').length;
    const flags = votes.filter((v) => v.vote === 'flag').length;

    if (confirms >= VALIDATION_THRESHOLD) {
      await submissionsService.updateStatus(submissionId, 'verified');

      // Trigger crown check
      const submission = await db('submissions').where({ id: submissionId }).first();
      if (submission) {
        const store = await db('stores').where({ id: submission.store_id }).first();
        if (store?.region_id) {
          await crownsService.checkAndTransfer(
            submission.item_id,
            store.region_id,
            submission.cycle_id,
            submission.user_id,
            submissionId,
            parseFloat(submission.price)
          );
        }
      }

      return { consensusReached: true, result: 'verified' };
    }

    if (flags >= VALIDATION_THRESHOLD) {
      await submissionsService.updateStatus(submissionId, 'rejected');
      return { consensusReached: true, result: 'rejected' };
    }

    return { consensusReached: false, result: 'pending' };
  }

  async getStats(userId: string) {
    const total = await db('validations')
      .where({ validator_id: userId })
      .count('id as count')
      .first();

    const confirms = await db('validations')
      .where({ validator_id: userId, vote: 'confirm' })
      .count('id as count')
      .first();

    const flags = await db('validations')
      .where({ validator_id: userId, vote: 'flag' })
      .count('id as count')
      .first();

    return {
      total: parseInt(total?.count as string) || 0,
      confirms: parseInt(confirms?.count as string) || 0,
      flags: parseInt(flags?.count as string) || 0,
    };
  }
}
