import { Router } from "express"
import CustomerController from "../controllers/CustomerController"
import { authMiddleware } from "../middleware/auth"
import { validate } from "../middleware/validate"
import { CustomerSchema } from "../schemas/customers/customer"
import { CustomerParamsSchema } from "../schemas/customers/customerParams"
import { ListCustomersSchema } from "../schemas/customers/listCustomers"

const router = Router()

router.use(authMiddleware)

router.get("/", validate(ListCustomersSchema, "query"), CustomerController.list)
router.post("/", validate(CustomerSchema), CustomerController.create)
router.get("/:id", validate(CustomerParamsSchema, "params"), CustomerController.get)
router.put("/:id", validate(CustomerParamsSchema, "params"), validate(CustomerSchema), CustomerController.update)
router.delete("/:id", validate(CustomerParamsSchema, "params"), CustomerController.delete)

export default router
