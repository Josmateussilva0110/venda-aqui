import type { NextFunction, Request, Response } from "express"
import type { ZodType } from "zod"
import type { FieldError, HttpResponse } from "../types/http"

type RequestSource = "body" | "query" | "params"

export function validate(schema: ZodType, source: RequestSource = "body") {
  return (request: Request, response: Response, next: NextFunction) => {
    const result = schema.safeParse(request[source] ?? {})

    if (!result.success) {
      const errors: FieldError[] = result.error.issues.map((issue) => ({
        field: issue.path.join(".") || source,
        message: issue.message,
      }))
      const body: HttpResponse = { success: false, message: "Erro de validação", errors }
      return response.status(422).json(body)
    }

    // No Express 5 request.query é só getter; redefinir é o jeito de entregar a versão convertida
    Object.defineProperty(request, source, { value: result.data, writable: true, enumerable: true, configurable: true })
    return next()
  }
}
