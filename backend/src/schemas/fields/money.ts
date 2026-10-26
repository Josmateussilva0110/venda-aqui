import { z } from "zod"

// Valores em centavos (inteiros) para não acumular erro de ponto flutuante no lucro
export function centsField(label: string) {
  return z
    .number({ error: `Informe ${label}.` })
    .int({ error: `${label} deve ser em centavos (número inteiro).` })
    .min(0, { error: `${label} não pode ser negativo.` })
    .max(100_000_000, { error: `${label} muito alto.` })
}
