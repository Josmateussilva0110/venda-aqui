import { z } from "zod"
import { STOCK_LEVELS } from "../../constants/products"
import { paginationFields } from "../fields/pagination"
import { searchField } from "../fields/search"

export const ListProductsSchema = z.object({
  search: searchField,
  // "attention" junta baixo e esgotado, do menor estoque para o maior (alertas do início)
  stockLevel: z.enum(STOCK_LEVELS, { error: "Filtro de estoque inválido." }).default("all"),
  ...paginationFields,
})

export type ListProductsDTO = z.infer<typeof ListProductsSchema>
