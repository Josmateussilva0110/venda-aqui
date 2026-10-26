import { supabase } from "../config/supabase"
import { SESSION_COLUMNS } from "../constants/columns"

interface SessionRow {
  id: string
  merchant_id: string
  device_id: string
  expires_at: string
  revoked_at: string | null
}

export interface Session {
  id: string
  merchantId: string
  deviceId: string
  expiresAt: string
  revokedAt: string | null
}

class SessionModel {
  // Uma sessão ativa por aparelho: entrar de novo no mesmo aparelho encerra a anterior
  async create(input: { merchantId: string; deviceId: string; refreshTokenHash: string; expiresAt: string }): Promise<Session> {
    const now = new Date().toISOString()

    const { error: revokeError } = await supabase
      .from("sessions")
      .update({ revoked_at: now })
      .eq("merchant_id", input.merchantId)
      .eq("device_id", input.deviceId)
      .is("revoked_at", null)
    if (revokeError) throw revokeError

    const { data, error } = await supabase
      .from("sessions")
      .insert({
        merchant_id: input.merchantId,
        device_id: input.deviceId,
        refresh_token_hash: input.refreshTokenHash,
        expires_at: input.expiresAt,
      })
      .select(SESSION_COLUMNS)
      .single<SessionRow>()
    if (error) throw error
    return this.toSession(data)
  }

  async findByRefreshTokenHash(refreshTokenHash: string): Promise<Session | null> {
    const { data, error } = await supabase
      .from("sessions")
      .select(SESSION_COLUMNS)
      .eq("refresh_token_hash", refreshTokenHash)
      .maybeSingle<SessionRow>()
    if (error) throw error
    return data ? this.toSession(data) : null
  }

  // A troca só vale se o hash antigo ainda for o atual: dois refresh simultâneos
  // com o mesmo token não podem gerar duas sessões válidas
  async rotate(input: { id: string; currentHash: string; newHash: string; expiresAt: string }): Promise<boolean> {
    const { data, error } = await supabase
      .from("sessions")
      .update({ refresh_token_hash: input.newHash, expires_at: input.expiresAt, last_used_at: new Date().toISOString() })
      .eq("id", input.id)
      .eq("refresh_token_hash", input.currentHash)
      .is("revoked_at", null)
      .select("id")
    if (error) throw error
    return data.length > 0
  }

  async revoke(id: string, merchantId: string): Promise<void> {
    const { error } = await supabase
      .from("sessions")
      .update({ revoked_at: new Date().toISOString() })
      .eq("id", id)
      .eq("merchant_id", merchantId)
      .is("revoked_at", null)
    if (error) throw error
  }

  async revokeAllForMerchant(merchantId: string): Promise<void> {
    const { error } = await supabase
      .from("sessions")
      .update({ revoked_at: new Date().toISOString() })
      .eq("merchant_id", merchantId)
      .is("revoked_at", null)
    if (error) throw error
  }

  private toSession(row: SessionRow): Session {
    return {
      id: row.id,
      merchantId: row.merchant_id,
      deviceId: row.device_id,
      expiresAt: row.expires_at,
      revokedAt: row.revoked_at,
    }
  }
}

export default new SessionModel()
