import { PIN_LOCK_MINUTES } from "../constants/auth"
import { PortalErrorCode } from "../types/portal"

export const PORTAL_CUSTOMER_NOT_FOUND_ERROR = { code: PortalErrorCode.CUSTOMER_NOT_FOUND, message: "Cliente não encontrado." }
export const PORTAL_INVITE_INVALID_ERROR = {
  code: PortalErrorCode.INVITE_INVALID,
  message: "Este link não vale mais. Peça um link novo para a loja.",
}
export const PORTAL_INVITE_NEEDS_NEW_PIN_ERROR = {
  code: PortalErrorCode.INVITE_NEEDS_NEW_PIN,
  message: "Você ainda não tem acesso. Crie um PIN para continuar.",
}
export const PORTAL_INVALID_CREDENTIALS_ERROR = {
  code: PortalErrorCode.INVALID_CREDENTIALS,
  message: "Telefone, CPF ou PIN incorretos.",
}
export const PORTAL_PIN_LOCKED_ERROR = {
  code: PortalErrorCode.PIN_LOCKED,
  message: `PIN bloqueado por muitas tentativas. Tente de novo em ${PIN_LOCK_MINUTES} minutos ou peça um link novo para a loja.`,
}
export const PORTAL_SESSION_INVALID_ERROR = { code: PortalErrorCode.SESSION_INVALID, message: "Sessão inválida. Entre novamente." }
export const PORTAL_SESSION_EXPIRED_ERROR = { code: PortalErrorCode.SESSION_EXPIRED, message: "Sessão expirada. Entre novamente." }
export const PORTAL_SESSION_REVOKED_ERROR = { code: PortalErrorCode.SESSION_REVOKED, message: "Sessão encerrada. Entre novamente." }
export const PORTAL_STORE_NOT_FOUND_ERROR = { code: PortalErrorCode.STORE_NOT_FOUND, message: "Loja não encontrada." }
export const PORTAL_INVITE_CREATE_FAILED_ERROR = { code: PortalErrorCode.INVITE_CREATE_FAILED, message: "Erro ao gerar o link de acesso." }
export const PORTAL_INVITE_FETCH_FAILED_ERROR = { code: PortalErrorCode.INVITE_FETCH_FAILED, message: "Erro ao abrir o link." }
export const PORTAL_INVITE_ACCEPT_FAILED_ERROR = { code: PortalErrorCode.INVITE_ACCEPT_FAILED, message: "Erro ao liberar o acesso." }
export const PORTAL_LOGIN_FAILED_ERROR = { code: PortalErrorCode.LOGIN_FAILED, message: "Erro ao entrar. Tente novamente." }
export const PORTAL_REFRESH_FAILED_ERROR = { code: PortalErrorCode.REFRESH_FAILED, message: "Erro ao renovar a sessão." }
export const PORTAL_LOGOUT_FAILED_ERROR = { code: PortalErrorCode.LOGOUT_FAILED, message: "Erro ao sair." }
export const PORTAL_STORES_FAILED_ERROR = { code: PortalErrorCode.STORES_FAILED, message: "Erro ao carregar as lojas." }
export const PORTAL_STATEMENT_FAILED_ERROR = { code: PortalErrorCode.STATEMENT_FAILED, message: "Erro ao carregar as movimentações." }

export const portalErrorHttpStatusMap: Record<PortalErrorCode, number> = {
  [PortalErrorCode.CUSTOMER_NOT_FOUND]: 404,
  [PortalErrorCode.INVITE_INVALID]: 410,
  [PortalErrorCode.INVITE_NEEDS_NEW_PIN]: 409,
  [PortalErrorCode.INVALID_CREDENTIALS]: 401,
  [PortalErrorCode.PIN_LOCKED]: 429,
  [PortalErrorCode.ACCESS_TOKEN_INVALID]: 401,
  [PortalErrorCode.SESSION_INVALID]: 401,
  [PortalErrorCode.SESSION_EXPIRED]: 401,
  [PortalErrorCode.SESSION_REVOKED]: 401,
  [PortalErrorCode.STORE_NOT_FOUND]: 404,
  [PortalErrorCode.INVITE_CREATE_FAILED]: 500,
  [PortalErrorCode.INVITE_FETCH_FAILED]: 500,
  [PortalErrorCode.INVITE_ACCEPT_FAILED]: 500,
  [PortalErrorCode.LOGIN_FAILED]: 500,
  [PortalErrorCode.REFRESH_FAILED]: 500,
  [PortalErrorCode.LOGOUT_FAILED]: 500,
  [PortalErrorCode.STORES_FAILED]: 500,
  [PortalErrorCode.STATEMENT_FAILED]: 500,
}
