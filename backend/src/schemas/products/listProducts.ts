import { z } from "zod"
import { STOCK_LEVELS } from "../../constants/products"

export const ListProductsSchema = z.object({
  search: z
    .string()
    .transform((value) => value.trim())
    .pipe(z.string().max(80, { error: "Busca muito longa." }))
    .optional(),
  // "attention" junta baixo e esgotado, do menor estoque para o maior (alertas do início)
  stockLevel: z.enum(STOCK_LEVELS, { error: "Filtro de estoque inválido." }).default("all"),
  limit: z.coerce.number().int().min(1).max(100).default(50),
  offset: z.coerce.number().int().min(0).default(0),
})

export type ListProductsDTO = z.infer<typeof ListProductsSchema>
