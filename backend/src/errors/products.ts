import { ProductErrorCode } from "../types/products"

export const PRODUCT_NOT_FOUND_ERROR = { code: ProductErrorCode.PRODUCT_NOT_FOUND, message: "Produto não encontrado." }
export const PRODUCT_NAME_TAKEN_ERROR = { code: ProductErrorCode.PRODUCT_NAME_TAKEN, message: "Você já tem um produto com esse nome." }
export const PRODUCT_LIST_FAILED_ERROR = { code: ProductErrorCode.PRODUCT_LIST_FAILED, message: "Erro ao carregar os produtos." }
export const PRODUCT_FETCH_FAILED_ERROR = { code: ProductErrorCode.PRODUCT_FETCH_FAILED, message: "Erro ao carregar o produto." }
export const PRODUCT_CREATE_FAILED_ERROR = { code: ProductErrorCode.PRODUCT_CREATE_FAILED, message: "Erro ao cadastrar o produto." }
export const PRODUCT_UPDATE_FAILED_ERROR = { code: ProductErrorCode.PRODUCT_UPDATE_FAILED, message: "Erro ao salvar o produto." }
export const PRODUCT_RESTOCK_FAILED_ERROR = { code: ProductErrorCode.PRODUCT_RESTOCK_FAILED, message: "Erro ao repor o estoque." }
export const PRODUCT_PHOTO_UPLOAD_URL_FAILED_ERROR = { code: ProductErrorCode.PHOTO_UPLOAD_URL_FAILED, message: "Erro ao preparar o envio da foto." }
export const PRODUCT_PHOTO_UPDATE_FAILED_ERROR = { code: ProductErrorCode.PHOTO_UPDATE_FAILED, message: "Erro ao salvar a foto." }

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
