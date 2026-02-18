import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import * as itemsController from '../../controllers/items.controller';

const router = Router();

router.get('/weekly', authenticate, itemsController.getWeeklyItems);
router.get('/search', authenticate, itemsController.searchItems);
router.get('/pending', authenticate, itemsController.getPendingItems);
router.get('/:id', authenticate, itemsController.getItem);
router.post('/', authenticate, itemsController.createItem);
router.post('/:id/vote', authenticate, itemsController.voteOnItem);

export default router;
