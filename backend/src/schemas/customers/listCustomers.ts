import { z } from "zod"
import { paginationFields } from "../fields/pagination"

export const ListCustomersSchema = z.object({
  // Busca por nome ou telefone; o limite acompanha o tamanho máximo do nome
  search: z
    .string()
    .transform((value) => value.trim())
    .pipe(z.string().max(80, { error: "Busca muito longa." }))
    .optional(),
  ...paginationFields,
})

export type ListCustomersDTO = z.infer<typeof ListCustomersSchema>
