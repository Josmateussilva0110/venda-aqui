import { z } from "zod"
import { phoneField } from "../fields/phone"

export const PinRecoveryRequestSchema = z.object({
  phone: phoneField,
})

export type PinRecoveryRequestDTO = z.infer<typeof PinRecoveryRequestSchema>
