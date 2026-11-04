// Relatório como sai da função sales_report; somas bigint chegam como número ou texto
export interface SalesReportRow {
  sale_count: number
  revenue_cents: number | string
  cost_cents: number | string
  ranking: ReportRankingRow[]
}

export interface ReportRankingRow {
  product_id: string | null
  name: string
  sold_by_weight: boolean
  quantity: number | string
  revenue_cents: number | string
  profit_cents: number | string
}
