import { z } from "zod"
import { deviceIdField } from "../fields/deviceId"
import { phoneField } from "../fields/phone"
import { pinField } from "../fields/pin"

export const LoginSchema = z.object({
  phone: phoneField,
  pin: pinField,
  deviceId: deviceIdField,
})

export type LoginDTO = z.infer<typeof LoginSchema>
