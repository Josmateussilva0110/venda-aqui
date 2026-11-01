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
  createdAt: string
  updatedAt: string
}

// Fiado do comércio inteiro, independente do filtro e da página
export interface CreditSummary {
  owingCount: number
  owedCents: number
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
