import bcrypt from "bcryptjs"
import { BCRYPT_ROUNDS } from "../constants/auth"

// Hash válido de um PIN qualquer, usado para gastar o mesmo tempo quando o
// telefone não existe e não revelar pela latência quais números têm conta
const DUMMY_PIN_HASH = bcrypt.hashSync("000000", BCRYPT_ROUNDS)

export function hashPin(pin: string): Promise<string> {
  return bcrypt.hash(pin, BCRYPT_ROUNDS)
}

export function comparePin(pin: string, hash: string | null): Promise<boolean> {
  return bcrypt.compare(pin, hash ?? DUMMY_PIN_HASH).then((matches) => matches && hash !== null)
}
