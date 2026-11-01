import type { PostgrestError } from "@supabase/supabase-js"
import { supabase } from "../config/supabase"
import { SALE_DB_ERRORS } from "../constants/sales"
import {
  SALE_CREATE_FAILED_ERROR,
  SALE_CREDIT_ALREADY_PAID_ERROR,
  SALE_CUSTOMER_NOT_FOUND_ERROR,
  SALE_FETCH_FAILED_ERROR,
  SALE_LIST_FAILED_ERROR,
  SALE_NOT_FOUND_ERROR,
  SALE_PRODUCT_NOT_FOUND_ERROR,
  SALE_UPDATE_FAILED_ERROR,
  saleInsufficientStockError,
  saleQuantityNotIntegerError,
} from "../errors/sales"
import type { ListSalesDTO } from "../schemas/sales/listSales"
import type { SaleDTO } from "../schemas/sales/sale"
import type { Sale, SaleErrorCode, SaleItem, SaleItemRow, SaleList, SaleListRow, SaleResult, SaleRow, SaleSaved } from "../types/sales"
import { escapeLikePattern } from "../utils/database"

class SaleService {

  async list(merchantId: string, filters: ListSalesDTO): SaleResult<SaleList> {
    try {
      const { data, error } = await supabase
        .rpc("list_sales", {
          p_merchant_id: merchantId,
          p_from: filters.from,
          p_to: filters.to,
          p_payment_method: filters.paymentMethod ?? null,
          // A função usa ilike: os curingas digitados viram texto
          p_search: filters.search ? escapeLikePattern(filters.search) : null,
          p_limit: filters.limit,
          p_offset: filters.offset,
        })
        .single<SaleListRow>()

      if (error || !data) {
        console.error("[SaleService.list]", error)
        return { status: false, error: SALE_LIST_FAILED_ERROR }
      }

      return {
        status: true,
        data: {
          items: data.items.map((row) => this.toSale(row)),
          total: data.total,
          totalCents: data.total_cents,
          limit: filters.limit,
          offset: filters.offset,
        },
      }
    } catch (error) {
      console.error("[SaleService.list] error:", error)
      return { status: false, error: SALE_LIST_FAILED_ERROR }
    }
  }

  async get(merchantId: string, saleId: string): SaleResult<Sale> {
    try {
      const { data, error } = await supabase
        .rpc("get_sale", { p_merchant_id: merchantId, p_sale_id: saleId })
        .maybeSingle<SaleRow | null>()

      if (error) {
        console.error("[SaleService.get]", error)
        return { status: false, error: SALE_FETCH_FAILED_ERROR }
      }
      if (!data) return { status: false, error: SALE_NOT_FOUND_ERROR }

      return { status: true, data: this.toSale(data) }
    } catch (error) {
      console.error("[SaleService.get] error:", error)
      return { status: false, error: SALE_FETCH_FAILED_ERROR }
    }
  }

  async create(merchantId: string, input: SaleDTO): SaleResult<SaleSaved> {
    try {
      const { data, error } = await supabase
        .rpc("register_sale", { p_merchant_id: merchantId, ...this.toArgs(input) })
        .single<{ id: string; total_cents: number }>()

      const ruleError = this.mapRuleError(error)
      if (ruleError) return { status: false, error: ruleError }
      if (error || !data) {
        console.error("[SaleService.create]", error)
        return { status: false, error: SALE_CREATE_FAILED_ERROR }
      }

      return { status: true, data: { id: data.id, totalCents: data.total_cents } }
    } catch (error) {
      console.error("[SaleService.create] error:", error)
      return { status: false, error: SALE_CREATE_FAILED_ERROR }
    }
  }

  async update(merchantId: string, saleId: string, input: SaleDTO): SaleResult<SaleSaved> {
    try {
      const { data, error } = await supabase
        .rpc("update_sale", { p_merchant_id: merchantId, p_sale_id: saleId, ...this.toArgs(input) })
        .single<{ id: string; total_cents: number }>()

      const ruleError = this.mapRuleError(error)
      if (ruleError) return { status: false, error: ruleError }
      if (error || !data) {
        console.error("[SaleService.update]", error)
        return { status: false, error: SALE_UPDATE_FAILED_ERROR }
      }

      return { status: true, data: { id: data.id, totalCents: data.total_cents } }
    } catch (error) {
      console.error("[SaleService.update] error:", error)
      return { status: false, error: SALE_UPDATE_FAILED_ERROR }
    }
  }

  // Erros de regra que as funções do banco sinalizam com SQLSTATE próprio; são respostas
  // normais (estoque acabou, cliente sumiu), por isso não vão para o log de erro
  private mapRuleError(error: PostgrestError | null): { code: SaleErrorCode; message: string } | null {
    switch (error?.code) {
      case SALE_DB_ERRORS.productNotFound:
        return SALE_PRODUCT_NOT_FOUND_ERROR
      case SALE_DB_ERRORS.insufficientStock:
        return saleInsufficientStockError(error.details)
      case SALE_DB_ERRORS.fractionalQuantity:
        return saleQuantityNotIntegerError(error.details)
      case SALE_DB_ERRORS.customerNotFound:
        return SALE_CUSTOMER_NOT_FOUND_ERROR
      case SALE_DB_ERRORS.saleNotFound:
        return SALE_NOT_FOUND_ERROR
      case SALE_DB_ERRORS.negativeBalance:
        return SALE_CREDIT_ALREADY_PAID_ERROR
      default:
        return null
    }
  }

  private toArgs(input: SaleDTO) {
    return {
      p_payment_method: input.paymentMethod,
      p_customer_id: input.customerId ?? null,
      p_items: input.items.map((item) => ({ productId: item.productId, quantity: item.quantity })),
    }
  }

  private toSale(row: SaleRow): Sale {
    return {
      id: row.id,
      paymentMethod: row.payment_method,
      totalCents: row.total_cents,
      createdAt: row.created_at,
      editedAt: row.edited_at,
      customer: row.customer ? { id: row.customer.id, name: row.customer.name } : null,
      items: row.items.map((item) => this.toSaleItem(item)),
    }
  }

  private toSaleItem(row: SaleItemRow): SaleItem {
    return {
      productId: row.product_id,
      name: row.name,
      unitPriceCents: row.unit_price_cents,
      quantity: Number(row.quantity),
      soldByWeight: row.sold_by_weight,
      subtotalCents: row.subtotal_cents,
    }
  }
}

export default new SaleService()
