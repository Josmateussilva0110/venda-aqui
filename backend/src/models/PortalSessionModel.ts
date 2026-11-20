import { supabase } from "../config/supabase"
import { PORTAL_SESSION_COLUMNS } from "../constants/columns"
import type { PortalSessionRecord } from "../types/portal"

interface PortalSessionRow {
  id: string
  account_id: string
  device_id: string
  expires_at: string
  revoked_at: string | null
}

// Mesmas regras do SessionModel do comerciante, na tabela customer_sessions
class PortalSessionModel {
  // Uma sessão ativa por aparelho: entrar de novo no mesmo aparelho encerra a anterior
  async create(input: { accountId: string; deviceId: string; refreshTokenHash: string; expiresAt: string }): Promise<PortalSessionRecord> {
    const { error: revokeError } = await supabase
      .from("customer_sessions")
      .update({ revoked_at: new Date().toISOString() })
      .eq("account_id", input.accountId)
      .eq("device_id", input.deviceId)
      .is("revoked_at", null)
    if (revokeError) throw revokeError

    const { data, error } = await supabase
      .from("customer_sessions")
      .insert({
        account_id: input.accountId,
        device_id: input.deviceId,
        refresh_token_hash: input.refreshTokenHash,
        expires_at: input.expiresAt,
      })
      .select(PORTAL_SESSION_COLUMNS)
      .single<PortalSessionRow>()
    if (error) throw error
    return this.toSession(data)
  }

  async findByRefreshTokenHash(refreshTokenHash: string): Promise<PortalSessionRecord | null> {
    const { data, error } = await supabase
      .from("customer_sessions")
      .select(PORTAL_SESSION_COLUMNS)
      .eq("refresh_token_hash", refreshTokenHash)
      .maybeSingle<PortalSessionRow>()
    if (error) throw error
    return data ? this.toSession(data) : null
  }

  // A troca só vale se o hash antigo ainda for o atual: dois refresh simultâneos não geram duas sessões
  async rotate(input: { id: string; currentHash: string; newHash: string; expiresAt: string }): Promise<boolean> {
    const { data, error } = await supabase
      .from("customer_sessions")
      .update({ refresh_token_hash: input.newHash, expires_at: input.expiresAt, last_used_at: new Date().toISOString() })
      .eq("id", input.id)
      .eq("refresh_token_hash", input.currentHash)
      .is("revoked_at", null)
      .select("id")
    if (error) throw error
    return data.length > 0
  }

  async revoke(id: string, accountId: string): Promise<void> {
    const { error } = await supabase
      .from("customer_sessions")
      .update({ revoked_at: new Date().toISOString() })
      .eq("id", id)
      .eq("account_id", accountId)
      .is("revoked_at", null)
    if (error) throw error
  }

  private toSession(row: PortalSessionRow): PortalSessionRecord {
    return {
      id: row.id,
      accountId: row.account_id,
      deviceId: row.device_id,
      expiresAt: row.expires_at,
      revokedAt: row.revoked_at,
    }
  }
}

export default new PortalSessionModel()
