import { ACCESS_TOKEN_TTL_SECONDS, REFRESH_TOKEN_TTL_DAYS } from "../constants/auth"
import { INVALID_CREDENTIALS_MESSAGE, PIN_LOCKED_MESSAGE } from "../errors/auth"
import MerchantModel from "../models/MerchantModel"
import SessionModel, { type Session } from "../models/SessionModel"
import type { LoginDTO } from "../schemas/auth/login"
import type { RefreshDTO } from "../schemas/auth/refresh"
import type { RegisterDTO } from "../schemas/auth/register"
import { AuthErrorCode, type AuthResult, type AuthSession, type AuthTokens, type Merchant, type PhoneAvailability } from "../types/auth"
import { isUniqueViolation } from "../utils/database"
import { addDays, isFuture, isPast } from "../utils/dates"
import { comparePin, hashPin } from "../utils/pin"
import { generateRefreshToken, hashSecret, signAccessToken } from "../utils/tokens"

class AuthService {
  async checkPhone(phone: string): AuthResult<PhoneAvailability> {
    try {
      const exists = await MerchantModel.existsByPhone(phone)
      return { status: true, data: { available: !exists } }
    } catch (error) {
      console.error("[AuthService.checkPhone] error:", error)
      return { status: false, error: { code: AuthErrorCode.PHONE_CHECK_FAILED, message: "Erro ao verificar o telefone." } }
    }
  }

  async register(input: RegisterDTO): AuthResult<AuthSession> {
    try {
      const pinHash = await hashPin(input.pin)
      const merchant = await MerchantModel.create({ name: input.name, phone: input.phone, pinHash })
      // Cadastro termina já logado, sem pedir o PIN de novo
      return this.startSession(merchant, input.deviceId)
    } catch (error) {
      // A checagem da etapa 1 não impede dois cadastros simultâneos; a unique do banco impede
      if (isUniqueViolation(error)) {
        return { status: false, error: { code: AuthErrorCode.PHONE_ALREADY_REGISTERED, message: "Este telefone já tem cadastro." } }
      }
      console.error("[AuthService.register] error:", error)
      return { status: false, error: { code: AuthErrorCode.REGISTER_FAILED, message: "Erro ao criar a conta." } }
    }
  }

  async login(input: LoginDTO): AuthResult<AuthSession> {
    try {
      const credentials = await MerchantModel.findCredentialsByPhone(input.phone)

      if (credentials && isFuture(credentials.pinLockedUntil)) {
        return { status: false, error: { code: AuthErrorCode.PIN_LOCKED, message: PIN_LOCKED_MESSAGE } }
      }

      // Compara mesmo sem conta, para o tempo de resposta não revelar se o telefone existe
      const pinMatches = await comparePin(input.pin, credentials?.pinHash ?? null)

      if (!credentials) {
        return { status: false, error: { code: AuthErrorCode.INVALID_CREDENTIALS, message: INVALID_CREDENTIALS_MESSAGE } }
      }

      if (!pinMatches) {
        return this.rejectWrongPin(credentials.merchant.id)
      }

      // Só grava quando há o que zerar: a maioria dos logins não teve erro antes
      const hadFailures = credentials.failedPinAttempts > 0 || credentials.pinLockedUntil !== null
      const [session] = await Promise.all([
        this.startSession(credentials.merchant, input.deviceId),
        hadFailures ? MerchantModel.resetFailedPinAttempts(credentials.merchant.id) : undefined,
      ])
      return session
    } catch (error) {
      console.error("[AuthService.login] error:", error)
      return { status: false, error: { code: AuthErrorCode.LOGIN_FAILED, message: "Erro ao entrar. Tente novamente." } }
    }
  }

