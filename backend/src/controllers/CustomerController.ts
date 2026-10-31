import type { Request, Response } from "express"
import { customerErrorHttpStatusMap } from "../errors/customers"
import type { CustomerDTO } from "../schemas/customers/customer"
import CustomerService from "../services/CustomerService"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"

class CustomerController {

  async create(request: Request<unknown, unknown, CustomerDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.create(request.merchantId!, request.body)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Cliente cadastrado com sucesso.", result.data, 201)
  }

}

export default new CustomerController()
