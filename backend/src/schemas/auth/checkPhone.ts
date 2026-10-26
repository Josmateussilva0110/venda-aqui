import { z } from "zod"
import { phoneField } from "../fields/phone"

export const CheckPhoneSchema = z.object({
  phone: phoneField,
})

export type CheckPhoneDTO = z.infer<typeof CheckPhoneSchema>
