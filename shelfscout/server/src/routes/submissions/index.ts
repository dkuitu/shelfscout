import { Router } from 'express';
import { authenticate } from '../../middleware/auth';
import { upload } from '../../middleware/upload';
import * as submissionsController from '../../controllers/submissions.controller';

const router = Router();

router.post('/upload', authenticate, upload.single('photo'), submissionsController.uploadPhoto);
router.post('/', authenticate, submissionsController.createSubmission);
router.get('/mine', authenticate, submissionsController.getUserSubmissions);
router.get('/store/:storeId', authenticate, submissionsController.getSubmissionsByStore);
router.get('/:id', authenticate, submissionsController.getSubmission);

export default router;
