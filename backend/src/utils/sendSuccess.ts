import type { Response } from "express"
import type { HttpResponse } from "../types/http"

export function sendSuccess<T>(response: Response, message: string, data?: T, status = 200): Response {
  const body: HttpResponse<T> = { success: true, message, data }
  return response.status(status).json(body)
}
