import { Request, Response, NextFunction } from 'express';
import { SubmissionsService } from '../services/submissions.service';
import { createSubmissionSchema } from '../schemas/submission.schema';
import { AuthenticatedRequest } from '../types';

const submissionsService = new SubmissionsService();

export async function createSubmission(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const data = createSubmissionSchema.parse(req.body);
    const submission = await submissionsService.create(
      userId!,
      data.store_id,
      data.item_id,
      data.price,
      data.photo_url,
      data.gps_lat,
      data.gps_lng
    );
    res.status(201).json({ submission });
  } catch (err) {
    next(err);
  }
}

export async function uploadPhoto(req: Request, res: Response, next: NextFunction) {
  try {
    if (!req.file) {
      res.status(400).json({ error: 'No photo file provided' });
      return;
    }
    const photoUrl = `/uploads/${req.file.filename}`;
    res.json({ photo_url: photoUrl });
  } catch (err) {
    next(err);
  }
}

export async function getSubmission(req: Request, res: Response, next: NextFunction) {
  try {
    const submission = await submissionsService.getById(req.params.id);
    res.json({ submission });
  } catch (err) {
    next(err);
  }
}

export async function getSubmissionsByStore(req: Request, res: Response, next: NextFunction) {
  try {
    const submissions = await submissionsService.getByStore(req.params.storeId);
    res.json({ submissions });
  } catch (err) {
    next(err);
  }
}

export async function getUserSubmissions(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const submissions = await submissionsService.getByUser(userId!);
    res.json({ submissions });
  } catch (err) {
    next(err);
  }
}
