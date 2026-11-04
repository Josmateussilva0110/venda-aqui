import type { ServiceResult } from "../serviceResult"
import type { ReportErrorCode } from "./errors"

export * from "./errors"
export * from "./row"

export type ReportResult<T> = Promise<ServiceResult<T, ReportErrorCode>>

// Produto no ranking de lucro; productId nulo quando o produto foi excluído depois da venda
export interface ReportRankingItem {
  productId: string | null
  name: string
  soldByWeight: boolean
  quantity: number
  revenueCents: number
  profitCents: number
}

export interface SalesReport {
  saleCount: number
  revenueCents: number
  // Custo guardado em cada item na hora da venda
  costCents: number
  profitCents: number
  ranking: ReportRankingItem[]
}
