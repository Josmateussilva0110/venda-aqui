import type { NextFunction, Request, Response } from "express"
import type { HttpResponse } from "../types/http"
import { PortalErrorCode } from "../types/portal"
import { verifyPortalAccessToken } from "../utils/tokens"

// Só aceita token do portal: o do comerciante tem outro emissor e é recusado aqui, e vice-versa
export function portalAuthMiddleware(request: Request, response: Response, next: NextFunction) {
  const [scheme, token] = request.headers.authorization?.split(" ") ?? []
  const claims = scheme === "Bearer" && token ? verifyPortalAccessToken(token) : null

  if (!claims) {
    // Como no app do comerciante: este código pede só a renovação; PORTAL_SESSION_* pede o PIN de novo
    const body: HttpResponse = { success: false, message: "Acesso expirado ou ausente.", code: PortalErrorCode.ACCESS_TOKEN_INVALID }
    return response.status(401).json(body)
  }

  request.portalAccountId = claims.accountId
  request.portalSessionId = claims.sessionId
  return next()
}
