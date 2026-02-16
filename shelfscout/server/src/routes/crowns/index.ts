import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import * as crownsController from '../../controllers/crowns.controller';

const router = Router();

router.get('/region/:regionId', authenticate, crownsController.getCrowns);
router.get('/history/:id', authenticate, crownsController.getCrownHistory);
router.get('/mine', authenticate, crownsController.getUserCrowns);

export default router;
