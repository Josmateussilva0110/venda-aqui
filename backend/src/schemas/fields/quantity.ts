import { z } from "zod"

const MAX_QUANTITY = 999_999_999

// Quantidade em estoque: unidades inteiras ou kg com até 3 casas
export function quantityField(min: { value: number; message: string }) {
  return z
    .number({ error: "Informe a quantidade." })
    .min(min.value, { error: min.message })
    .max(MAX_QUANTITY, { error: "Quantidade muito alta." })
    // Tolerância porque 0.1 * 1000 não dá exatamente 100 em ponto flutuante
    .refine((value) => Math.abs(value * 1000 - Math.round(value * 1000)) < 1e-6, {
      error: "Use no máximo 3 casas decimais.",
    })
}
