export const CUSTOMER_BALANCE_FILTERS = ["all", "owing"] as const

// Compras listadas na cobrança pelo WhatsApp; as mais antigas viram "mais N compras", para a mensagem não crescer sem fim
export const OPEN_ACCOUNT_PURCHASE_LIMIT = 10

// Índice único do CPF por comércio (migration 20261119000000_customer_cpf.sql): o erro dele vira "CPF repetido"
export const CUSTOMER_CPF_UNIQUE_INDEX = "customers_merchant_cpf_key"
