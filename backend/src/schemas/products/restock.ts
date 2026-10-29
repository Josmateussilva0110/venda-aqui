import { z } from "zod"
import { quantityField } from "../fields/quantity"

// O app manda só quanto chegou; o novo total é somado no banco, nunca enviado pelo cliente
export const RestockSchema = z.object({
  quantity: quantityField({ value: 0.001, message: "Informe uma quantidade maior que zero." }),
})

export type RestockDTO = z.infer<typeof RestockSchema>
