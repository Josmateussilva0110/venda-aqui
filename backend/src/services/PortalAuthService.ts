import { ACCESS_TOKEN_TTL_SECONDS } from "../constants/auth"
import { PORTAL_REFRESH_TOKEN_TTL_DAYS } from "../constants/portal"
import {
  PORTAL_INVALID_CREDENTIALS_ERROR,
  PORTAL_LOGIN_FAILED_ERROR,
  PORTAL_LOGOUT_FAILED_ERROR,
  PORTAL_PIN_LOCKED_ERROR,
  PORTAL_REFRESH_FAILED_ERROR,
  PORTAL_SESSION_EXPIRED_ERROR,
  PORTAL_SESSION_INVALID_ERROR,
  PORTAL_SESSION_REVOKED_ERROR,
} from "../errors/portal"
import PortalAccountModel from "../models/PortalAccountModel"
import PortalSessionModel from "../models/PortalSessionModel"
import type { RefreshDTO } from "../schemas/auth/refresh"
import type { PortalLoginDTO } from "../schemas/portal/login"
import type { AuthTokens } from "../types/auth"
import type {
  PortalAccount,
  PortalAccountCredentials,
  PortalErrorCode,
  PortalResult,
  PortalSession,
  PortalSessionRecord,
} from "../types/portal"
import { addDays, isFuture, isPast } from "../utils/dates"
import { comparePin } from "../utils/pin"
import { generateRefreshToken, hashSecret, signPortalAccessToken } from "../utils/tokens"

class PortalAuthService {
  async login(input: PortalLoginDTO): PortalResult<PortalSession> {
    try {
      const credentials = await this.findCredentials(input)
      const rejection = await this.verifyPin(credentials, input.pin)
      // Sem conta o verifyPin já recusa; o "!credentials" aqui só estreita o tipo
      if (rejection || !credentials) return { status: false, error: rejection ?? PORTAL_INVALID_CREDENTIALS_ERROR }

      return this.startSession(credentials.account, input.deviceId)
    } catch (error) {
      console.error("[PortalAuthService.login] error:", error)
      return { status: false, error: PORTAL_LOGIN_FAILED_ERROR }
    }
  }

  async refresh(input: RefreshDTO): PortalResult<AuthTokens> {
    try {
      const currentHash = hashSecret(input.refreshToken)
      const session = await PortalSessionModel.findByRefreshTokenHash(currentHash)
      if (!session) return { status: false, error: PORTAL_SESSION_INVALID_ERROR }

      const rejection = await this.checkSessionUsable(session, input.deviceId)
      if (rejection) return { status: false, error: rejection }

      const refreshToken = generateRefreshToken()
      const refreshTokenExpiresAt = addDays(new Date(), PORTAL_REFRESH_TOKEN_TTL_DAYS).toISOString()
      const rotated = await PortalSessionModel.rotate({
        id: session.id,
        currentHash,
        newHash: hashSecret(refreshToken),
        expiresAt: refreshTokenExpiresAt,
      })
      if (!rotated) return { status: false, error: PORTAL_SESSION_INVALID_ERROR }

      return {
        status: true,
        data: {
          accessToken: signPortalAccessToken({ accountId: session.accountId, sessionId: session.id }),
          accessTokenExpiresIn: ACCESS_TOKEN_TTL_SECONDS,
          refreshToken,
          refreshTokenExpiresAt,
        },
      }
    } catch (error) {
      console.error("[PortalAuthService.refresh] error:", error)
      return { status: false, error: PORTAL_REFRESH_FAILED_ERROR }
    }
  }

  async logout(accountId: string, sessionId: string): PortalResult<void> {
    try {
      await PortalSessionModel.revoke(sessionId, accountId)
      return { status: true, data: undefined }
    } catch (error) {
      console.error("[PortalAuthService.logout] error:", error)
      return { status: false, error: PORTAL_LOGOUT_FAILED_ERROR }
    }
  }

  // Público porque aceitar o convite também termina com o cliente logado
  async startSession(account: PortalAccount, deviceId: string): PortalResult<PortalSession> {
    try {
      const refreshToken = generateRefreshToken()
      const refreshTokenExpiresAt = addDays(new Date(), PORTAL_REFRESH_TOKEN_TTL_DAYS).toISOString()
      const session = await PortalSessionModel.create({
        accountId: account.id,
        deviceId,
        refreshTokenHash: hashSecret(refreshToken),
        expiresAt: refreshTokenExpiresAt,
      })

      return {
        status: true,
        data: {
          account,
          accessToken: signPortalAccessToken({ accountId: account.id, sessionId: session.id }),
          accessTokenExpiresIn: ACCESS_TOKEN_TTL_SECONDS,
          refreshToken,
          refreshTokenExpiresAt,
        },
      }
    } catch (error) {
      console.error("[PortalAuthService.startSession] error:", error)
      return { status: false, error: PORTAL_LOGIN_FAILED_ERROR }
    }
  }

  // Confere o PIN com bloqueio por tentativas; devolve o motivo da recusa, ou null se o PIN confere.
  // Público porque ligar uma loja nova pelo convite também pede o PIN atual
  async verifyPin(
    credentials: PortalAccountCredentials | null,
    pin: string,
  ): Promise<{ code: PortalErrorCode; message: string } | null> {
    if (credentials && isFuture(credentials.pinLockedUntil)) return PORTAL_PIN_LOCKED_ERROR

    // Compara mesmo sem conta, para o tempo de resposta não revelar se o telefone ou CPF tem acesso
    const pinMatches = await comparePin(pin, credentials?.pinHash ?? null)
    if (!credentials) return PORTAL_INVALID_CREDENTIALS_ERROR

    if (!pinMatches) {
      const lockedUntil = await PortalAccountModel.registerFailedPinAttempt(credentials.account.id)
      return isFuture(lockedUntil) ? PORTAL_PIN_LOCKED_ERROR : PORTAL_INVALID_CREDENTIALS_ERROR
    }

    // Só grava quando há o que zerar: a maioria das entradas não teve erro antes
    if (credentials.failedPinAttempts > 0 || credentials.pinLockedUntil !== null) {
      await PortalAccountModel.resetFailedPinAttempts(credentials.account.id)
    }
    return null
  }

  private async findCredentials(input: PortalLoginDTO): Promise<PortalAccountCredentials | null> {
    if (input.method === "phone") return PortalAccountModel.findCredentialsByPhone(input.phone)

    // O CPF é digitado por cada comerciante, então pode apontar para mais de uma conta. Nesse caso
    // não há como saber qual é a da pessoa: a entrada pelo CPF é recusada e o telefone resolve
    const accountIds = await PortalAccountModel.findIdsByCpf(input.cpf)
    return accountIds.length === 1 ? PortalAccountModel.findCredentialsById(accountIds[0]!) : null
  }

  // Devolve o motivo da recusa, ou null se a sessão pode ser renovada
  private async checkSessionUsable(
    session: PortalSessionRecord,
    deviceId: string,
  ): Promise<{ code: PortalErrorCode; message: string } | null> {
    if (session.revokedAt) return PORTAL_SESSION_REVOKED_ERROR
    if (isPast(session.expiresAt)) return PORTAL_SESSION_EXPIRED_ERROR
    if (session.deviceId !== deviceId) {
      // Token de um aparelho usado em outro indica vazamento: encerra a sessão de origem também
      await PortalSessionModel.revoke(session.id, session.accountId)
      return PORTAL_SESSION_REVOKED_ERROR
    }
    return null
  }
}

export default new PortalAuthService()
