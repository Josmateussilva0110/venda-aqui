import type { ServiceResult } from "../serviceResult"
import type { ProductErrorCode } from "./errors"

export * from "./errors"
export * from "./row"

export type ProductResult<T> = Promise<ServiceResult<T, ProductErrorCode>>

export type StockLevel = "ok" | "low" | "out"

export interface Product {
  id: string
  name: string
  photoUrl: string | null
  thumbUrl: string | null
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

export type StockCountKey = keyof StockCounts

export interface ProductList {
  items: Product[]
  total: number
  limit: number
  offset: number
  // Só na primeira página: as seguintes reaproveitam as contagens que o app já tem
  stockCounts?: StockCounts
  lowStockThreshold: number
}

export interface UploadTarget {
  path: string
  signedUrl: string
  token: string
}

// Foto inteira e miniatura vão em uploads separados, cada uma com sua URL assinada
export interface PhotoUploadTarget extends UploadTarget {
  thumb: UploadTarget
}
