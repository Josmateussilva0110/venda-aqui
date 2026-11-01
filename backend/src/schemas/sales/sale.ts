import { z } from "zod"
import { MAX_SALE_ITEMS, PAYMENT_METHODS } from "../../constants/sales"
import { quantityField } from "../fields/quantity"
import { uuidField } from "../fields/uuid"

// O app manda só o que foi vendido: preço e total saem do banco, nunca do cliente
const SaleItemSchema = z.object({
  productId: uuidField,
  quantity: quantityField({ value: 0.001, message: "Informe uma quantidade maior que zero." }),
})

// O mesmo payload serve para registrar e editar a venda
export const SaleSchema = z
  .object({
    paymentMethod: z.enum(PAYMENT_METHODS, { error: "Forma de pagamento inválida." }),
    customerId: uuidField.optional(),
    items: z
      .array(SaleItemSchema, { error: "Informe os itens da venda." })
      .min(1, { error: "Adicione pelo menos um produto." })
      .max(MAX_SALE_ITEMS, { error: `A venda tem no máximo ${MAX_SALE_ITEMS} produtos.` }),
  })
  .refine((data) => data.paymentMethod !== "credit" || data.customerId, {
    error: "Escolha o cliente do fiado.",
    path: ["customerId"],
  })
  .refine((data) => data.paymentMethod === "credit" || !data.customerId, {
    error: "Só a venda fiado tem cliente.",
    path: ["customerId"],
  })
  .refine((data) => new Set(data.items.map((item) => item.productId)).size === data.items.length, {
    error: "Produto repetido na venda: some as quantidades num item só.",
    path: ["items"],
  })

export type SaleDTO = z.infer<typeof SaleSchema>
