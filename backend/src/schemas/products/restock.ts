import { z } from "zod"
import { clientIdField } from "../fields/offline"
import { quantityField } from "../fields/quantity"

// O app manda só quanto chegou; o novo total é somado no banco, nunca enviado pelo cliente
// clientId vem da reposição feita sem internet: reenviar não soma duas vezes
export const RestockSchema = z.object({
  quantity: quantityField({ value: 0.001, message: "Informe uma quantidade maior que zero." }),
  clientId: clientIdField,
})

export type RestockDTO = z.infer<typeof RestockSchema>
