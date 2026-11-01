import { z } from "zod"
import { MAX_HISTORY_RANGE_DAYS, PAYMENT_METHODS } from "../../constants/sales"
import { paginationFields } from "../fields/pagination"
import { searchField } from "../fields/search"

const DAY_MS = 24 * 60 * 60 * 1000

// O app manda o início e o fim do período já no fuso do aparelho; "to" é exclusivo
export const ListSalesSchema = z
  .object({
    from: z.iso.datetime({ offset: true, error: "Início do período inválido." }),
    to: z.iso.datetime({ offset: true, error: "Fim do período inválido." }),
    paymentMethod: z.enum(PAYMENT_METHODS, { error: "Forma de pagamento inválida." }).optional(),
    search: searchField,
    ...paginationFields,
  })
  .refine((data) => Date.parse(data.from) < Date.parse(data.to), {
    error: "O início do período deve ser antes do fim.",
    path: ["to"],
  })
  .refine((data) => Date.parse(data.to) - Date.parse(data.from) <= MAX_HISTORY_RANGE_DAYS * DAY_MS, {
    error: `Escolha um período de até ${MAX_HISTORY_RANGE_DAYS} dias.`,
    path: ["from"],
  })

export type ListSalesDTO = z.infer<typeof ListSalesSchema>
