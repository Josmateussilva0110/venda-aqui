import { Router } from "express"
import authRoutes from "./auth"
import productRoutes from "./products"

const router = Router()

router.get("/health", (_request, response) => {
  response.status(200).json({ success: true, message: "API no ar." })
})
router.use("/auth", authRoutes)
router.use("/products", productRoutes)

export default router
