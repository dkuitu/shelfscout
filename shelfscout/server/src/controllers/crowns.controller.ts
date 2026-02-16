import { Request, Response, NextFunction } from 'express';
import { CrownsService } from '../services/crowns.service';
import { AuthenticatedRequest } from '../types';

const crownsService = new CrownsService();

export async function getCrowns(req: Request, res: Response, next: NextFunction) {
  try {
    const { regionId } = req.params;
    const cycleId = req.query.cycle_id as string | undefined;
    const crowns = await crownsService.getCrowns(regionId, cycleId);
    res.json({ crowns });
  } catch (err) {
    next(err);
  }
}

export async function getCrownHistory(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await crownsService.getHistory(req.params.id);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

export async function getUserCrowns(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const crowns = await crownsService.getUserCrowns(userId!);
    res.json({ crowns });
  } catch (err) {
    next(err);
  }
}
