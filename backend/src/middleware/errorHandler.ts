import type { NextFunction, Request, Response } from "express"
import type { HttpResponse } from "../types/http"

interface HttpError {
  status?: number
  type?: string
}

export function errorHandler(error: unknown, _request: Request, response: Response, _next: NextFunction) {
  const { status, type } = (error ?? {}) as HttpError

  // Erros do body-parser chegam aqui com status 4xx e são culpa do cliente, não falha do servidor
  if (type === "entity.parse.failed") {
    return response.status(400).json({ success: false, message: "JSON inválido." } satisfies HttpResponse)
  }
  if (type === "entity.too.large") {
    return response.status(413).json({ success: false, message: "Requisição grande demais." } satisfies HttpResponse)
  }
  if (status && status >= 400 && status < 500) {
    return response.status(status).json({ success: false, message: "Requisição inválida." } satisfies HttpResponse)
  }

  console.error("[errorHandler]", error)
  return response.status(500).json({ success: false, message: "Erro interno. Tente novamente." } satisfies HttpResponse)
}
