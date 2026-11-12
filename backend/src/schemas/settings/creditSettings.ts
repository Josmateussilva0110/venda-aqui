import { z } from "zod"
import { CREDIT_TERM_DAYS, REMIND_DAYS_BEFORE_MAX, REMIND_OVERDUE_EVERY_DAYS_MAX, REMINDER_HOUR } from "../../constants/settings"

// Uma mensagem só para tipo, inteiro e limites: o comerciante precisa saber o intervalo aceito
function wholeNumber(label: string, min: number, max: number) {
  const message = `Use um número inteiro de ${min} a ${max} para ${label}.`
  return z.number({ error: message }).int({ error: message }).min(min, { error: message }).max(max, { error: message })
}

export const CreditSettingsSchema = z.object({
  creditTermDays: wholeNumber("o prazo do fiado", CREDIT_TERM_DAYS.min, CREDIT_TERM_DAYS.max),
  remindersEnabled: z.boolean({ error: "Informe se os lembretes estão ligados." }),
  // Zero desliga o lembrete antes do vencimento
  remindDaysBefore: wholeNumber("os dias antes do vencimento", 0, REMIND_DAYS_BEFORE_MAX),
  remindOnDue: z.boolean({ error: "Informe se lembra no dia do vencimento." }),
  // Zero desliga os lembretes depois de vencido
  remindOverdueEveryDays: wholeNumber("o intervalo depois de vencido", 0, REMIND_OVERDUE_EVERY_DAYS_MAX),
  reminderHour: wholeNumber("a hora do aviso", REMINDER_HOUR.min, REMINDER_HOUR.max),
})

export type CreditSettingsDTO = z.infer<typeof CreditSettingsSchema>
