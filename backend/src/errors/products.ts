import { ProductErrorCode } from "../types/products"

export const productErrorHttpStatusMap: Record<ProductErrorCode, number> = {
  [ProductErrorCode.PRODUCT_NOT_FOUND]: 404,
  [ProductErrorCode.PRODUCT_NAME_TAKEN]: 409,
  [ProductErrorCode.PHOTO_NOT_UPLOADED]: 400,
  [ProductErrorCode.PHOTO_PATH_INVALID]: 400,
  [ProductErrorCode.RESTOCK_QUANTITY_NOT_INTEGER]: 422,
  [ProductErrorCode.PRODUCT_CREATE_FAILED]: 500,
  [ProductErrorCode.PRODUCT_UPDATE_FAILED]: 500,
  [ProductErrorCode.PRODUCT_LIST_FAILED]: 500,
  [ProductErrorCode.PRODUCT_FETCH_FAILED]: 500,
  [ProductErrorCode.PRODUCT_RESTOCK_FAILED]: 500,
  [ProductErrorCode.PHOTO_UPLOAD_URL_FAILED]: 500,
  [ProductErrorCode.PHOTO_UPDATE_FAILED]: 500,
}
