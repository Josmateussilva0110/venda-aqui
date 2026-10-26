import { Router } from "express"
import ProductController from "../controllers/ProductController"
import { authMiddleware } from "../middleware/auth"
import { validate } from "../middleware/validate"
import { ListProductsSchema } from "../schemas/products/listProducts"
import { PhotoSchema } from "../schemas/products/photo"
import { PhotoUploadUrlSchema } from "../schemas/products/photoUploadUrl"
import { ProductSchema } from "../schemas/products/product"
import { ProductParamsSchema } from "../schemas/products/productParams"

const router = Router()

router.use(authMiddleware)

router.get("/", validate(ListProductsSchema, "query"), ProductController.list)
router.post("/", validate(ProductSchema), ProductController.create)
router.get("/:id", validate(ProductParamsSchema, "params"), ProductController.get)
router.put("/:id", validate(ProductParamsSchema, "params"), validate(ProductSchema), ProductController.update)
router.post("/:id/photo/upload-url", validate(ProductParamsSchema, "params"), validate(PhotoUploadUrlSchema), ProductController.createPhotoUploadUrl)
router.put("/:id/photo", validate(ProductParamsSchema, "params"), validate(PhotoSchema), ProductController.updatePhoto)

export default router
