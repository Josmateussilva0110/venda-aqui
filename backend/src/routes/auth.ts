import { Router } from "express"
import AuthController from "../controllers/AuthController"
import { authMiddleware } from "../middleware/auth"
import {
  loginRateLimiter,
  phoneCheckRateLimiter,
  pinRecoveryConfirmRateLimiter,
  pinRecoveryRequestRateLimiter,
  refreshRateLimiter,
  registerRateLimiter,
} from "../middleware/rateLimit"
import { validate } from "../middleware/validate"
import { CheckPhoneSchema } from "../schemas/auth/checkPhone"
import { LoginSchema } from "../schemas/auth/login"
import { PinRecoveryConfirmSchema } from "../schemas/auth/pinRecoveryConfirm"
import { PinRecoveryRequestSchema } from "../schemas/auth/pinRecoveryRequest"
import { RefreshSchema } from "../schemas/auth/refresh"
import { RegisterSchema } from "../schemas/auth/register"

const router = Router()

// POST com o telefone no corpo, para o número não ficar em log de URL
router.post("/phone/check", phoneCheckRateLimiter, validate(CheckPhoneSchema), AuthController.checkPhone)
router.post("/register", registerRateLimiter, validate(RegisterSchema), AuthController.register)
router.post("/login", loginRateLimiter, validate(LoginSchema), AuthController.login)
router.post("/refresh", refreshRateLimiter, validate(RefreshSchema), AuthController.refresh)
router.post("/logout", authMiddleware, AuthController.logout)
router.get("/me", authMiddleware, AuthController.me)
router.post("/pin-recovery/request", pinRecoveryRequestRateLimiter, validate(PinRecoveryRequestSchema), AuthController.requestPinRecovery)
router.post("/pin-recovery/confirm", pinRecoveryConfirmRateLimiter, validate(PinRecoveryConfirmSchema), AuthController.confirmPinRecovery)

export default router
