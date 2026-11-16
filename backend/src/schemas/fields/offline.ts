import { z } from "zod"
import { DAY_MS, MAX_OFFLINE_SALE_AGE_DAYS } from "../../constants/sales"
import { uuidField } from "./uuid"

// Gerado no aparelho: reenviar a mesma operação (resposta perdida, app fechado no meio) não a duplica
export const clientIdField = uuidField.optional()

// Quando a operação aconteceu no balcão, para as feitas sem internet. Mais velha que o limite fica no
// aparelho em vez de reescrever relatórios já fechados; adiantada (relógio errado) o banco limita a agora
export function offlineMomentField(label: string) {
  return z.iso
    .datetime({ offset: true, error: `Data ${label} inválida.` })
    .refine((value) => Date.now() - Date.parse(value) <= MAX_OFFLINE_SALE_AGE_DAYS * DAY_MS, {
      error: `Operação feita há mais de ${MAX_OFFLINE_SALE_AGE_DAYS} dias não pode mais ser enviada.`,
    })
    .optional()
}
