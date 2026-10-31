import { Router } from "express"
import CustomerController from "../controllers/CustomerController"
import { authMiddleware } from "../middleware/auth"
import { validate } from "../middleware/validate"
import { CustomerSchema } from "../schemas/customers/customer"

const router = Router()

router.use(authMiddleware)

router.post("/", validate(CustomerSchema), CustomerController.create)

export default router
