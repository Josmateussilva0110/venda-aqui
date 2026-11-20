import { supabase } from "../config/supabase"
import { PORTAL_STATEMENT_FAILED_ERROR, PORTAL_STORE_NOT_FOUND_ERROR, PORTAL_STORES_FAILED_ERROR } from "../errors/portal"
import type { StatementDTO } from "../schemas/customers/statement"
import type { CustomerStatement, StatementRow } from "../types/customers"
import type { PortalResult, PortalStore, PortalStoreRow } from "../types/portal"
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

  // storeId é o id do cadastro do cliente naquela loja; a loja (merchant_id) sai do banco, nunca da requisição
  async statement(accountId: string, storeId: string, filters: StatementDTO): PortalResult<CustomerStatement> {
    try {
      const { data: store, error: storeError } = await supabase
        .from("customers")
        .select("merchant_id")
        .eq("id", storeId)
        .eq("portal_account_id", accountId)
        .maybeSingle<{ merchant_id: string }>()
      if (storeError) {
        console.error("[PortalService.statement]", storeError)
        return { status: false, error: PORTAL_STATEMENT_FAILED_ERROR }
      }
      if (!store) return { status: false, error: PORTAL_STORE_NOT_FOUND_ERROR }

      const { data, error } = await supabase
        .rpc("customer_statement", {
          p_merchant_id: store.merchant_id,
          p_customer_id: storeId,
          p_limit: filters.limit,
          p_offset: filters.offset,
        })
        .single<StatementRow>()
      if (error || !data) {
        console.error("[PortalService.statement]", error)
        return { status: false, error: PORTAL_STATEMENT_FAILED_ERROR }
      }

      return {
        status: true,
        data: { items: data.items.map(toStatementEntry), total: data.total, limit: filters.limit, offset: filters.offset },
      }
    } catch (error) {
      console.error("[PortalService.statement] error:", error)
      return { status: false, error: PORTAL_STATEMENT_FAILED_ERROR }
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
