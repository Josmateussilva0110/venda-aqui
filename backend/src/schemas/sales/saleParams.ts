import { z } from "zod"
import { uuidField } from "../fields/uuid"

export const SaleParamsSchema = z.object({
  id: uuidField,
})

export type SaleParamsDTO = z.infer<typeof SaleParamsSchema>
