import { z } from "zod"
import { PAYMENT_METHODS } from "../../constants/sales"
import { paginationFields } from "../fields/pagination"
import { periodFields, withPeriodRules } from "../fields/period"
import { searchField } from "../fields/search"

export const ListSalesSchema = withPeriodRules(
  z.object({
    ...periodFields,
    paymentMethod: z.enum(PAYMENT_METHODS, { error: "Forma de pagamento inválida." }).optional(),
    search: searchField,
    ...paginationFields,
  }),
)

export type ListSalesDTO = z.infer<typeof ListSalesSchema>
