export * from "./errors"

export interface Product {
  id: string
  name: string
  photoUrl: string | null
  salePriceCents: number
  costPriceCents: number
  quantity: number
  soldByWeight: boolean
  createdAt: string
  updatedAt: string
}

export interface ProductList {
  items: Product[]
  total: number
  limit: number
  offset: number
}

export interface PhotoUploadTarget {
  path: string
  signedUrl: string
  token: string
}
