import { Request, Response, NextFunction } from 'express';
import { ItemsService } from '../services/items.service';
import { createItemSchema, voteItemSchema } from '../schemas/item.schema';
import { AuthenticatedRequest } from '../types';

const itemsService = new ItemsService();

export async function getWeeklyItems(_req: Request, res: Response, next: NextFunction) {
  try {
    const items = await itemsService.getWeeklyItems();
    res.json({ items });
  } catch (err) {
    next(err);
  }
}

export async function searchItems(req: Request, res: Response, next: NextFunction) {
  try {
    const q = req.query.q as string | undefined;
    const categoryId = req.query.category_id as string | undefined;
    const items = await itemsService.search(q, categoryId);
    res.json({ items });
  } catch (err) {
    next(err);
  }
}

export async function createItem(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const data = createItemSchema.parse(req.body);
    const item = await itemsService.create(data.name, data.category_id, data.unit, userId!);
    res.status(201).json({ item });
  } catch (err) {
    next(err);
  }
}

export async function voteOnItem(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const data = voteItemSchema.parse(req.body);
    const result = await itemsService.vote(req.params.id, userId!, data.vote);
    res.json(result);
  } catch (err) {
    next(err);
  }
}

export async function getPendingItems(req: Request, res: Response, next: NextFunction) {
  try {
    const { userId } = req as AuthenticatedRequest;
    const items = await itemsService.getPendingItems(userId!);
    res.json({ items });
  } catch (err) {
    next(err);
  }
}

export async function getItem(req: Request, res: Response, next: NextFunction) {
  try {
    const item = await itemsService.getById(req.params.id);
    res.json({ item });
  } catch (err) {
    next(err);
  }
}
