import { z } from "zod"
import { SETTLEMENT_METHODS } from "../../constants/sales"
import { centsField } from "../fields/money"
import { clientIdField, offlineMomentField } from "../fields/offline"

// O teto real (não pagar mais do que deve) é conferido no banco, contra o saldo travado
// Recebido sem internet: vem com clientId (reenvio seguro) e paidAt (hora em que o dinheiro foi recebido)
export const PaymentSchema = z
  .object({
    amountCents: centsField("O valor").refine((value) => value > 0, { error: "Informe um valor maior que zero." }),
    paymentMethod: z.enum(SETTLEMENT_METHODS, { error: "Forma de pagamento inválida." }),
    clientId: clientIdField,
    paidAt: offlineMomentField("do pagamento"),
  })
  .refine((data) => !data.paidAt || data.clientId, {
    error: "Pagamento feito sem internet precisa do identificador do aparelho.",
    path: ["clientId"],
  })

export type PaymentDTO = z.infer<typeof PaymentSchema>
