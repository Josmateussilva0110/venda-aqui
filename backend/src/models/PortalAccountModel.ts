import { supabase } from "../config/supabase"
import { MAX_FAILED_PIN_ATTEMPTS, PIN_LOCK_MINUTES } from "../constants/auth"
import { PORTAL_ACCOUNT_AUTH_COLUMNS } from "../constants/columns"
import type { PortalAccountCredentials, PortalAccountRow } from "../types/portal"

// Os métodos lançam o erro do banco; quem chama (service) registra e traduz
class PortalAccountModel {
  async findCredentialsByPhone(phone: string): Promise<PortalAccountCredentials | null> {
    const { data, error } = await supabase
      .from("customer_accounts")
      .select(PORTAL_ACCOUNT_AUTH_COLUMNS)
      .eq("phone", phone)
      .maybeSingle<PortalAccountRow>()
    if (error) throw error
    return data ? this.toCredentials(data) : null
  }

  async findCredentialsById(id: string): Promise<PortalAccountCredentials | null> {
    const { data, error } = await supabase
      .from("customer_accounts")
      .select(PORTAL_ACCOUNT_AUTH_COLUMNS)
      .eq("id", id)
      .maybeSingle<PortalAccountRow>()
    if (error) throw error
    return data ? this.toCredentials(data) : null
  }

  // Contas cujas lojas ligadas têm este CPF. Mais de uma é possível (o CPF é digitado por cada
  // comerciante), e aí quem chama recusa a entrada pelo CPF em vez de escolher uma
  async findIdsByCpf(cpf: string): Promise<string[]> {
    const { data, error } = await supabase
      .from("customers")
      .select("portal_account_id")
      .eq("cpf", cpf)
      .not("portal_account_id", "is", null)
      .returns<Array<{ portal_account_id: string }>>()
    if (error) throw error
    return [...new Set(data.map((row) => row.portal_account_id))]
  }

  // Devolve até quando o PIN ficou bloqueado, ou null se ainda não atingiu o limite
  async registerFailedPinAttempt(id: string): Promise<string | null> {
    const { data, error } = await supabase.rpc("register_failed_portal_pin_attempt", {
      p_account_id: id,
      p_max_attempts: MAX_FAILED_PIN_ATTEMPTS,
      p_lock_minutes: PIN_LOCK_MINUTES,
    })
    if (error) throw error
    return (data as string | null) ?? null
  }

  async resetFailedPinAttempts(id: string): Promise<void> {
    const { error } = await supabase
      .from("customer_accounts")
      .update({ failed_pin_attempts: 0, pin_locked_until: null })
      .eq("id", id)
    if (error) throw error
  }

  private toCredentials(row: PortalAccountRow): PortalAccountCredentials {
    return {
      account: { id: row.id, phone: row.phone },
      pinHash: row.pin_hash,
      failedPinAttempts: row.failed_pin_attempts,
      pinLockedUntil: row.pin_locked_until,
    }
  }
}

export default new PortalAccountModel()
