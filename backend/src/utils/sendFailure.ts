import type { Response } from "express"
import { getHttpStatusFromError } from "../errors/httpStatus"
import type { HttpResponse } from "../types/http"

// O genérico amarra o código ao mapa do mesmo domínio: passar o mapa de outro não compila
export function sendFailure<E extends string>(
  response: Response,
  error: { code: E; message?: string },
  statusMap: Record<E, number>,
): Response {
  const body: HttpResponse = {
    success: false,
    message: error.message ?? "Não foi possível concluir a operação.",
    code: error.code,
  }

  return response.status(getHttpStatusFromError(error.code, statusMap)).json(body)
}
