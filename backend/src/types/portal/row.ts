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
