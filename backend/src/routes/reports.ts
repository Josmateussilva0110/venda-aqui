import { Router } from "express"
import ReportController from "../controllers/ReportController"
import { authMiddleware } from "../middleware/auth"
import { validate } from "../middleware/validate"
import { ReportSchema } from "../schemas/reports/report"

const router = Router()

router.use(authMiddleware)

router.get("/sales", validate(ReportSchema, "query"), ReportController.sales)

export default router
