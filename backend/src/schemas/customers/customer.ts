import { z } from "zod"
import { nameField } from "../fields/name"
import { phoneField } from "../fields/phone"


export const CustomerSchema = z.object({
  name: nameField("o nome do cliente", 2, 80),
  phone: phoneField,
})

export type CustomerDTO = z.infer<typeof CustomerSchema>
