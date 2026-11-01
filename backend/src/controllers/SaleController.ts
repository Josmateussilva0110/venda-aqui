import type { Request, Response } from "express"
import { saleErrorHttpStatusMap } from "../errors/sales"
import type { ListSalesDTO } from "../schemas/sales/listSales"
import type { SaleDTO } from "../schemas/sales/sale"
import type { SaleParamsDTO } from "../schemas/sales/saleParams"
import SaleService from "../services/SaleService"
import { requireAuthField } from "../utils/requireAuthField"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"

class SaleController {

  async list(request: Request, response: Response): Promise<Response> {
    const result = await SaleService.list(requireAuthField(request, "merchantId"), request.query as unknown as ListSalesDTO)
    if (!result.status) return sendFailure(response, result.error, saleErrorHttpStatusMap)
    return sendSuccess(response, "Vendas carregadas.", result.data)
  }

  async get(request: Request<SaleParamsDTO>, response: Response): Promise<Response> {
    const result = await SaleService.get(requireAuthField(request, "merchantId"), request.params.id)
    if (!result.status) return sendFailure(response, result.error, saleErrorHttpStatusMap)
    return sendSuccess(response, "Venda carregada.", result.data)
  }

  async create(request: Request<unknown, unknown, SaleDTO>, response: Response): Promise<Response> {
    const result = await SaleService.create(requireAuthField(request, "merchantId"), request.body)
    if (!result.status) return sendFailure(response, result.error, saleErrorHttpStatusMap)
    return sendSuccess(response, "Venda registrada com sucesso.", result.data, 201)
  }

  async update(request: Request<SaleParamsDTO, unknown, SaleDTO>, response: Response): Promise<Response> {
    const result = await SaleService.update(requireAuthField(request, "merchantId"), request.params.id, request.body)
    if (!result.status) return sendFailure(response, result.error, saleErrorHttpStatusMap)
    return sendSuccess(response, "Venda atualizada com sucesso.", result.data)
  }

}

export default new SaleController()
