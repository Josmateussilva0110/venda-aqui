import type { Request, Response } from "express"
import { customerErrorHttpStatusMap } from "../errors/customers"
import type { CustomerDTO } from "../schemas/customers/customer"
import type { CustomerParamsDTO } from "../schemas/customers/customerParams"
import type { DueDateDTO } from "../schemas/customers/dueDate"
import type { ListRemindersDTO } from "../schemas/customers/listReminders"
import type { ListCustomersDTO } from "../schemas/customers/listCustomers"
import type { PaymentDTO } from "../schemas/customers/payment"
import type { StatementDTO } from "../schemas/customers/statement"
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

  async statement(request: Request<CustomerParamsDTO>, response: Response): Promise<Response> {
    const filters = request.query as unknown as StatementDTO
    const result = await CustomerService.statement(requireAuthField(request, "merchantId"), request.params.id, filters)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Extrato carregado.", result.data)
  }

  async registerPayment(request: Request<CustomerParamsDTO, unknown, PaymentDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.registerPayment(requireAuthField(request, "merchantId"), request.params.id, request.body)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Pagamento registrado com sucesso.", result.data, 201)
  }

  async setDueDate(request: Request<CustomerParamsDTO, unknown, DueDateDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.setDueDate(requireAuthField(request, "merchantId"), request.params.id, request.body)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Vencimento atualizado com sucesso.", result.data)
  }

  async listReminders(request: Request, response: Response): Promise<Response> {
    const filters = request.query as unknown as ListRemindersDTO
    const result = await CustomerService.listReminders(requireAuthField(request, "merchantId"), filters)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Lembretes carregados.", result.data)
  }

  async openAccount(request: Request<CustomerParamsDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.openAccount(requireAuthField(request, "merchantId"), request.params.id)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Conta em aberto carregada.", result.data)
  }

  async markReminded(request: Request<CustomerParamsDTO>, response: Response): Promise<Response> {
    const result = await CustomerService.markReminded(requireAuthField(request, "merchantId"), request.params.id)
    if (!result.status) return sendFailure(response, result.error, customerErrorHttpStatusMap)
    return sendSuccess(response, "Lembrete registrado.", result.data, 201)
  }

}

export default new CustomerController()
