import { supabase } from "../config/supabase"
import { REPORT_RANK_LIMIT } from "../constants/reports"
import { REPORT_FAILED_ERROR } from "../errors/reports"
import type { ReportDTO } from "../schemas/reports/report"
import type { ReportRankingItem, ReportRankingRow, ReportResult, SalesReport, SalesReportRow } from "../types/reports"

class ReportService {

  async sales(merchantId: string, filters: ReportDTO): ReportResult<SalesReport> {
    try {
      const { data, error } = await supabase
        .rpc("sales_report", { p_merchant_id: merchantId, p_from: filters.from, p_to: filters.to, p_rank_limit: REPORT_RANK_LIMIT })
        .single<SalesReportRow>()

      if (error || !data) {
        console.error("[ReportService.sales]", error)
        return { status: false, error: REPORT_FAILED_ERROR }
      }

      return { status: true, data: this.toReport(data) }
    } catch (error) {
      console.error("[ReportService.sales] error:", error)
      return { status: false, error: REPORT_FAILED_ERROR }
    }
  }

  // O lucro sai daqui, não do app: total vendido menos o custo da época de cada venda
  private toReport(row: SalesReportRow): SalesReport {
    const revenueCents = Number(row.revenue_cents)
    const costCents = Number(row.cost_cents)
    return {
      saleCount: row.sale_count,
      revenueCents,
      costCents,
      profitCents: revenueCents - costCents,
      ranking: row.ranking.map((item) => this.toRankingItem(item)),
    }
  }

  private toRankingItem(row: ReportRankingRow): ReportRankingItem {
    return {
      productId: row.product_id,
      name: row.name,
      soldByWeight: row.sold_by_weight,
      quantity: Number(row.quantity),
      revenueCents: Number(row.revenue_cents),
      profitCents: Number(row.profit_cents),
    }
  }
}

export default new ReportService()
