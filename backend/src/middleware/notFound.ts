import type { Request, Response } from "express"
import type { HttpResponse } from "../types/http"

export function notFound(_request: Request, response: Response) {
  const body: HttpResponse = { success: false, message: "Rota não encontrada." }
  return response.status(404).json(body)
}
