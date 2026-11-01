import { SaleErrorCode } from "../types/sales"

export const SALE_NOT_FOUND_ERROR = { code: SaleErrorCode.SALE_NOT_FOUND, message: "Venda não encontrada." }
export const SALE_PRODUCT_NOT_FOUND_ERROR = { code: SaleErrorCode.SALE_PRODUCT_NOT_FOUND, message: "Um dos produtos não existe mais. Atualize a lista." }
export const SALE_CUSTOMER_NOT_FOUND_ERROR = { code: SaleErrorCode.SALE_CUSTOMER_NOT_FOUND, message: "Cliente não encontrado." }
export const SALE_CREDIT_ALREADY_PAID_ERROR = {
  code: SaleErrorCode.SALE_CREDIT_ALREADY_PAID,
  message: "O cliente já pagou parte deste fiado. Não dá para reduzir a dívida abaixo do que foi pago.",
}
export const SALE_CREATE_FAILED_ERROR = { code: SaleErrorCode.SALE_CREATE_FAILED, message: "Erro ao registrar a venda." }
export const SALE_UPDATE_FAILED_ERROR = { code: SaleErrorCode.SALE_UPDATE_FAILED, message: "Erro ao salvar a venda." }
export const SALE_LIST_FAILED_ERROR = { code: SaleErrorCode.SALE_LIST_FAILED, message: "Erro ao carregar as vendas." }
export const SALE_FETCH_FAILED_ERROR = { code: SaleErrorCode.SALE_FETCH_FAILED, message: "Erro ao carregar a venda." }

// O banco informa qual produto falhou, para o comerciante saber o que corrigir no carrinho
export function saleInsufficientStockError(productName: string) {
  return { code: SaleErrorCode.SALE_INSUFFICIENT_STOCK, message: `Estoque insuficiente de ${productName}.` }
}

export function saleQuantityNotIntegerError(productName: string) {
  return { code: SaleErrorCode.SALE_QUANTITY_NOT_INTEGER, message: `${productName} é vendido por unidade: use um número inteiro.` }
}

export const saleErrorHttpStatusMap: Record<SaleErrorCode, number> = {
  [SaleErrorCode.SALE_NOT_FOUND]: 404,
  [SaleErrorCode.SALE_PRODUCT_NOT_FOUND]: 409,
  [SaleErrorCode.SALE_INSUFFICIENT_STOCK]: 409,
  [SaleErrorCode.SALE_QUANTITY_NOT_INTEGER]: 422,
  [SaleErrorCode.SALE_CUSTOMER_NOT_FOUND]: 404,
  [SaleErrorCode.SALE_CREDIT_ALREADY_PAID]: 409,
  [SaleErrorCode.SALE_CREATE_FAILED]: 500,
  [SaleErrorCode.SALE_UPDATE_FAILED]: 500,
  [SaleErrorCode.SALE_LIST_FAILED]: 500,
  [SaleErrorCode.SALE_FETCH_FAILED]: 500,
}
