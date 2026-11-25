import type { Request, Response } from "express"
import { portalErrorHttpStatusMap } from "../errors/portal"
import type { RefreshDTO } from "../schemas/auth/refresh"
import type { StatementDTO } from "../schemas/customers/statement"
import type { AcceptInviteDTO } from "../schemas/portal/acceptInvite"
import type { InviteTokenDTO } from "../schemas/portal/inviteToken"
import type { PortalLoginDTO } from "../schemas/portal/login"
import type { StoreParamsDTO } from "../schemas/portal/storeParams"
import PortalAuthService from "../services/PortalAuthService"
import PortalInviteService from "../services/PortalInviteService"
import PortalService from "../services/PortalService"
import { requireAuthField } from "../utils/requireAuthField"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"

class PortalController {
  async inspectInvite(request: Request<unknown, unknown, InviteTokenDTO>, response: Response): Promise<Response> {
    const result = await PortalInviteService.inspect(request.body.token)
    if (!result.status) return sendFailure(response, result.error, portalErrorHttpStatusMap)
    return sendSuccess(response, "Link válido.", result.data)
  }

  async acceptInvite(request: Request<unknown, unknown, AcceptInviteDTO>, response: Response): Promise<Response> {
    const result = await PortalInviteService.accept(request.body)
    if (!result.status) return sendFailure(response, result.error, portalErrorHttpStatusMap)
    return sendSuccess(response, "Acesso liberado.", result.data)
  }

  async login(request: Request<unknown, unknown, PortalLoginDTO>, response: Response): Promise<Response> {
    const result = await PortalAuthService.login(request.body)
    if (!result.status) return sendFailure(response, result.error, portalErrorHttpStatusMap)
    return sendSuccess(response, "Login realizado com sucesso.", result.data)
  }

  async refresh(request: Request<unknown, unknown, RefreshDTO>, response: Response): Promise<Response> {
    const result = await PortalAuthService.refresh(request.body)
    if (!result.status) return sendFailure(response, result.error, portalErrorHttpStatusMap)
    return sendSuccess(response, "Sessão renovada.", result.data)
  }

  async logout(request: Request, response: Response): Promise<Response> {
    const result = await PortalAuthService.logout(
      requireAuthField(request, "portalAccountId"),
      requireAuthField(request, "portalSessionId"),
    )
    if (!result.status) return sendFailure(response, result.error, portalErrorHttpStatusMap)
    return sendSuccess(response, "Você saiu da conta.")
  }

  async listStores(request: Request, response: Response): Promise<Response> {
    const result = await PortalService.listStores(requireAuthField(request, "portalAccountId"))
    if (!result.status) return sendFailure(response, result.error, portalErrorHttpStatusMap)
    return sendSuccess(response, "Lojas carregadas.", result.data)
  }

  async statement(request: Request<StoreParamsDTO>, response: Response): Promise<Response> {
    const filters = request.query as unknown as StatementDTO
    const result = await PortalService.statement(requireAuthField(request, "portalAccountId"), request.params.id, filters)
    if (!result.status) return sendFailure(response, result.error, portalErrorHttpStatusMap)
    return sendSuccess(response, "Movimentações carregadas.", result.data)
  }
}

export default new PortalController()
