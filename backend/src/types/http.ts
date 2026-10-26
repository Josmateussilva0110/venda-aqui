export interface FieldError {
  field: string
  message: string
}

export interface HttpResponse<T = unknown> {
  success: boolean
  message: string
  code?: string
  data?: T
  errors?: FieldError[]
}
