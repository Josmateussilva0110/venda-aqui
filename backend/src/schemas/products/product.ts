import { z } from "zod"
import { centsField } from "../fields/money"
import { nameField } from "../fields/name"
import { quantityField } from "../fields/quantity"

// O mesmo payload serve para criar e editar: a tela de edição é a de cadastro pré-preenchida
export const ProductSchema = z
  .object({
    name: nameField("o nome do produto", 1, 80),
    salePriceCents: centsField("Preço de venda"),
    costPriceCents: centsField("Preço de custo"),
    quantity: quantityField({ value: 0, message: "A quantidade não pode ser negativa." }),
    soldByWeight: z.boolean({ error: "Informe se o produto é vendido por peso." }).default(false),
  })
  .refine((data) => data.soldByWeight || Number.isInteger(data.quantity), {
    error: "Produto vendido por unidade deve ter quantidade inteira.",
    path: ["quantity"],
  })

export type ProductDTO = z.infer<typeof ProductSchema>
