import type { Request, Response } from "express"
import { customerErrorHttpStatusMap } from "../errors/customers"
import type { CustomerDTO } from "../schemas/customers/customer"
import type { CustomerParamsDTO } from "../schemas/customers/customerParams"
import type { ListCustomersDTO } from "../schemas/customers/listCustomers"
import CustomerService from "../services/CustomerService"
import { requireAuthField } from "../utils/requireAuthField"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"

class CustomerController {

  async list(request: Request, response: Response): Promise<Response> {
    const result = await CustomerService.list(requireAuthField(request, "merchantId"), request.query as unknown as ListCustomersDTO)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Clientes carregados.", result.data)
  }

  async get(request: Request<CustomerParamsDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.get(requireAuthField(request, "merchantId"), request.params.id)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Cliente carregado.", result.data)
  }

  async create(request: Request<unknown, unknown, CustomerDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.create(requireAuthField(request, "merchantId"), request.body)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Cliente cadastrado com sucesso.", result.data, 201)
  }

  async update(request: Request<CustomerParamsDTO, unknown, CustomerDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.update(requireAuthField(request, "merchantId"), request.params.id, request.body)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Cliente atualizado com sucesso.", result.data)
  }

  async delete(request: Request<CustomerParamsDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.delete(requireAuthField(request, "merchantId"), request.params.id)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Cliente excluído com sucesso.", result.data)
  }

}

export default new CustomerController()
