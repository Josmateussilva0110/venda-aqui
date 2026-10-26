import { supabase } from "../config/supabase"
import { MAX_FAILED_PIN_ATTEMPTS, PIN_LOCK_MINUTES } from "../constants/auth"
import { MERCHANT_AUTH_COLUMNS, MERCHANT_COLUMNS } from "../constants/columns"
import type { Merchant } from "../types/auth"

interface MerchantRow {
  id: string
  name: string
  phone: string
  created_at: string
}

interface MerchantAuthRow extends MerchantRow {
  pin_hash: string
  failed_pin_attempts: number
  pin_locked_until: string | null
}

export interface MerchantCredentials {
  merchant: Merchant
  pinHash: string
  failedPinAttempts: number
  pinLockedUntil: string | null
}

// Os métodos lançam o erro do banco; quem chama (service) registra e traduz
class MerchantModel {
  async findById(id: string): Promise<Merchant | null> {
    const { data, error } = await supabase.from("merchants").select(MERCHANT_COLUMNS).eq("id", id).maybeSingle<MerchantRow>()
    if (error) throw error
    return data ? this.toMerchant(data) : null
  }

  async findByPhone(phone: string): Promise<Merchant | null> {
    const { data, error } = await supabase.from("merchants").select(MERCHANT_COLUMNS).eq("phone", phone).maybeSingle<MerchantRow>()
    if (error) throw error
    return data ? this.toMerchant(data) : null
  }

  async findCredentialsByPhone(phone: string): Promise<MerchantCredentials | null> {
    const { data, error } = await supabase
      .from("merchants")
      .select(MERCHANT_AUTH_COLUMNS)
      .eq("phone", phone)
      .maybeSingle<MerchantAuthRow>()
    if (error) throw error
    if (!data) return null
    return {
      merchant: this.toMerchant(data),
      pinHash: data.pin_hash,
      failedPinAttempts: data.failed_pin_attempts,
      pinLockedUntil: data.pin_locked_until,
    }
  }

  async existsByPhone(phone: string): Promise<boolean> {
    const { count, error } = await supabase
      .from("merchants")
      .select("id", { count: "exact", head: true })
      .eq("phone", phone)
    if (error) throw error
    return (count ?? 0) > 0
  }

  async create(input: { name: string; phone: string; pinHash: string }): Promise<Merchant> {
    const { data, error } = await supabase
      .from("merchants")
      .insert({ name: input.name, phone: input.phone, pin_hash: input.pinHash })
      .select(MERCHANT_COLUMNS)
      .single<MerchantRow>()
    if (error) throw error
    return this.toMerchant(data)
  }

  // Devolve até quando o PIN ficou bloqueado, ou null se ainda não atingiu o limite
  async registerFailedPinAttempt(id: string): Promise<string | null> {
    const { data, error } = await supabase.rpc("register_failed_pin_attempt", {
      p_merchant_id: id,
      p_max_attempts: MAX_FAILED_PIN_ATTEMPTS,
      p_lock_minutes: PIN_LOCK_MINUTES,
    })
    if (error) throw error
    return (data as string | null) ?? null
  }

  async resetFailedPinAttempts(id: string): Promise<void> {
    const { error } = await supabase
      .from("merchants")
      .update({ failed_pin_attempts: 0, pin_locked_until: null })
      .eq("id", id)
    if (error) throw error
  }

  async updatePin(id: string, pinHash: string): Promise<void> {
    const { error } = await supabase
      .from("merchants")
      .update({ pin_hash: pinHash, failed_pin_attempts: 0, pin_locked_until: null })
      .eq("id", id)
    if (error) throw error
  }

  private toMerchant(row: MerchantRow): Merchant {
    return { id: row.id, name: row.name, phone: row.phone, createdAt: row.created_at }
  }
}

export default new MerchantModel()
