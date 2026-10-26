import { rateLimit } from "express-rate-limit"
import type { HttpResponse } from "../types/http"

function limiter(windowMinutes: number, limit: number, skipSuccessfulRequests: boolean) {
  const body: HttpResponse = { success: false, message: "Muitas tentativas. Aguarde alguns minutos e tente de novo." }

  return rateLimit({
    windowMs: windowMinutes * 60 * 1000,
    limit,
    skipSuccessfulRequests,
    standardHeaders: "draft-8",
    legacyHeaders: false,
    message: body,
  })
}

// Só falhas contam, para não punir quem acerta o PIN. O bloqueio por conta
// (MAX_FAILED_PIN_ATTEMPTS) cobre o ataque distribuído entre vários IPs.
export const loginRateLimiter = limiter(15, 10, true)
export const registerRateLimiter = limiter(60, 10, false)
export const phoneCheckRateLimiter = limiter(15, 30, false)
export const refreshRateLimiter = limiter(15, 60, true)
// Cada pedido dispara uma mensagem paga no WhatsApp
export const pinRecoveryRequestRateLimiter = limiter(60, 5, false)
export const pinRecoveryConfirmRateLimiter = limiter(15, 10, true)
