// Linha de customer_accounts com os campos do login
export interface PortalAccountRow {
  id: string
  phone: string
  pin_hash: string
  failed_pin_attempts: number
  pin_locked_until: string | null
}

// Resultado da função customer_portal_invite_info
export interface PortalInviteInfoRow {
  merchant_name: string
  phone: string
  has_account: boolean
}

// Item da função customer_portal_stores
export interface PortalStoreRow {
  customer_id: string
  merchant_name: string
  customer_name: string
  balance_cents: number
  credit_due_date: string | null
}

// Resultado da função customer_portal_statement; quantidade chega como texto ou número (numeric)
export interface PortalStatementRow {
  total: number
  items: Array<{
    kind: "sale" | "payment"
    id: string
    amount_cents: number
    payment_method: string
    created_at: string
    items: Array<{ name: string; quantity: number | string; sold_by_weight: boolean; subtotal_cents: number }>
  }>
}
