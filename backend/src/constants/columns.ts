export const MERCHANT_COLUMNS = "id, name, phone, created_at"
export const MERCHANT_AUTH_COLUMNS = `${MERCHANT_COLUMNS}, pin_hash, failed_pin_attempts, pin_locked_until`

export const SESSION_COLUMNS = "id, merchant_id, device_id, expires_at, revoked_at"

export const PRODUCT_COLUMNS =
  "id, name, photo_path, thumb_path, sale_price_cents, cost_price_cents, quantity, sold_by_weight, created_at, updated_at"
