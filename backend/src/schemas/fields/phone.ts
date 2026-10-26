import { z } from "zod"

// Aceita o número como o comerciante digita ("(86) 99999-0000", "+55 86 ...")
// e devolve sempre +55DDDNÚMERO, o formato salvo no banco
export const phoneField = z
  .string({ error: "Informe o telefone." })
  .transform((value) => value.replace(/\D/g, ""))
  .transform((digits) => (digits.length >= 12 && digits.startsWith("55") ? digits.slice(2) : digits))
  .refine((digits) => /^[1-9]{2}9?\d{8}$/.test(digits), { error: "Telefone inválido. Use DDD + número." })
  .transform((digits) => `+55${digits}`)
