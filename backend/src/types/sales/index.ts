import type { PAYMENT_METHODS } from "../../constants/sales"
import type { ServiceResult } from "../serviceResult"
import type { SaleErrorCode } from "./errors"

export * from "./errors"
export * from "./row"

export type SaleResult<T> = Promise<ServiceResult<T, SaleErrorCode>>

export type PaymentMethod = (typeof PAYMENT_METHODS)[number]

export interface SaleItem {
  // Nulo quando o produto foi apagado depois da venda; nome e preço continuam guardados
  productId: string | null
  name: string
  unitPriceCents: number
  quantity: number
  soldByWeight: boolean
  subtotalCents: number
}

export interface Sale {
  id: string
  paymentMethod: PaymentMethod
  totalCents: number
  createdAt: string
  editedAt: string | null
  customer: { id: string; name: string } | null
  items: SaleItem[]
}

export interface SaleList {
  items: Sale[]
  total: number
  // Soma de todas as vendas do filtro, não só da página
  totalCents: number
  limit: number
  offset: number
}

// Resposta do registro e da edição: o total vai junto porque quem calcula é o servidor
export interface SaleSaved {
  id: string
  totalCents: number
}
