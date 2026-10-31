import type { StockCountKey } from "../types/products"

// Até esta quantidade (unidades ou kg) o produto aparece como "estoque baixo"
export const LOW_STOCK_THRESHOLD = 5

export const STOCK_LEVELS = ["all", "low", "out", "attention"] as const

export const STOCK_COUNT_KEYS: StockCountKey[] = ["all", "low", "out"]
