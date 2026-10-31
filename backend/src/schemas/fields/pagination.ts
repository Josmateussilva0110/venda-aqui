import { z } from "zod"

const MAX_PAGE_SIZE = 100

// Vem da query string, então chega como texto e o coerce converte para número
export const paginationFields = {
  limit: z.coerce
    .number({ error: "Tamanho da página inválido." })
    .int({ error: "Tamanho da página inválido." })
    .min(1, { error: "Tamanho da página inválido." })
    .max(MAX_PAGE_SIZE, { error: `A página tem no máximo ${MAX_PAGE_SIZE} itens.` })
    .default(50),
  offset: z.coerce
    .number({ error: "Posição da página inválida." })
    .int({ error: "Posição da página inválida." })
    .min(0, { error: "Posição da página inválida." })
    .default(0),
}
