import { Request, Response, NextFunction } from 'express';
import { ItemsService } from '../services/items.service';

const itemsService = new ItemsService();

export async function getWeeklyItems(req: Request, res: Response, next: NextFunction) {
  try {
    const items = await itemsService.getWeeklyItems();
    res.json({ items });
  } catch (err) {
    next(err);
  }
}
