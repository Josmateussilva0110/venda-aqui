import type { ServiceResult } from "../serviceResult"
import type { CustomerErrorCode } from "./errors"

export * from "./errors"
export * from "./row"

export type CustomerResult<T> = Promise<ServiceResult<T, CustomerErrorCode>>

export interface Customer {
  id: string
  name: string
  phone: string
  createdAt: string
  updatedAt: string
}

export interface CustomerList {
  items: Customer[]
  total: number
  limit: number
  offset: number
}
