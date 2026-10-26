export const ACCESS_TOKEN_TTL_SECONDS = 15 * 60
// Sessão longa e renovada a cada uso: o comerciante só digita o PIN de novo
// depois de logout ou ao entrar em outro aparelho
export const REFRESH_TOKEN_TTL_DAYS = 90

export const BCRYPT_ROUNDS = 10
export const MAX_FAILED_PIN_ATTEMPTS = 5
export const PIN_LOCK_MINUTES = 15

export const RECOVERY_CODE_LENGTH = 6
export const RECOVERY_CODE_TTL_MINUTES = 10
export const MAX_RECOVERY_CODE_ATTEMPTS = 5
