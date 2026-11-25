import { supabase } from "../config/supabase"
import { PORTAL_STATEMENT_FAILED_ERROR, PORTAL_STORE_NOT_FOUND_ERROR, PORTAL_STORES_FAILED_ERROR } from "../errors/portal"
import type { StatementDTO } from "../schemas/customers/statement"
import type { PortalResult, PortalStatement, PortalStatementEntry, PortalStatementRow, PortalStore, PortalStoreRow } from "../types/portal"
import { toStatementEntry } from "../utils/statement"

// Consultas do cliente logado. Tudo filtra pela conta do token: só aparecem lojas ligadas por convite
class PortalService {
  async listStores(accountId: string): PortalResult<PortalStore[]> {
    try {
      const { data, error } = await supabase.rpc("customer_portal_stores", { p_account_id: accountId })
      if (error || !Array.isArray(data)) {
        console.error("[PortalService.listStores]", error)
        return { status: false, error: PORTAL_STORES_FAILED_ERROR }
      }

      return { status: true, data: (data as PortalStoreRow[]).map((row) => this.toStore(row)) }
    } catch (error) {
      console.error("[PortalService.listStores] error:", error)
      return { status: false, error: PORTAL_STORES_FAILED_ERROR }
    }
  }

  // storeId é o id do cadastro do cliente na loja; a função confere que ele é desta conta e tira dele a loja
  async statement(accountId: string, storeId: string, filters: StatementDTO): PortalResult<PortalStatement> {
    try {
      const { data, error } = await supabase.rpc("customer_portal_statement", {
        p_account_id: accountId,
        p_customer_id: storeId,
        p_limit: filters.limit,
        p_offset: filters.offset,
      })
      if (error) {
        console.error("[PortalService.statement]", error)
        return { status: false, error: PORTAL_STATEMENT_FAILED_ERROR }
      }
      if (!data) return { status: false, error: PORTAL_STORE_NOT_FOUND_ERROR }

      const page = data as PortalStatementRow
      return {
        status: true,
        data: { items: page.items.map((row) => this.toStatementEntry(row)), total: page.total, limit: filters.limit, offset: filters.offset },
      }
    } catch (error) {
      console.error("[PortalService.statement] error:", error)
      return { status: false, error: PORTAL_STATEMENT_FAILED_ERROR }
    }
  }

  private toStatementEntry(row: PortalStatementRow["items"][number]): PortalStatementEntry {
    return {
      ...toStatementEntry(row),
      items: row.items.map((item) => ({
        name: item.name,
        quantity: Number(item.quantity),
        soldByWeight: item.sold_by_weight,
        subtotalCents: item.subtotal_cents,
      })),
    }
  }

  private toStore(row: PortalStoreRow): PortalStore {
    return {
      id: row.customer_id,
      merchantName: row.merchant_name,
      customerName: row.customer_name,
      balanceCents: row.balance_cents,
      creditDueDate: row.credit_due_date,
    }
  }
}

export default new PortalService()

