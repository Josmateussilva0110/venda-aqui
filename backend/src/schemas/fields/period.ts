import { z } from "zod"
import { MAX_HISTORY_RANGE_DAYS } from "../../constants/sales"

const DAY_MS = 24 * 60 * 60 * 1000

// O app manda o início e o fim do período já no fuso do aparelho; "to" é exclusivo
export const periodFields = {
  from: z.iso.datetime({ offset: true, error: "Início do período inválido." }),
  to: z.iso.datetime({ offset: true, error: "Fim do período inválido." }),
}

// Mesmas regras de período para histórico e relatório, senão os dois divergem sem ninguém notar
export function withPeriodRules<T extends z.ZodType<{ from: string; to: string }>>(schema: T) {
  return schema
    .refine((data) => Date.parse(data.from) < Date.parse(data.to), {
      error: "O início do período deve ser antes do fim.",
      path: ["to"],
    })
    .refine((data) => Date.parse(data.to) - Date.parse(data.from) <= MAX_HISTORY_RANGE_DAYS * DAY_MS, {
      error: `Escolha um período de até ${MAX_HISTORY_RANGE_DAYS} dias.`,
      path: ["from"],
    })
}
