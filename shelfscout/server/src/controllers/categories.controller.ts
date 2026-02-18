import { Request, Response, NextFunction } from 'express';
import { CategoriesService } from '../services/categories.service';

const categoriesService = new CategoriesService();

export async function getAllCategories(_req: Request, res: Response, next: NextFunction) {
  try {
    const categories = await categoriesService.getAll();
    res.json({ categories });
  } catch (err) {
    next(err);
  }
}
