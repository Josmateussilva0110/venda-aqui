import type { Request, Response } from "express"
import { customerErrorHttpStatusMap } from "../errors/customers"
import type { CustomerDTO } from "../schemas/customers/customer"
import type { ListCustomersDTO } from "../schemas/customers/listCustomers"
import CustomerService from "../services/CustomerService"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"
import { requireAuthField } from "../utils/requireAuthField"

class CustomerController {

  async list(request: Request, response: Response): Promise<Response> {
    const result = await CustomerService.list(requireAuthField(request, "merchantId"), request.query as unknown as ListCustomersDTO)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Clientes carregados.", result.data)
  }

  async create(request: Request<unknown, unknown, CustomerDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.create(requireAuthField(request, "merchantId"), request.body)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Cliente cadastrado com sucesso.", result.data, 201)
  }

}

export default new CustomerController()
