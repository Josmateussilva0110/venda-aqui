// Mesmos limites das constraints da migration 20261111000000_credit_due_dates_and_reminders.sql
export const CREDIT_TERM_DAYS = { min: 1, max: 180 } as const
export const REMIND_DAYS_BEFORE_MAX = 30
export const REMIND_OVERDUE_EVERY_DAYS_MAX = 30
export const REMINDER_HOUR = { min: 0, max: 23 } as const
