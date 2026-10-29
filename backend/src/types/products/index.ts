export * from "./errors"

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
