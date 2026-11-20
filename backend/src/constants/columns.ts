export const MERCHANT_COLUMNS = "id, name, phone, created_at"
export const MERCHANT_AUTH_COLUMNS = `${MERCHANT_COLUMNS}, pin_hash, failed_pin_attempts, pin_locked_until`

export const SESSION_COLUMNS = "id, merchant_id, device_id, expires_at, revoked_at"

export const PORTAL_ACCOUNT_AUTH_COLUMNS = "id, phone, pin_hash, failed_pin_attempts, pin_locked_until"
export const PORTAL_SESSION_COLUMNS = "id, account_id, device_id, expires_at, revoked_at"

export const PRODUCT_COLUMNS =
  "id, name, photo_path, thumb_path, sale_price_cents, cost_price_cents, quantity, sold_by_weight, created_at, updated_at"

export const CUSTOMER_COLUMNS = "id, name, phone, balance_cents, credit_due_date, created_at, updated_at"

// O CPF é dado pessoal: vai só no detalhe (que abre a edição), nunca nas listas
export const CUSTOMER_DETAIL_COLUMNS = `${CUSTOMER_COLUMNS}, cpf`

export const CREDIT_SETTINGS_COLUMNS =
  "credit_term_days, reminders_enabled, remind_days_before, remind_on_due, remind_overdue_every_days, reminder_hour"
