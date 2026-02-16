import { z } from 'zod';

export const submitValidationSchema = z.object({
  vote: z.enum(['confirm', 'flag']),
  reason: z.string().max(500).optional(),
});

export type SubmitValidationInput = z.infer<typeof submitValidationSchema>;
