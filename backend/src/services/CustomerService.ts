import { supabase } from "../config/supabase"
import { CUSTOMER_PHONE_TAKEN_ERROR } from "../errors/customers"
import type { CustomerDTO } from "../schemas/customers/customer"
import { CustomerErrorCode, type CustomerResult } from "../types/customers"
import { isUniqueViolation } from "../utils/database"

class CustomerService {

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
        return { status: false, error: { code: CustomerErrorCode.CUSTOMER_CREATE_FAILED, message: "Erro ao cadastrar o cliente." } }
      }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[CustomerService.create] error:", error)
      return { status: false, error: { code: CustomerErrorCode.CUSTOMER_CREATE_FAILED, message: "Erro ao cadastrar o cliente." } }
    }
  }

  private toRow(input: CustomerDTO) {
    return {
      name: input.name,
      phone: input.phone
    }
  }
}

export default new CustomerService()
