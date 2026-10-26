import { z } from "zod"
import { centsField } from "../fields/money"
import { nameField } from "../fields/name"

const MAX_QUANTITY = 999_999_999

// O mesmo payload serve para criar e editar: a tela de edição é a de cadastro pré-preenchida
export const ProductSchema = z
  .object({
    name: nameField("o nome do produto", 1, 80),
    salePriceCents: centsField("Preço de venda"),
    costPriceCents: centsField("Preço de custo"),
    quantity: z
      .number({ error: "Informe a quantidade." })
      .min(0, { error: "A quantidade não pode ser negativa." })
      .max(MAX_QUANTITY, { error: "Quantidade muito alta." })
      // Tolerância porque 0.1 * 1000 não dá exatamente 100 em ponto flutuante
      .refine((value) => Math.abs(value * 1000 - Math.round(value * 1000)) < 1e-6, {
        error: "Use no máximo 3 casas decimais.",
      }),
    soldByWeight: z.boolean({ error: "Informe se o produto é vendido por peso." }).default(false),
  })
  .refine((data) => data.soldByWeight || Number.isInteger(data.quantity), {
    error: "Produto vendido por unidade deve ter quantidade inteira.",
    path: ["quantity"],
  })

export type ProductDTO = z.infer<typeof ProductSchema>
