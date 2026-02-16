import { z } from 'zod';

export const nearbyQuerySchema = z.object({
  lat: z.coerce.number().min(-90).max(90),
  lng: z.coerce.number().min(-180).max(180),
  radius: z.coerce.number().positive().max(50000).default(5000), // meters, default 5km
});

export const suggestStoreSchema = z.object({
  name: z.string().min(1, 'Store name is required').max(200),
  address: z.string().min(1, 'Address is required').max(500),
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
  chain: z.string().max(100).optional(),
});

export type NearbyQuery = z.infer<typeof nearbyQuerySchema>;
export type SuggestStoreInput = z.infer<typeof suggestStoreSchema>;
