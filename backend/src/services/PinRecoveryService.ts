import { RECOVERY_CODE_LENGTH, RECOVERY_CODE_TTL_MINUTES } from "../constants/auth"
import MerchantModel from "../models/MerchantModel"
import PinRecoveryModel from "../models/PinRecoveryModel"
import SessionModel from "../models/SessionModel"
import { whatsAppSender } from "../providers/whatsapp"
import type { PinRecoveryConfirmDTO } from "../schemas/auth/pinRecoveryConfirm"
import { AuthErrorCode, type AuthSession } from "../types/auth"
import type { ServiceResult } from "../types/serviceResult"
import { addMinutes } from "../utils/dates"
import { hashPin } from "../utils/pin"
import { generateNumericCode, hashSecret, secretMatchesHash } from "../utils/tokens"
import AuthService from "./AuthService"

type AuthResult<T> = Promise<ServiceResult<T, AuthErrorCode>>

const INVALID_CODE_ERROR = {
  code: AuthErrorCode.RECOVERY_CODE_INVALID,
  message: "Código inválido ou expirado. Peça um novo código.",
}

class PinRecoveryService {
  async requestCode(phone: string): AuthResult<void> {
    try {
      const merchant = await MerchantModel.findByPhone(phone)

      // Mesma resposta com ou sem conta: o endpoint não serve para descobrir números cadastrados
      if (!merchant) return { status: true, data: undefined }

      const code = generateNumericCode(RECOVERY_CODE_LENGTH)
      await PinRecoveryModel.create({
        merchantId: merchant.id,
        codeHash: hashSecret(code),
        expiresAt: addMinutes(new Date(), RECOVERY_CODE_TTL_MINUTES).toISOString(),
      })
      await whatsAppSender.sendRecoveryCode(merchant.phone, code)

      return { status: true, data: undefined }
    } catch (error) {
      console.error("[PinRecoveryService.requestCode] error:", error)
      return { status: false, error: { code: AuthErrorCode.RECOVERY_SEND_FAILED, message: "Não foi possível enviar o código. Tente novamente." } }
    }
  }

  async confirm(input: PinRecoveryConfirmDTO): AuthResult<AuthSession> {
    try {
      const merchant = await MerchantModel.findByPhone(input.phone)
      if (!merchant) return { status: false, error: INVALID_CODE_ERROR }

      const codeAccepted = await this.consumeCode(merchant.id, input.code)
      if (!codeAccepted) return { status: false, error: INVALID_CODE_ERROR }

      const pinHash = await hashPin(input.pin)
      // PIN trocado encerra todas as sessões: quem pediu a recuperação pode estar sem o aparelho antigo
      await Promise.all([MerchantModel.updatePin(merchant.id, pinHash), SessionModel.revokeAllForMerchant(merchant.id)])

      return AuthService.startSession(merchant, input.deviceId)
    } catch (error) {
      console.error("[PinRecoveryService.confirm] error:", error)
      return { status: false, error: { code: AuthErrorCode.RECOVERY_FAILED, message: "Erro ao redefinir o PIN." } }
    }
  }

  private async consumeCode(merchantId: string, code: string): Promise<boolean> {
    const activeCode = await PinRecoveryModel.consumeAttempt(merchantId)
    if (!activeCode || !secretMatchesHash(code, activeCode.codeHash)) return false
    return PinRecoveryModel.markUsed(activeCode.id)
  }
}

export default new PinRecoveryService()
