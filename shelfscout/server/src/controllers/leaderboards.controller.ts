import { Request, Response, NextFunction } from 'express';
import { LeaderboardsService } from '../services/leaderboards.service';

const leaderboardsService = new LeaderboardsService();

export async function getRegionalLeaderboard(req: Request, res: Response, next: NextFunction) {
  try {
    const { regionId } = req.params;
    const leaderboard = await leaderboardsService.getRegional(regionId);
    res.json({ leaderboard });
  } catch (err) {
    next(err);
  }
}

export async function getNationalLeaderboard(_req: Request, res: Response, next: NextFunction) {
  try {
    const leaderboard = await leaderboardsService.getNational();
    res.json({ leaderboard });
  } catch (err) {
    next(err);
  }
}

export async function getWeeklyLeaderboard(_req: Request, res: Response, next: NextFunction) {
  try {
    const leaderboard = await leaderboardsService.getWeekly();
    res.json({ leaderboard });
  } catch (err) {
    next(err);
  }
}
