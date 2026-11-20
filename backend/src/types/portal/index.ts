import type { AuthTokens } from "../auth"
import type { ServiceResult } from "../serviceResult"
import type { PortalErrorCode } from "./errors"

export * from "./errors"
export * from "./row"

export type PortalResult<T> = Promise<ServiceResult<T, PortalErrorCode>>

export interface PortalAccount {
  id: string
  phone: string
}

export interface PortalAccountCredentials {
  account: PortalAccount
  pinHash: string
  failedPinAttempts: number
  pinLockedUntil: string | null
}

export interface PortalSessionRecord {
  id: string
  accountId: string
  deviceId: string
  expiresAt: string
  revokedAt: string | null
}

export interface PortalSession extends AuthTokens {
  account: PortalAccount
}

// O comerciante coloca o link na mensagem do WhatsApp
export interface PortalInviteCreated {
  url: string
  expiresAt: string
}

// O que a tela do link mostra antes de pedir o PIN
export interface PortalInviteInfo {
  merchantName: string
  // Só os 4 últimos dígitos, para o cliente reconhecer o número sem o link expor o telefone inteiro
  phoneEnding: string
  // true: pedir o PIN atual (ou "esqueci", que cria um novo); false: criar o PIN
  hasAccount: boolean
}

// Cadastro do cliente numa loja ligada à conta
export interface PortalStore {
  // id do cadastro na loja; é o que o extrato recebe
  id: string
  merchantName: string
  customerName: string
  balanceCents: number
  creditDueDate: string | null
}
