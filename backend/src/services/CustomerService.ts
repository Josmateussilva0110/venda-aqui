import { supabase } from "../config/supabase"
import { CUSTOMER_COLUMNS } from "../constants/columns"
import {
  CUSTOMER_CREATE_FAILED_ERROR,
  CUSTOMER_DELETE_FAILED_ERROR,
  CUSTOMER_FETCH_FAILED_ERROR,
  CUSTOMER_LIST_FAILED_ERROR,
  CUSTOMER_NOT_FOUND_ERROR,
  CUSTOMER_PHONE_TAKEN_ERROR,
  CUSTOMER_UPDATE_FAILED_ERROR,
} from "../errors/customers"
import type { CustomerDTO } from "../schemas/customers/customer"
import type { ListCustomersDTO } from "../schemas/customers/listCustomers"
import type { Customer, CustomerList, CustomerResult, CustomerRow } from "../types/customers"
import { escapeLikePattern, isUniqueViolation } from "../utils/database"

class CustomerService {

  async list(merchantId: string, filters: ListCustomersDTO): CustomerResult<CustomerList> {
    try {
      let query = supabase
        .from("customers")
        .select(CUSTOMER_COLUMNS, { count: "exact" })
        .eq("merchant_id", merchantId)

      if (filters.search) {
        const phoneDigits = this.phoneDigitsOf(filters.search)
        query = phoneDigits
          ? query.ilike("phone", `%${phoneDigits}%`)
          : query.ilike("name", `%${escapeLikePattern(filters.search)}%`)
      }

      // O id desempata nomes iguais, senão um cliente pode repetir ou sumir entre as páginas
      const { data, count, error } = await query
        .order("name", { ascending: true })
        .order("id", { ascending: true })
        .range(filters.offset, filters.offset + filters.limit - 1)
        .returns<CustomerRow[]>()

      if (error) {
        console.error("[CustomerService.list]", error)
        return { status: false, error: CUSTOMER_LIST_FAILED_ERROR }
      }

      return {
        status: true,
        data: {
          items: data.map((row) => this.toCustomer(row)),
          total: count ?? 0,
          limit: filters.limit,
          offset: filters.offset,
        },
      }
    } catch (error) {
      console.error("[CustomerService.list] error:", error)
      return { status: false, error: CUSTOMER_LIST_FAILED_ERROR }
    }
  }

  async get(merchantId: string, customerId: string): CustomerResult<Customer> {
    try {
      const { data, error } = await supabase
        .from("customers")
        .select(CUSTOMER_COLUMNS)
        .eq("id", customerId)
        .eq("merchant_id", merchantId)
        .maybeSingle<CustomerRow>()

      if (error) {
        console.error("[CustomerService.get]", error)
        return { status: false, error: CUSTOMER_FETCH_FAILED_ERROR }
      }
      if (!data) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }

      return { status: true, data: this.toCustomer(data) }
    } catch (error) {
      console.error("[CustomerService.get] error:", error)
      return { status: false, error: CUSTOMER_FETCH_FAILED_ERROR }
    }
  }

  async create(merchantId: string, input: CustomerDTO): CustomerResult<{ id: string }> {
    try {
      const { data, error } = await supabase
        .from("customers")
        .insert({ merchant_id: merchantId, ...this.toRow(input) })
        .select("id")
        .single<{ id: string }>()

      if (isUniqueViolation(error)) return { status: false, error: CUSTOMER_PHONE_TAKEN_ERROR }
      if (error || !data) {
        console.error("[CustomerService.create]", error)
        return { status: false, error: CUSTOMER_CREATE_FAILED_ERROR }
      }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[CustomerService.create] error:", error)
      return { status: false, error: CUSTOMER_CREATE_FAILED_ERROR }
    }
  }

  async update(merchantId: string, customerId: string, input: CustomerDTO): CustomerResult<{ id: string }> {
    try {
      const { data, error } = await supabase
        .from("customers")
        .update(this.toRow(input))
        .eq("id", customerId)
        .eq("merchant_id", merchantId)
        .select("id")
        .maybeSingle<{ id: string }>()

      if (isUniqueViolation(error)) return { status: false, error: CUSTOMER_PHONE_TAKEN_ERROR }
      if (error) {
        console.error("[CustomerService.update]", error)
        return { status: false, error: CUSTOMER_UPDATE_FAILED_ERROR }
      }
      if (!data) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[CustomerService.update] error:", error)
      return { status: false, error: CUSTOMER_UPDATE_FAILED_ERROR }
    }
  }

  async delete(merchantId: string, customerId: string): CustomerResult<{ id: string }> {
    try {
      // O filtro pelo comerciante garante que um id de outro comércio não apaga nada (vira 404)
      const { data, error } = await supabase
        .from("customers")
        .delete()
        .eq("id", customerId)
        .eq("merchant_id", merchantId)
        .select("id")
        .maybeSingle<{ id: string }>()

      if (error) {
        console.error("[CustomerService.delete]", error)
        return { status: false, error: CUSTOMER_DELETE_FAILED_ERROR }
      }
      if (!data) return { status: false, error: CUSTOMER_NOT_FOUND_ERROR }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[CustomerService.delete] error:", error)
      return { status: false, error: CUSTOMER_DELETE_FAILED_ERROR }
    }
  }

  // Busca só com dígitos e pontuação de telefone ("(86) 9999-") procura no telefone; o resto, no nome.
  // Decidir aqui evita montar um filtro .or() com texto do cliente, que o PostgREST interpretaria
  private phoneDigitsOf(search: string): string | null {
    if (!/^[\d\s()+-]+$/.test(search)) return null
    const digits = search.replace(/\D/g, "")
    return digits.length > 0 ? digits : null
  }

  private toRow(input: CustomerDTO) {
    return {
      name: input.name,
      phone: input.phone,
    }
  }

  private toCustomer(row: CustomerRow): Customer {
    return {
      id: row.id,
      name: row.name,
      phone: row.phone,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    }
  }
}

export default new CustomerService()
