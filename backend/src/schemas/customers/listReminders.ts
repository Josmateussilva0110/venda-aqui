import { z } from "zod"
import { paginationFields } from "../fields/pagination"

export const ListRemindersSchema = z.object({
  ...paginationFields,
})

export type ListRemindersDTO = z.infer<typeof ListRemindersSchema>
