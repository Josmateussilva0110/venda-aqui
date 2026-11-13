import type { PaymentMethod } from "../sales"
import type { ServiceResult } from "../serviceResult"
import type { CustomerErrorCode } from "./errors"

export * from "./errors"
export * from "./row"

export type CustomerResult<T> = Promise<ServiceResult<T, CustomerErrorCode>>

export interface Customer {
  id: string
  name: string
  phone: string
  // Quanto o cliente deve de fiado agora
  balanceCents: number
  // Data (AAAA-MM-DD) até quando o fiado deve ser pago; nula quando não deve nada
  creditDueDate: string | null
  createdAt: string
  updatedAt: string
}

// Fiado do comércio inteiro, independente do filtro e da página
export interface CreditSummary {
  owingCount: number
  owedCents: number
  // Nulo com os lembretes desligados
  reminders: ReminderSummary | null
}

// O app usa para avisar o comerciante na hora configurada
export interface ReminderSummary {
  dueCount: number
  // Próximo dia (AAAA-MM-DD) em que um lembrete novo fica pendente
  nextOn: string | null
  hour: number
}

// "upcoming": antes do vencimento; "due": vence hoje; "overdue": já venceu
export type ReminderKind = "upcoming" | "due" | "overdue"

export interface CreditReminder {
  id: string
  name: string
  phone: string
  balanceCents: number
  creditDueDate: string
  kind: ReminderKind
}

export interface CreditReminderList {
  items: CreditReminder[]
  total: number
  limit: number
  offset: number
}

export interface OpenPurchaseItem {
  name: string
  quantity: number
  soldByWeight: boolean
  // Valor do item na venda (preço da época), como ficou gravado
  subtotalCents: number
}

export interface OpenPurchase {
  id: string
  createdAt: string
  totalCents: number
  items: OpenPurchaseItem[]
}

// Dívida atual: compras desde a última vez que o saldo zerou e o que já foi pago nelas.
// Compras listadas + anteriores - pago = saldo
export interface OpenAccount {
  balanceCents: number
  creditDueDate: string | null
  paidCents: number
  // As mais recentes (até OPEN_ACCOUNT_PURCHASE_LIMIT), em ordem de data
  purchases: OpenPurchase[]
  earlierCount: number
  earlierCents: number
}

export interface DueDateSaved {
  id: string
  creditDueDate: string
}

export interface CustomerList {
  items: Customer[]
  total: number
  limit: number
  offset: number
  // Só na primeira página (offset 0)
  summary?: CreditSummary
}

// Venda fiado (aumenta a dívida) ou pagamento (diminui), do mais recente para o mais antigo
export interface StatementEntry {
  kind: "sale" | "payment"
  id: string
  amountCents: number
  paymentMethod: PaymentMethod
  createdAt: string
}

export interface CustomerStatement {
  items: StatementEntry[]
  total: number
  limit: number
  offset: number
}

export interface PaymentSaved {
  id: string
  balanceCents: number
}
