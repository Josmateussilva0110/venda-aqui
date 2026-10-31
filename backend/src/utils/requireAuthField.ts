import type { Request } from "express"

type AuthField = "merchantId" | "sessionId"

// Os campos só existem depois do authMiddleware; faltar aqui é rota montada sem ele, não erro do cliente.
// Lançar faz o Express 5 levar ao errorHandler (500 + log) em vez de seguir com undefined.
export function requireAuthField(request: Pick<Request, AuthField | "method" | "originalUrl">, field: AuthField): string {
  const value = request[field]
  if (!value) {
    throw new Error(`${field} ausente em ${request.method} ${request.originalUrl}: rota sem authMiddleware`)
  }
  return value
}
