import { AuthErrorCode } from "../types/auth"

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
