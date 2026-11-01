import { z } from "zod"
import { paginationFields } from "../fields/pagination"

export const StatementSchema = z.object({
  ...paginationFields,
})

export type StatementDTO = z.infer<typeof StatementSchema>
