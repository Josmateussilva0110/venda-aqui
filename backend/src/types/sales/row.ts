import type { PaymentMethod } from "."

// Venda como sai da função _sale_json no banco, antes de virar Sale
export interface SaleRow {
  id: string
  payment_method: PaymentMethod
  total_cents: number
  created_at: string
  edited_at: string | null
  customer: { id: string; name: string } | null
  items: SaleItemRow[]
}

export interface SaleItemRow {
  product_id: string | null
  name: string
  unit_price_cents: number
  quantity: number
  sold_by_weight: boolean
  subtotal_cents: number
}

export interface SaleListRow {
  total: number
  total_cents: number
  items: SaleRow[]
}
