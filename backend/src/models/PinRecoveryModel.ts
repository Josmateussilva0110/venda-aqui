import { supabase } from "../config/supabase"
import { MAX_RECOVERY_CODE_ATTEMPTS } from "../constants/auth"

interface ConsumedCodeRow {
  id: string
  code_hash: string
}

export interface ConsumedRecoveryCode {
  id: string
  codeHash: string
}

class PinRecoveryModel {
  // Pedir um código novo invalida os anteriores, senão vários códigos válidos
  // multiplicariam as chances de acerto
  async create(input: { merchantId: string; codeHash: string; expiresAt: string }): Promise<void> {
    const { error: invalidateError } = await supabase
      .from("pin_recovery_codes")
      .update({ used_at: new Date().toISOString() })
      .eq("merchant_id", input.merchantId)
      .is("used_at", null)
    if (invalidateError) throw invalidateError

    const { error } = await supabase
      .from("pin_recovery_codes")
      .insert({ merchant_id: input.merchantId, code_hash: input.codeHash, expires_at: input.expiresAt })
    if (error) throw error
  }

  // Gasta uma tentativa do código ativo e devolve o hash para comparar.
  // null quando não há código válido: inexistente, expirado ou sem tentativas
  async consumeAttempt(merchantId: string): Promise<ConsumedRecoveryCode | null> {
    const { data, error } = await supabase.rpc("consume_pin_recovery_attempt", {
      p_merchant_id: merchantId,
      p_max_attempts: MAX_RECOVERY_CODE_ATTEMPTS,
    })
    if (error) throw error

    const row = (data as ConsumedCodeRow[] | null)?.[0]
    return row ? { id: row.id, codeHash: row.code_hash } : null
  }

  // Devolve false se outro pedido já usou o código no meio do caminho
  async markUsed(id: string): Promise<boolean> {
    const { data, error } = await supabase
      .from("pin_recovery_codes")
      .update({ used_at: new Date().toISOString() })
      .eq("id", id)
      .is("used_at", null)
      .select("id")
    if (error) throw error
    return data.length > 0
  }
}

export default new PinRecoveryModel()
