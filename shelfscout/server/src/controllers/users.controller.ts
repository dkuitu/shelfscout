import { Request, Response, NextFunction } from 'express';
import { UsersService } from '../services/users.service';
import { AuthenticatedRequest } from '../types';

const usersService = new UsersService();

export async function getProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const profile = await usersService.getProfile(userId!);
    res.json({ profile });
  } catch (err) {
    next(err);
  }
}

export async function updateProfile(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const { username } = req.body;
    const user = await usersService.updateProfile(userId!, { username });
    res.json({ user });
  } catch (err) {
    next(err);
  }
}

export async function getBadges(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const badges = await usersService.getBadges(userId!);
    res.json({ badges });
  } catch (err) {
    next(err);
  }
}

export async function getStats(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const stats = await usersService.getStats(userId!);
    res.json({ stats });
  } catch (err) {
    next(err);
  }
}
