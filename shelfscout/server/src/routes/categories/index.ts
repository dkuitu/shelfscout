import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import * as categoriesController from '../../controllers/categories.controller';

const router = Router();

router.get('/', authenticate, categoriesController.getAllCategories);

export default router;
