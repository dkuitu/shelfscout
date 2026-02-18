import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import * as itemsController from '../../controllers/items.controller';

const router = Router();

router.get('/weekly', authenticate, itemsController.getWeeklyItems);

export default router;
