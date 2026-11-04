import type { Request, Response } from "express"
import { reportErrorHttpStatusMap } from "../errors/reports"
import type { ReportDTO } from "../schemas/reports/report"
import ReportService from "../services/ReportService"
import { requireAuthField } from "../utils/requireAuthField"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"

class ReportController {

  async sales(request: Request, response: Response): Promise<Response> {
    const result = await ReportService.sales(requireAuthField(request, "merchantId"), request.query as unknown as ReportDTO)
    if (!result.status) return sendFailure(response, result.error, reportErrorHttpStatusMap)
    return sendSuccess(response, "Relatório carregado.", result.data)
  }

}

export default new ReportController()
