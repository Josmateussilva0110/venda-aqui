import { PIN_LOCK_MINUTES } from "../constants/auth"
import { AuthErrorCode } from "../types/auth"

export const INVALID_CREDENTIALS_MESSAGE = "Telefone ou PIN incorretos."
export const PIN_LOCKED_MESSAGE = `PIN bloqueado por muitas tentativas. Tente de novo em ${PIN_LOCK_MINUTES} minutos ou recupere o PIN pelo WhatsApp.`

export const INVALID_CODE_ERROR = {
  code: AuthErrorCode.RECOVERY_CODE_INVALID,
  message: "Código inválido ou expirado. Peça um novo código.",
}

export const authErrorHttpStatusMap: Record<AuthErrorCode, number> = {
  [AuthErrorCode.PHONE_ALREADY_REGISTERED]: 409,
  [AuthErrorCode.INVALID_CREDENTIALS]: 401,
  [AuthErrorCode.PIN_LOCKED]: 429,
  [AuthErrorCode.ACCESS_TOKEN_INVALID]: 401,
  [AuthErrorCode.SESSION_INVALID]: 401,
  [AuthErrorCode.SESSION_EXPIRED]: 401,
  [AuthErrorCode.SESSION_REVOKED]: 401,
  [AuthErrorCode.MERCHANT_NOT_FOUND]: 404,
  [AuthErrorCode.RECOVERY_CODE_INVALID]: 400,
  [AuthErrorCode.RECOVERY_SEND_FAILED]: 502,
  [AuthErrorCode.REGISTER_FAILED]: 500,
  [AuthErrorCode.LOGIN_FAILED]: 500,
  [AuthErrorCode.REFRESH_FAILED]: 500,
  [AuthErrorCode.LOGOUT_FAILED]: 500,
  [AuthErrorCode.PHONE_CHECK_FAILED]: 500,
  [AuthErrorCode.PROFILE_FAILED]: 500,
  [AuthErrorCode.RECOVERY_FAILED]: 500,
}
