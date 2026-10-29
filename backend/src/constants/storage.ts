export const PRODUCT_PHOTOS_BUCKET = "product-photos"

// A miniatura fica ao lado da foto, com o mesmo nome e este sufixo; o app sempre a gera em JPEG
export const PHOTO_THUMB_SUFFIX = "-thumb.jpg"

export const PHOTO_EXTENSIONS = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
} as const

export type PhotoContentType = keyof typeof PHOTO_EXTENSIONS
