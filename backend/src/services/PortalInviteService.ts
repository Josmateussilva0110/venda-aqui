import type { PostgrestError } from "@supabase/supabase-js"
import { env } from "../config/env"
import { supabase } from "../config/supabase"
import { PORTAL_DB_ERRORS, PORTAL_INVITE_TOKEN_BYTES, PORTAL_INVITE_TTL_HOURS } from "../constants/portal"
import {
  PORTAL_CUSTOMER_NOT_FOUND_ERROR,
  PORTAL_INVITE_ACCEPT_FAILED_ERROR,
  PORTAL_INVITE_CREATE_FAILED_ERROR,
  PORTAL_INVITE_FETCH_FAILED_ERROR,
  PORTAL_INVITE_INVALID_ERROR,
  PORTAL_INVITE_NEEDS_NEW_PIN_ERROR,
} from "../errors/portal"
import PortalAccountModel from "../models/PortalAccountModel"
import type { AcceptInviteDTO } from "../schemas/portal/acceptInvite"
import type {
  PortalErrorCode,
  PortalInviteCreated,
  PortalInviteInfo,
  PortalInviteInfoRow,
  PortalResult,
  PortalSession,
} from "../types/portal"
import { addMinutes } from "../utils/dates"
import { hashPin } from "../utils/pin"
import { generateUrlToken, hashSecret } from "../utils/tokens"
import PortalAuthService from "./PortalAuthService"

class PortalInviteService {
  // Chamado pelo comerciante: o link volta para o app dele, que abre o WhatsApp com a mensagem pronta
  async create(merchantId: string, customerId: string): PortalResult<PortalInviteCreated> {
    try {
      const { data: customer, error: customerError } = await supabase
        .from("customers")
        .select("id, phone")
        .eq("id", customerId)
        .eq("merchant_id", merchantId)
        .maybeSingle<{ id: string; phone: string }>()
      if (customerError) {
        console.error("[PortalInviteService.create]", customerError)
        return { status: false, error: PORTAL_INVITE_CREATE_FAILED_ERROR }
      }
      if (!customer) return { status: false, error: PORTAL_CUSTOMER_NOT_FOUND_ERROR }

      // Link novo invalida os anteriores: só o último enviado vale, e um link esquecido no WhatsApp morre
      const { error: invalidateError } = await supabase
        .from("customer_portal_invites")
        .update({ used_at: new Date().toISOString() })
        .eq("merchant_id", merchantId)
        .eq("customer_id", customer.id)
        .is("used_at", null)
      if (invalidateError) throw invalidateError

      const token = generateUrlToken(PORTAL_INVITE_TOKEN_BYTES)
      const expiresAt = addMinutes(new Date(), PORTAL_INVITE_TTL_HOURS * 60).toISOString()
      const { error } = await supabase.from("customer_portal_invites").insert({
        merchant_id: merchantId,
        customer_id: customer.id,
        phone: customer.phone,
        token_hash: hashSecret(token),
        expires_at: expiresAt,
      })
      if (error) throw error

      return { status: true, data: { url: this.buildInviteUrl(token), expiresAt } }
    } catch (error) {
      console.error("[PortalInviteService.create] error:", error)
      return { status: false, error: PORTAL_INVITE_CREATE_FAILED_ERROR }
    }
  }

  // Não usa o convite: só diz à tela do link se ela pede o PIN atual ou a criação de um PIN
  async inspect(token: string): PortalResult<PortalInviteInfo> {
    try {
      const { data, error } = await supabase
        .rpc("customer_portal_invite_info", { p_token_hash: hashSecret(token) })
        .maybeSingle<PortalInviteInfoRow>()
      if (error) {
        console.error("[PortalInviteService.inspect]", error)
        return { status: false, error: PORTAL_INVITE_FETCH_FAILED_ERROR }
      }
      if (!data) return { status: false, error: PORTAL_INVITE_INVALID_ERROR }

      return {
        status: true,
        data: { merchantName: data.merchant_name, phoneEnding: data.phone.slice(-4), hasAccount: data.has_account },
      }
    } catch (error) {
      console.error("[PortalInviteService.inspect] error:", error)
      return { status: false, error: PORTAL_INVITE_FETCH_FAILED_ERROR }
    }
  }

  async accept(input: AcceptInviteDTO): PortalResult<PortalSession> {
    try {
      const tokenHash = hashSecret(input.token)

      if (input.currentPin !== undefined) {
        const rejection = await this.verifyCurrentPin(tokenHash, input.currentPin)
        if (rejection) return { status: false, error: rejection }
      }

      const newPinHash = input.newPin !== undefined ? await hashPin(input.newPin) : null
      const { data: accountId, error } = await supabase.rpc("redeem_customer_portal_invite", {
        p_token_hash: tokenHash,
        p_new_pin_hash: newPinHash,
      })

      const ruleError = this.mapRedeemError(error)
      if (ruleError) return { status: false, error: ruleError }
      if (error || typeof accountId !== "string") {
        console.error("[PortalInviteService.accept]", error)
        return { status: false, error: PORTAL_INVITE_ACCEPT_FAILED_ERROR }
      }

      const credentials = await PortalAccountModel.findCredentialsById(accountId)
      if (!credentials) return { status: false, error: PORTAL_INVITE_ACCEPT_FAILED_ERROR }

      return PortalAuthService.startSession(credentials.account, input.deviceId)
    } catch (error) {
      console.error("[PortalInviteService.accept] error:", error)
      return { status: false, error: PORTAL_INVITE_ACCEPT_FAILED_ERROR }
    }
  }

  // Ligar a loja a uma conta existente sem trocar o PIN exige saber o PIN dela: o comerciante, que vê
  // o link, não pode usá-lo para entrar na conta de alguém e ver as outras lojas
  private async verifyCurrentPin(tokenHash: string, pin: string): Promise<{ code: PortalErrorCode; message: string } | null> {
    const { data: invite, error } = await supabase
      .rpc("customer_portal_invite_info", { p_token_hash: tokenHash })
      .maybeSingle<PortalInviteInfoRow>()
    if (error) throw error
    if (!invite) return PORTAL_INVITE_INVALID_ERROR
    if (!invite.has_account) return PORTAL_INVITE_NEEDS_NEW_PIN_ERROR

    const credentials = await PortalAccountModel.findCredentialsByPhone(invite.phone)
    return PortalAuthService.verifyPin(credentials, pin)
  }

  // Erros de regra da função não são falha do servidor: viram resposta normal, sem log de erro
  private mapRedeemError(error: PostgrestError | null): { code: PortalErrorCode; message: string } | null {
    if (error?.code === PORTAL_DB_ERRORS.inviteInvalid) return PORTAL_INVITE_INVALID_ERROR
    if (error?.code === PORTAL_DB_ERRORS.accountMissing) return PORTAL_INVITE_NEEDS_NEW_PIN_ERROR
    return null
  }

  private buildInviteUrl(token: string): string {
    return `${env.CUSTOMER_INVITE_BASE_URL}?token=${token}`
  }
}

export default new PortalInviteService()
