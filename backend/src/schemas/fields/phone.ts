import { z } from "zod"

// Celular no formato antigo, sem o 9 (DDD + 8 dígitos começando de 6 a 9). Fixo começa de 2 a 5
const MOBILE_WITHOUT_NINE = /^([1-9]{2})([6-9]\d{7})$/

// Aceita o número como o comerciante digita ("(86) 99999-0000", "+55 86 ...") e devolve sempre
// +55DDDNÚMERO, o formato salvo no banco. Um número só tem uma forma salva: é o que impede o
// mesmo celular de ser cadastrado duas vezes (com e sem o 9)
export const phoneField = z
  .string({ error: "Informe o telefone." })
  .transform((value) => value.replace(/\D/g, ""))
  .transform((digits) => (digits.length >= 12 && digits.startsWith("55") ? digits.slice(2) : digits))
  .transform((digits) => digits.replace(MOBILE_WITHOUT_NINE, "$19$2"))
  .refine((digits) => /^[1-9]{2}9?\d{8}$/.test(digits), { error: "Telefone inválido. Use DDD + número." })
  .transform((digits) => `+55${digits}`)
