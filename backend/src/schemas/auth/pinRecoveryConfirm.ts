import { z } from "zod"
import { RECOVERY_CODE_LENGTH } from "../../constants/auth"
import { deviceIdField } from "../fields/deviceId"
import { phoneField } from "../fields/phone"
import { newPinField } from "../fields/pin"

export const PinRecoveryConfirmSchema = z
  .object({
    phone: phoneField,
    code: z
      .string({ error: "Informe o código recebido." })
      .trim()
      .regex(new RegExp(`^\\d{${RECOVERY_CODE_LENGTH}}$`), { error: `O código tem ${RECOVERY_CODE_LENGTH} números.` }),
    pin: newPinField,
    pinConfirmation: z.string({ error: "Confirme o PIN." }),
    deviceId: deviceIdField,
  })
  .refine((data) => data.pin === data.pinConfirmation, {
    error: "Os PINs não conferem.",
    path: ["pinConfirmation"],
  })

export type PinRecoveryConfirmDTO = z.infer<typeof PinRecoveryConfirmSchema>
