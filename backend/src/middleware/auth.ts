import type { NextFunction, Request, Response } from "express"
import type { HttpResponse } from "../types/http"
import { AuthErrorCode } from "../types/auth"
import { verifyAccessToken } from "../utils/tokens"

export function authMiddleware(request: Request, response: Response, next: NextFunction) {
  const [scheme, token] = request.headers.authorization?.split(" ") ?? []
  const claims = scheme === "Bearer" && token ? verifyAccessToken(token) : null

  if (!claims) {
    // Código distinto dos de sessão: aqui o app só precisa renovar com o refresh token,
    // enquanto SESSION_* significa que a sessão acabou e é preciso pedir o PIN de novo
    const body: HttpResponse = { success: false, message: "Acesso expirado ou ausente.", code: AuthErrorCode.ACCESS_TOKEN_INVALID }
    return response.status(401).json(body)
  }

  request.merchantId = claims.merchantId
  request.sessionId = claims.sessionId
  return next()
}
