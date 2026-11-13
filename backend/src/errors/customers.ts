import { CustomerErrorCode } from "../types/customers"

export const CUSTOMER_NOT_FOUND_ERROR = { code: CustomerErrorCode.CUSTOMER_NOT_FOUND, message: "Cliente não encontrado." }
export const CUSTOMER_PHONE_TAKEN_ERROR = { code: CustomerErrorCode.CUSTOMER_PHONE_TAKEN, message: "Você já tem um cliente com esse telefone." }
export const CUSTOMER_LIST_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_LIST_FAILED, message: "Erro ao carregar os clientes." }
export const CUSTOMER_FETCH_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_FETCH_FAILED, message: "Erro ao carregar o cliente." }
export const CUSTOMER_CREATE_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_CREATE_FAILED, message: "Erro ao cadastrar o cliente." }
export const CUSTOMER_UPDATE_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_UPDATE_FAILED, message: "Erro ao salvar o cliente." }
export const CUSTOMER_HAS_HISTORY_ERROR = {
  code: CustomerErrorCode.CUSTOMER_HAS_HISTORY,
  message: "Este cliente tem fiado no histórico e não pode ser excluído.",
}
export const CUSTOMER_PAYMENT_EXCEEDS_BALANCE_ERROR = {
  code: CustomerErrorCode.CUSTOMER_PAYMENT_EXCEEDS_BALANCE,
  message: "O valor é maior do que o cliente deve.",
}
export const CUSTOMER_PAYMENT_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_PAYMENT_FAILED, message: "Erro ao registrar o pagamento." }
export const CUSTOMER_STATEMENT_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_STATEMENT_FAILED, message: "Erro ao carregar o extrato." }
export const CUSTOMER_DELETE_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_DELETE_FAILED, message: "Erro ao excluir o cliente." }
export const CUSTOMER_NOT_OWING_ERROR = { code: CustomerErrorCode.CUSTOMER_NOT_OWING, message: "Este cliente não tem fiado em aberto." }
export const CUSTOMER_DUE_DATE_INVALID_ERROR = {
  code: CustomerErrorCode.CUSTOMER_DUE_DATE_INVALID,
  message: "Escolha um vencimento entre hoje e daqui a um ano.",
}
export const CUSTOMER_DUE_DATE_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_DUE_DATE_FAILED, message: "Erro ao mudar o vencimento." }
export const CUSTOMER_REMINDERS_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_REMINDERS_FAILED, message: "Erro ao carregar os lembretes." }
export const CUSTOMER_OPEN_ACCOUNT_FAILED_ERROR = {
  code: CustomerErrorCode.CUSTOMER_OPEN_ACCOUNT_FAILED,
  message: "Erro ao carregar as compras do cliente.",
}
export const CUSTOMER_REMINDER_FAILED_ERROR = { code: CustomerErrorCode.CUSTOMER_REMINDER_FAILED, message: "Erro ao registrar o lembrete." }

export const customerErrorHttpStatusMap: Record<CustomerErrorCode, number> = {
  [CustomerErrorCode.CUSTOMER_NOT_FOUND]: 404,
  [CustomerErrorCode.CUSTOMER_PHONE_TAKEN]: 409,
  [CustomerErrorCode.CUSTOMER_CREATE_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_UPDATE_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_LIST_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_FETCH_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_DELETE_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_HAS_HISTORY]: 409,
  [CustomerErrorCode.CUSTOMER_PAYMENT_EXCEEDS_BALANCE]: 409,
  [CustomerErrorCode.CUSTOMER_PAYMENT_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_STATEMENT_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_NOT_OWING]: 409,
  [CustomerErrorCode.CUSTOMER_DUE_DATE_INVALID]: 422,
  [CustomerErrorCode.CUSTOMER_DUE_DATE_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_REMINDERS_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_REMINDER_FAILED]: 500,
  [CustomerErrorCode.CUSTOMER_OPEN_ACCOUNT_FAILED]: 500,
}
