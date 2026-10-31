import { CustomerErrorCode } from "../types/customers"

export const CUSTOMER_NOT_FOUND_ERROR = { code: CustomerErrorCode.CUSTOMER_NOT_FOUND, message: "Cliente não encontrado." }
export const CUSTOMER_LIST_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_LIST_FAILED, message: "Erro ao carregar os clientes." }
export const CUSTOMER_PHONE_TAKEN_ERROR = { code: CustomerErrorCode.CUSTOMER_PHONE_TAKEN, message: "Você já tem um cliente com esse telefone." }

export const customerErrorHttpStatusMap: Record<CustomerErrorCode, number> = {
  [CustomerErrorCode.CUSTOMER_NOT_FOUND]: 404,
  [CustomerErrorCode.CUSTOMER_PHONE_TAKEN]: 409,
  [CustomerErrorCode.CUSTOMER_CREATE_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_UPDATE_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_LIST_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_FETCH_FAILED]: 500,
}
