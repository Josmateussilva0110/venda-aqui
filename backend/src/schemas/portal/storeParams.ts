import { z } from "zod"
import { uuidField } from "../fields/uuid"

export const StoreParamsSchema = z.object({
  id: uuidField,
})

export type StoreParamsDTO = z.infer<typeof StoreParamsSchema>
