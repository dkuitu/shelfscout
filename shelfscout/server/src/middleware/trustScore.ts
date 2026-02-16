import { Response, NextFunction } from 'express';
import db from '../config/database';
import { AuthenticatedRequest } from '../types';

export async function attachTrustScore(req: AuthenticatedRequest, _res: Response, next: NextFunction) {
  if (req.userId) {
    try {
      const user = await db('users')
        .where({ id: req.userId })
        .select('trust_score')
        .first();
      req.trustScore = user ? parseFloat(user.trust_score) : 1.0;
    } catch {
      req.trustScore = 1.0;
    }
  }
  next();
}
