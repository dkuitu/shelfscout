import { Request, Response, NextFunction } from 'express';
import { StoresService } from '../services/stores.service';
import { nearbyQuerySchema, suggestStoreSchema } from '../schemas/store.schema';
import { AuthenticatedRequest } from '../types';

const storesService = new StoresService();

export async function getNearbyStores(req: Request, res: Response, next: NextFunction) {
  try {
    const { lat, lng, radius } = nearbyQuerySchema.parse(req.query);
    const stores = await storesService.getNearby(lat, lng, radius);
    res.json({ stores });
  } catch (err) {
    next(err);
  }
}

export async function getStore(req: Request, res: Response, next: NextFunction) {
  try {
    const store = await storesService.getById(req.params.id);
    res.json({ store });
  } catch (err) {
    next(err);
  }
}

export async function suggestStore(req: Request, res: Response, next: NextFunction) {
  try {
    const data = suggestStoreSchema.parse(req.body);
    const store = await storesService.suggest(data.name, data.address, data.lat, data.lng, data.chain);
    res.status(201).json({ store });
  } catch (err) {
    next(err);
  }
}
