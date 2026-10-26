import { z } from "zod"
import { uuidField } from "../fields/uuid"

export const ProductParamsSchema = z.object({
  id: uuidField,
})

export type ProductParamsDTO = z.infer<typeof ProductParamsSchema>
