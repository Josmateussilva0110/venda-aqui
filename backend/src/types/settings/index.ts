import type { ServiceResult } from "../serviceResult"
import type { SettingsErrorCode } from "./errors"

export * from "./errors"
export * from "./row"

export type SettingsResult<T> = Promise<ServiceResult<T, SettingsErrorCode>>

// Prazo do fiado e quando lembrar o cliente (zero desliga o lembrete antes e o de vencido)
export interface CreditSettings {
  creditTermDays: number
  remindersEnabled: boolean
  remindDaysBefore: number
  remindOnDue: boolean
  remindOverdueEveryDays: number
  reminderHour: number
}
