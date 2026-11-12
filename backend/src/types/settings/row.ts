// Colunas de configuração do fiado na tabela merchants
export interface CreditSettingsRow {
  credit_term_days: number
  reminders_enabled: boolean
  remind_days_before: number
  remind_on_due: boolean
  remind_overdue_every_days: number
  reminder_hour: number
}
