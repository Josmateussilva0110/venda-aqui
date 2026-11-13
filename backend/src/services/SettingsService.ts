import { supabase } from "../config/supabase"
import { CREDIT_SETTINGS_COLUMNS } from "../constants/columns"
import { CREDIT_SETTINGS_FETCH_FAILED_ERROR, CREDIT_SETTINGS_UPDATE_FAILED_ERROR } from "../errors/settings"
import type { CreditSettingsDTO } from "../schemas/settings/creditSettings"
import type { CreditSettings, CreditSettingsRow, SettingsResult } from "../types/settings"

class SettingsService {

  async getCredit(merchantId: string): SettingsResult<CreditSettings> {
    try {
      const { data, error } = await supabase
        .from("merchants")
        .select(CREDIT_SETTINGS_COLUMNS)
        .eq("id", merchantId)
        .maybeSingle<CreditSettingsRow>()

      // O comerciante vem do token: não achar a linha é falha, não 404 do cliente
      if (error || !data) {
        console.error("[SettingsService.getCredit]", error ?? "merchant ausente")
        return { status: false, error: CREDIT_SETTINGS_FETCH_FAILED_ERROR }
      }

      return { status: true, data: this.toCreditSettings(data) }
    } catch (error) {
      console.error("[SettingsService.getCredit] error:", error)
      return { status: false, error: CREDIT_SETTINGS_FETCH_FAILED_ERROR }
    }
  }

  async updateCredit(merchantId: string, input: CreditSettingsDTO): SettingsResult<{ id: string }> {
    try {
      const { data, error } = await supabase
        .from("merchants")
        .update(this.toRow(input))
        .eq("id", merchantId)
        .select("id")
        .maybeSingle<{ id: string }>()

      if (error || !data) {
        console.error("[SettingsService.updateCredit]", error ?? "merchant ausente")
        return { status: false, error: CREDIT_SETTINGS_UPDATE_FAILED_ERROR }
      }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[SettingsService.updateCredit] error:", error)
      return { status: false, error: CREDIT_SETTINGS_UPDATE_FAILED_ERROR }
    }
  }

  private toRow(input: CreditSettingsDTO): CreditSettingsRow {
    return {
      credit_term_days: input.creditTermDays,
      reminders_enabled: input.remindersEnabled,
      remind_days_before: input.remindDaysBefore,
      remind_on_due: input.remindOnDue,
      remind_overdue_every_days: input.remindOverdueEveryDays,
      reminder_hour: input.reminderHour,
    }
  }

  private toCreditSettings(row: CreditSettingsRow): CreditSettings {
    return {
      creditTermDays: row.credit_term_days,
      remindersEnabled: row.reminders_enabled,
      remindDaysBefore: row.remind_days_before,
      remindOnDue: row.remind_on_due,
      remindOverdueEveryDays: row.remind_overdue_every_days,
      reminderHour: row.reminder_hour,
    }
  }
}

export default new SettingsService()
