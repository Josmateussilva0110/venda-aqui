import { z } from "zod"

export const ListProductsSchema = z.object({
  search: z
    .string()
    .transform((value) => value.trim())
    .pipe(z.string().max(80, { error: "Busca muito longa." }))
    .optional(),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).default(0),
})

export type ListProductsDTO = z.infer<typeof ListProductsSchema>
