import type { StatementEntry, StatementEntryRow } from "../types/customers"
import type { PaymentMethod } from "../types/sales"

// Lançamento da função customer_statement; usado pelo extrato do comerciante e pelo do portal do cliente
export function toStatementEntry(row: StatementEntryRow): StatementEntry {
  return {
    kind: row.kind,
    id: row.id,
    amountCents: row.amount_cents,
    paymentMethod: row.payment_method as PaymentMethod,
    createdAt: row.created_at,
  }
}
