import { z } from 'zod';

export const createSubmissionSchema = z.object({
  store_id: z.string().uuid('Invalid store ID'),
  item_id: z.string().uuid('Invalid item ID'),
  price: z.number().positive('Price must be positive'),
  photo_url: z.string().url('Invalid photo URL').optional(),
  gps_lat: z.number().min(-90).max(90),
  gps_lng: z.number().min(-180).max(180),
});

export type CreateSubmissionInput = z.infer<typeof createSubmissionSchema>;
