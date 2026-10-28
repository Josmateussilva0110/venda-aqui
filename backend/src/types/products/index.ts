export * from "./errors"

export type StockLevel = "ok" | "low" | "out"

export interface Product {
  id: string
  name: string
  photoUrl: string | null
  salePriceCents: number
  costPriceCents: number
  quantity: number
  soldByWeight: boolean
  stockLevel: StockLevel
  createdAt: string
  updatedAt: string
}

export interface StockCounts {
  all: number
  low: number
  out: number
}

export interface ProductList {
  items: Product[]
  total: number
  limit: number
  offset: number
  stockCounts: StockCounts
  lowStockThreshold: number
}

export interface PhotoUploadTarget {
  path: string
  signedUrl: string
  token: string
}
