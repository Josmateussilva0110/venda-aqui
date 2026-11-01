import { z } from "zod"
import { SETTLEMENT_METHODS } from "../../constants/sales"
import { centsField } from "../fields/money"

// O teto real (não pagar mais do que deve) é conferido no banco, contra o saldo travado
export const PaymentSchema = z.object({
  amountCents: centsField("O valor").refine((value) => value > 0, { error: "Informe um valor maior que zero." }),
  paymentMethod: z.enum(SETTLEMENT_METHODS, { error: "Forma de pagamento inválida." }),
})

export type PaymentDTO = z.infer<typeof PaymentSchema>