  async refresh(input: RefreshDTO): AuthResult<AuthTokens> {
    try {
      const currentHash = hashSecret(input.refreshToken)
      const session = await SessionModel.findByRefreshTokenHash(currentHash)

      if (!session) {
        return { status: false, error: { code: AuthErrorCode.SESSION_INVALID, message: "Sessão inválida. Entre novamente." } }
      }

      const rejection = await this.checkSessionUsable(session, input.deviceId)
      if (rejection) return { status: false, error: rejection }

      const refreshToken = generateRefreshToken()
      const refreshTokenExpiresAt = addDays(new Date(), REFRESH_TOKEN_TTL_DAYS).toISOString()
      const rotated = await SessionModel.rotate({
        id: session.id,
        currentHash,
        newHash: hashSecret(refreshToken),
        expiresAt: refreshTokenExpiresAt,
      })

      if (!rotated) {
        return { status: false, error: { code: AuthErrorCode.SESSION_INVALID, message: "Sessão inválida. Entre novamente." } }
      }

      return {
        status: true,
        data: {
          accessToken: signAccessToken({ merchantId: session.merchantId, sessionId: session.id }),
          accessTokenExpiresIn: ACCESS_TOKEN_TTL_SECONDS,
          refreshToken,
          refreshTokenExpiresAt,
        },
      }
    } catch (error) {
      console.error("[AuthService.refresh] error:", error)
      return { status: false, error: { code: AuthErrorCode.REFRESH_FAILED, message: "Erro ao renovar a sessão." } }
    }
  }

  async logout(merchantId: string, sessionId: string): AuthResult<void> {
    try {
      await SessionModel.revoke(sessionId, merchantId)
      return { status: true, data: undefined }
    } catch (error) {
      console.error("[AuthService.logout] error:", error)
      return { status: false, error: { code: AuthErrorCode.LOGOUT_FAILED, message: "Erro ao sair." } }
    }
  }

  async getProfile(merchantId: string): AuthResult<Merchant> {
    try {
      const merchant = await MerchantModel.findById(merchantId)

      if (!merchant) {
        return { status: false, error: { code: AuthErrorCode.MERCHANT_NOT_FOUND, message: "Conta não encontrada." } }
      }

      return { status: true, data: merchant }
    } catch (error) {
      console.error("[AuthService.getProfile] error:", error)
      return { status: false, error: { code: AuthErrorCode.PROFILE_FAILED, message: "Erro ao carregar os dados da conta." } }
    }
  }

  // Público porque a recuperação de PIN também termina com o comerciante logado
  async startSession(merchant: Merchant, deviceId: string): AuthResult<AuthSession> {
    try {
      const refreshToken = generateRefreshToken()
      const refreshTokenExpiresAt = addDays(new Date(), REFRESH_TOKEN_TTL_DAYS).toISOString()
      const session = await SessionModel.create({
        merchantId: merchant.id,
        deviceId,
        refreshTokenHash: hashSecret(refreshToken),
        expiresAt: refreshTokenExpiresAt,
      })

      return {
        status: true,
        data: {
          merchant,
          accessToken: signAccessToken({ merchantId: merchant.id, sessionId: session.id }),
          accessTokenExpiresIn: ACCESS_TOKEN_TTL_SECONDS,
          refreshToken,
          refreshTokenExpiresAt,
        },
      }
    } catch (error) {
      console.error("[AuthService.startSession] error:", error)
      return { status: false, error: { code: AuthErrorCode.LOGIN_FAILED, message: "Erro ao iniciar a sessão." } }
    }
  }

  private async rejectWrongPin(merchantId: string): AuthResult<AuthSession> {
    const lockedUntil = await MerchantModel.registerFailedPinAttempt(merchantId)

    if (isFuture(lockedUntil)) {
      return { status: false, error: { code: AuthErrorCode.PIN_LOCKED, message: PIN_LOCKED_MESSAGE } }
    }
    return { status: false, error: { code: AuthErrorCode.INVALID_CREDENTIALS, message: INVALID_CREDENTIALS_MESSAGE } }
  }

  // Devolve o motivo da recusa, ou null se a sessão pode ser renovada
  private async checkSessionUsable(
    session: Session,
    deviceId: string,
  ): Promise<{ code: AuthErrorCode; message: string } | null> {
    if (session.revokedAt) {
      return { code: AuthErrorCode.SESSION_REVOKED, message: "Sessão encerrada. Entre novamente." }
    }
    if (isPast(session.expiresAt)) {
      return { code: AuthErrorCode.SESSION_EXPIRED, message: "Sessão expirada. Entre novamente." }
    }
    if (session.deviceId !== deviceId) {
      // Token de um aparelho usado em outro indica vazamento: encerra a sessão de origem também
      await SessionModel.revoke(session.id, session.merchantId)
      return { code: AuthErrorCode.SESSION_REVOKED, message: "Sessão encerrada. Entre novamente." }
    }
    return null
  }
}

export default new AuthService()
