import { z } from 'zod';

export const createItemSchema = z.object({
  name: z.string().min(2, 'Item name must be at least 2 characters').max(100),
  category_id: z.string().uuid('Invalid category ID'),
  unit: z.string().min(1, 'Unit is required').max(50),
});

export const searchItemsSchema = z.object({
  q: z.string().optional(),
  category_id: z.string().uuid('Invalid category ID').optional(),
});

export const voteItemSchema = z.object({
  vote: z.enum(['approve', 'reject']),
});

export type CreateItemInput = z.infer<typeof createItemSchema>;
export type SearchItemsInput = z.infer<typeof searchItemsSchema>;
export type VoteItemInput = z.infer<typeof voteItemSchema>;
