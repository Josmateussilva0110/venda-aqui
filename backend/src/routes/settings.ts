import { Router } from "express"
import SettingsController from "../controllers/SettingsController"
import { authMiddleware } from "../middleware/auth"
import { validate } from "../middleware/validate"
import { CreditSettingsSchema } from "../schemas/settings/creditSettings"

const router = Router()

router.use(authMiddleware)

router.get("/credit", SettingsController.getCredit)
router.put("/credit", validate(CreditSettingsSchema), SettingsController.updateCredit)

export default router
