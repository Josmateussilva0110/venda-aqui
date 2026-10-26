import { z } from "zod"

function isTrivialPin(pin: string): boolean {
  const digits = pin.split("").map(Number)
  const allSame = digits.every((digit) => digit === digits[0])
  const ascending = digits.every((digit, index) => index === 0 || digit === (digits[index - 1]! + 1) % 10)
  const descending = digits.every((digit, index) => index === 0 || digit === (digits[index - 1]! + 9) % 10)
  return allSame || ascending || descending
}

// Para login: só o formato, sem dizer se o PIN cadastrado seria fraco
export const pinField = z
  .string({ error: "Informe o PIN." })
  .regex(/^\d{4,6}$/, { error: "O PIN deve ter de 4 a 6 números." })

// Para cadastro e troca: com 4 dígitos, recusar 1234 ou 0000 faz diferença real
export const newPinField = pinField.refine((pin) => !isTrivialPin(pin), {
  error: "PIN fácil demais. Evite números repetidos ou em sequência.",
})
