import { z } from "zod"
import { uuidField } from "../fields/uuid"

export const CustomerParamsSchema = z.object({
  id: uuidField,
})

export type CustomerParamsDTO = z.infer<typeof CustomerParamsSchema>
