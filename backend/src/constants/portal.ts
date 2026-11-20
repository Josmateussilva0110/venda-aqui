// Link do convite: vida curta porque o comerciante vê o link, e uso único
export const PORTAL_INVITE_TTL_HOURS = 24
// 32 bytes aleatórios: o token vai na URL, então precisa de entropia alta para não ser adivinhado
export const PORTAL_INVITE_TOKEN_BYTES = 32

// Sessão do cliente mais curta que a do comerciante: ele consulta de vez em quando, muitas vezes num navegador
export const PORTAL_REFRESH_TOKEN_TTL_DAYS = 30

// SQLSTATE próprios das funções do portal (migration 20261120000000_customer_portal.sql)
export const PORTAL_DB_ERRORS = {
  inviteInvalid: "VQ009",
  accountMissing: "VQ010",
} as const
