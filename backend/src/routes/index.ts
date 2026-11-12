import { Router } from "express"
import authRoutes from "./auth"
import customerRoutes from "./customers"
import productRoutes from "./products"
import reportRoutes from "./reports"
import saleRoutes from "./sales"
import settingsRoutes from "./settings"

const router = Router()

router.get("/health", (_request, response) => {
  response.status(200).json({ success: true, message: "API no ar." })
})
router.use("/auth", authRoutes)
router.use("/products", productRoutes)
router.use("/customers", customerRoutes)
router.use("/sales", saleRoutes)
router.use("/reports", reportRoutes)
router.use("/settings", settingsRoutes)

export default router
