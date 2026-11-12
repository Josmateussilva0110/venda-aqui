// Linha da tabela customers como vem do Supabase, antes de virar Customer
export interface CustomerRow {
  id: string
  name: string
  phone: string
  balance_cents: number
  credit_due_date: string | null
  created_at: string
  updated_at: string
}

// Lançamento do extrato como sai da função customer_statement
export interface StatementEntryRow {
  kind: "sale" | "payment"
  id: string
  amount_cents: number
  payment_method: string
  created_at: string
}

export interface StatementRow {
  total: number
  items: StatementEntryRow[]
}

// Resultado da função customer_credit_summary
export interface CreditSummaryRow {
  owing_count: number
  owed_cents: number | string
  reminders_enabled: boolean
  reminder_hour: number
  reminders_due: number
  next_reminder_on: string | null
}

// Cliente com lembrete pendente, como sai da função list_credit_reminders
export interface CreditReminderRow {
  id: string
  name: string
  phone: string
  balance_cents: number
  credit_due_date: string
  reminder_kind: "upcoming" | "due" | "overdue"
}

export interface CreditReminderListRow {
  total: number
  items: CreditReminderRow[]
}
