import { z } from "zod"

export const deviceIdField = z
  .string({ error: "Identificador do aparelho ausente." })
  .trim()
  .min(8, { error: "Identificador do aparelho inválido." })
  .max(128, { error: "Identificador do aparelho inválido." })
