// "credit" é o fiado: a venda fica no saldo do cliente até ele pagar
export const PAYMENT_METHODS = ["cash", "pix", "card", "credit"] as const

// Formas aceitas para quitar o fiado (pagar fiado com fiado não faz sentido)
export const SETTLEMENT_METHODS = ["cash", "pix", "card"] as const

export const MAX_SALE_ITEMS = 100

// Um ano de histórico por consulta: períodos maiores varreriam vendas demais de uma vez
export const MAX_HISTORY_RANGE_DAYS = 366

// SQLSTATE próprios das funções de venda e fiado (migration 20261031010000_sales_and_credit.sql)
export const SALE_DB_ERRORS = {
  productNotFound: "VQ001",
  insufficientStock: "VQ002",
  fractionalQuantity: "VQ003",
  customerNotFound: "VQ004",
  saleNotFound: "VQ005",
  negativeBalance: "VQ006",
  // Vencimento do fiado (migration 20261111000000_credit_due_dates_and_reminders.sql)
  customerNotOwing: "VQ007",
  invalidDueDate: "VQ008",
} as const
