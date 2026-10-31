import type { ServiceResult } from "../serviceResult"
import type { AuthErrorCode } from "./errors"

export * from "./errors"

export type AuthResult<T> = Promise<ServiceResult<T, AuthErrorCode>>

export interface Merchant {
  id: string
  name: string
  phone: string
  createdAt: string
}

export interface AuthTokens {
  accessToken: string
  accessTokenExpiresIn: number
  refreshToken: string
  refreshTokenExpiresAt: string
}

export interface AuthSession extends AuthTokens {
  merchant: Merchant
}

export interface PhoneAvailability {
  available: boolean
}
