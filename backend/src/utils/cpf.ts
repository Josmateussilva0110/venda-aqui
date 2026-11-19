// Dígitos verificadores do CPF (regra da Receita). Sequências repetidas ("111.111.111-11") passam na
// conta mas não existem, por isso são recusadas antes
export function isValidCpf(digits: string): boolean {
  if (!/^\d{11}$/.test(digits) || /^(\d)\1{10}$/.test(digits)) return false
  return checkDigit(digits, 9) === Number(digits[9]) && checkDigit(digits, 10) === Number(digits[10])
}

function checkDigit(digits: string, length: number): number {
  let sum = 0
  for (let index = 0; index < length; index++) {
    sum += Number(digits[index]) * (length + 1 - index)
  }
  const rest = (sum * 10) % 11
  return rest === 10 ? 0 : rest
}
