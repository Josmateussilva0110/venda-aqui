import { z } from "zod"
import { deviceIdField } from "../fields/deviceId"
import { nameField } from "../fields/name"
import { phoneField } from "../fields/phone"
import { newPinField } from "../fields/pin"

export const RegisterSchema = z
  .object({
    name: nameField("o nome do comércio", 2, 80),
    phone: phoneField,
    pin: newPinField,
    pinConfirmation: z.string({ error: "Confirme o PIN." }),
    deviceId: deviceIdField,
  })
  .refine((data) => data.pin === data.pinConfirmation, {
    error: "Os PINs não conferem.",
    path: ["pinConfirmation"],
  })

export type RegisterDTO = z.infer<typeof RegisterSchema>
