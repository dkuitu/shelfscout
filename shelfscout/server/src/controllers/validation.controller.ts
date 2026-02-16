import { Request, Response, NextFunction } from 'express';
import { ValidationService } from '../services/validation.service';
import { submitValidationSchema } from '../schemas/validation.schema';
import { AuthenticatedRequest } from '../types';

const validationService = new ValidationService();

export async function getValidationQueue(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const submissions = await validationService.getQueue(userId!);
    res.json({ submissions });
  } catch (err) {
    next(err);
  }
}

export async function submitValidation(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const data = submitValidationSchema.parse(req.body);
    const result = await validationService.submitVote(
      req.params.submissionId,
      userId!,
      data.vote,
      data.reason
    );
    res.json(result);
  } catch (err) {
    next(err);
  }
}

export async function getValidationStats(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const stats = await validationService.getStats(userId!);
    res.json({ stats });
  } catch (err) {
    next(err);
  }
}
