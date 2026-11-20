import { Router } from "express"
import PortalController from "../controllers/PortalController"
import { portalAuthMiddleware } from "../middleware/portalAuth"
import { portalInviteRateLimiter, portalLoginRateLimiter, portalRefreshRateLimiter } from "../middleware/rateLimit"
import { validate } from "../middleware/validate"
import { RefreshSchema } from "../schemas/auth/refresh"
import { StatementSchema } from "../schemas/customers/statement"
import { AcceptInviteSchema } from "../schemas/portal/acceptInvite"
import { InviteTokenSchema } from "../schemas/portal/inviteToken"
import { PortalLoginSchema } from "../schemas/portal/login"
import { StoreParamsSchema } from "../schemas/portal/storeParams"

// Rotas do app do cliente (Android)
const router = Router()

// POST com o token no corpo, para o link não ficar em log de URL
router.post("/invites/inspect", portalInviteRateLimiter, validate(InviteTokenSchema), PortalController.inspectInvite)
router.post("/invites/accept", portalInviteRateLimiter, validate(AcceptInviteSchema), PortalController.acceptInvite)
router.post("/auth/login", portalLoginRateLimiter, validate(PortalLoginSchema), PortalController.login)
router.post("/auth/refresh", portalRefreshRateLimiter, validate(RefreshSchema), PortalController.refresh)
router.post("/auth/logout", portalAuthMiddleware, PortalController.logout)
router.get("/stores", portalAuthMiddleware, PortalController.listStores)
router.get(
  "/stores/:id/statement",
  portalAuthMiddleware,
  validate(StoreParamsSchema, "params"),
  validate(StatementSchema, "query"),
  PortalController.statement,
)

export default router
