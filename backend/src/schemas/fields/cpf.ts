import { z } from "zod"
import { isValidCpf } from "../../utils/cpf"

// CPF opcional, como o comerciante digita ("123.456.789-09"); sai só com os dígitos.
// Ausente: não mexe no CPF (app antigo editando não apaga). Vazio ou null: sem CPF (na edição, apaga)
export const optionalCpfField = z
  .string({ error: "CPF inválido." })
  .nullable()
  .transform((value) => (value ?? "").replace(/\D/g, ""))
  .refine((digits) => digits === "" || isValidCpf(digits), { error: "CPF inválido. Confira os 11 números." })
  .transform((digits) => (digits === "" ? null : digits))
  .optional()
