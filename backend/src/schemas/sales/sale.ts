import { z } from "zod"
import { MAX_SALE_ITEMS, PAYMENT_METHODS } from "../../constants/sales"
import { clientIdField, offlineMomentField } from "../fields/offline"
import { quantityField } from "../fields/quantity"
import { uuidField } from "../fields/uuid"

// O app manda só o que foi vendido: preço e total saem do banco, nunca do cliente
const SaleItemSchema = z.object({
  productId: uuidField,
  quantity: quantityField({ value: 0.001, message: "Informe uma quantidade maior que zero." }),
})

const saleFields = {
  paymentMethod: z.enum(PAYMENT_METHODS, { error: "Forma de pagamento inválida." }),
  customerId: uuidField.optional(),
  items: z
    .array(SaleItemSchema, { error: "Informe os itens da venda." })
    .min(1, { error: "Adicione pelo menos um produto." })
    .max(MAX_SALE_ITEMS, { error: `A venda tem no máximo ${MAX_SALE_ITEMS} produtos.` }),
}

// Mesmas regras no registro e na edição, senão as duas divergem sem ninguém notar
function withSaleRules<T extends z.ZodType<{ paymentMethod: string; customerId?: string; items: Array<{ productId: string }> }>>(schema: T) {
  return schema
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
}

// Edição: o mesmo payload do registro, sem os campos da venda feita sem internet
export const SaleSchema = withSaleRules(z.object(saleFields))

// Registro. Venda feita sem internet vem com clientId (gerado no aparelho, torna o reenvio seguro) e
// soldAt (hora do balcão); com soldAt, falta de estoque é aceita e volta como aviso
export const CreateSaleSchema = withSaleRules(
  z.object({
    ...saleFields,
    clientId: clientIdField,
    soldAt: offlineMomentField("da venda"),
  }),
).refine((data) => !data.soldAt || data.clientId, {
  error: "Venda feita sem internet precisa do identificador do aparelho.",
  path: ["clientId"],
})

export type SaleDTO = z.infer<typeof SaleSchema>
export type CreateSaleDTO = z.infer<typeof CreateSaleSchema>
