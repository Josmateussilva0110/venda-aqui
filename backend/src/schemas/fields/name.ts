import { z } from "zod"

export function nameField(label: string, min: number, max: number) {
  return z
    .string({ error: `Informe ${label}.` })
    .transform((value) => value.trim().replace(/\s+/g, " "))
    .pipe(
      z
        .string()
        .min(min, { error: min === 1 ? `Informe ${label}.` : `Use pelo menos ${min} letras.` })
        .max(max, { error: `Use no máximo ${max} caracteres.` }),
    )
}
