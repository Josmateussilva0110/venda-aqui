import type { Request, Response } from "express"
import { authErrorHttpStatusMap } from "../errors/auth"
import type { CheckPhoneDTO } from "../schemas/auth/checkPhone"
import type { LoginDTO } from "../schemas/auth/login"
import type { PinRecoveryConfirmDTO } from "../schemas/auth/pinRecoveryConfirm"
import type { PinRecoveryRequestDTO } from "../schemas/auth/pinRecoveryRequest"
import type { RefreshDTO } from "../schemas/auth/refresh"
import type { RegisterDTO } from "../schemas/auth/register"
import AuthService from "../services/AuthService"
import PinRecoveryService from "../services/PinRecoveryService"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"
import { requireAuthField } from "../utils/requireAuthField"

class AuthController {
  async checkPhone(request: Request<unknown, unknown, CheckPhoneDTO>, response: Response): Promise<Response> {
    const result = await AuthService.checkPhone(request.body.phone)
    if (!result.status) return sendFailure(response, result.error, authErrorHttpStatusMap)

    const message = result.data.available ? "Telefone disponível." : "Este telefone já tem cadastro."
    return sendSuccess(response, message, result.data)
  }

  async register(request: Request<unknown, unknown, RegisterDTO>, response: Response): Promise<Response> {
    const result = await AuthService.register(request.body)
    if (!result.status) return sendFailure(response, result.error, authErrorHttpStatusMap)
    return sendSuccess(response, "Conta criada com sucesso.", result.data, 201)
  }

  async login(request: Request<unknown, unknown, LoginDTO>, response: Response): Promise<Response> {
    const result = await AuthService.login(request.body)
    if (!result.status) return sendFailure(response, result.error, authErrorHttpStatusMap)
    return sendSuccess(response, "Login realizado com sucesso.", result.data)
  }

  async refresh(request: Request<unknown, unknown, RefreshDTO>, response: Response): Promise<Response> {
    const result = await AuthService.refresh(request.body)
    if (!result.status) return sendFailure(response, result.error, authErrorHttpStatusMap)
    return sendSuccess(response, "Sessão renovada.", result.data)
  }

  async logout(request: Request, response: Response): Promise<Response> {
    const result = await AuthService.logout(requireAuthField(request, "merchantId"), requireAuthField(request, "sessionId"))
    if (!result.status) return sendFailure(response, result.error, authErrorHttpStatusMap)
    return sendSuccess(response, "Você saiu da conta.")
  }

  async me(request: Request, response: Response): Promise<Response> {
    const result = await AuthService.getProfile(requireAuthField(request, "merchantId"))
    if (!result.status) return sendFailure(response, result.error, authErrorHttpStatusMap)
    return sendSuccess(response, "Dados da conta.", result.data)
  }

  async requestPinRecovery(request: Request<unknown, unknown, PinRecoveryRequestDTO>, response: Response): Promise<Response> {
    const result = await PinRecoveryService.requestCode(request.body.phone)
    if (!result.status) return sendFailure(response, result.error, authErrorHttpStatusMap)
    return sendSuccess(response, "Se o número tiver cadastro, você vai receber um código no WhatsApp.")
  }

  async confirmPinRecovery(request: Request<unknown, unknown, PinRecoveryConfirmDTO>, response: Response): Promise<Response> {
    const result = await PinRecoveryService.confirm(request.body)
    if (!result.status) return sendFailure(response, result.error, authErrorHttpStatusMap)
    return sendSuccess(response, "PIN redefinido com sucesso.", result.data)
  }
}

export default new AuthController()
