import { Router } from "express"
import CustomerController from "../controllers/CustomerController"
import { authMiddleware } from "../middleware/auth"
import { validate } from "../middleware/validate"
import { CustomerSchema } from "../schemas/customers/customer"
import { ListCustomersSchema } from "../schemas/customers/listCustomers"

const router = Router()

router.use(authMiddleware)

router.get("/", validate(ListCustomersSchema, "query"), CustomerController.list)
router.post("/", validate(CustomerSchema), CustomerController.create)

export default router
