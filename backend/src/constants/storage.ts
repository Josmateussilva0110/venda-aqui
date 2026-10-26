export const PRODUCT_PHOTOS_BUCKET = "product-photos"

export const PHOTO_EXTENSIONS = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
} as const

export type PhotoContentType = keyof typeof PHOTO_EXTENSIONS
