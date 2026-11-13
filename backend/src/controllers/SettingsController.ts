import type { Request, Response } from "express"
import { settingsErrorHttpStatusMap } from "../errors/settings"
import type { CreditSettingsDTO } from "../schemas/settings/creditSettings"
import SettingsService from "../services/SettingsService"
import { requireAuthField } from "../utils/requireAuthField"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"

class SettingsController {

  async getCredit(request: Request, response: Response): Promise<Response> {
    const result = await SettingsService.getCredit(requireAuthField(request, "merchantId"))
    if (!result.status) return sendFailure(response, result.error, settingsErrorHttpStatusMap)
    return sendSuccess(response, "Configurações do fiado carregadas.", result.data)
  }

  async updateCredit(request: Request<unknown, unknown, CreditSettingsDTO>, response: Response): Promise<Response> {
    const result = await SettingsService.updateCredit(requireAuthField(request, "merchantId"), request.body)
    if (!result.status) return sendFailure(response, result.error, settingsErrorHttpStatusMap)
    return sendSuccess(response, "Configurações do fiado salvas.", result.data)
  }

}

export default new SettingsController()
