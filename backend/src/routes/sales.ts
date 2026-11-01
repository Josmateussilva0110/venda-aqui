import { Router } from "express"
import SaleController from "../controllers/SaleController"
import { authMiddleware } from "../middleware/auth"
import { validate } from "../middleware/validate"
import { ListSalesSchema } from "../schemas/sales/listSales"
import { SaleSchema } from "../schemas/sales/sale"
import { SaleParamsSchema } from "../schemas/sales/saleParams"

const router = Router()

router.use(authMiddleware)

router.get("/", validate(ListSalesSchema, "query"), SaleController.list)
router.post("/", validate(SaleSchema), SaleController.create)
router.get("/:id", validate(SaleParamsSchema, "params"), SaleController.get)
router.put("/:id", validate(SaleParamsSchema, "params"), validate(SaleSchema), SaleController.update)

export default router
