import { z } from "zod"

// Texto de busca vindo da query string; vazio depois do trim é tratado como sem busca
export const searchField = z
  .string()
  .transform((value) => value.trim())
  .pipe(z.string().max(80, { error: "Busca muito longa." }))
  .optional()
