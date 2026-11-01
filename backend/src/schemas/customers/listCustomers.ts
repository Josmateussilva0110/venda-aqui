import { z } from "zod"
import { CUSTOMER_BALANCE_FILTERS } from "../../constants/customers"
import { paginationFields } from "../fields/pagination"
import { searchField } from "../fields/search"

export const ListCustomersSchema = z.object({
  // Busca por nome ou telefone
  search: searchField,
  // "owing" mostra só quem tem fiado em aberto
  balance: z.enum(CUSTOMER_BALANCE_FILTERS, { error: "Filtro de saldo inválido." }).default("all"),
  ...paginationFields,
})

export type ListCustomersDTO = z.infer<typeof ListCustomersSchema>
