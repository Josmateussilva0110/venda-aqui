import { z } from "zod"
import { deviceIdField } from "../fields/deviceId"
import { newPinField, pinField } from "../fields/pin"
import { inviteTokenField } from "./inviteToken"

// Conta existente: o PIN atual liga a loja. Conta nova, ou "esqueci o PIN": PIN novo com confirmação
export const AcceptInviteSchema = z
  .object({
    token: inviteTokenField,
    deviceId: deviceIdField,
    currentPin: pinField.optional(),
    newPin: newPinField.optional(),
    newPinConfirmation: z.string({ error: "Confirme o PIN." }).optional(),
  })
  .refine((data) => (data.currentPin === undefined) !== (data.newPin === undefined), {
    error: "Informe o PIN atual ou crie um PIN novo.",
    path: ["newPin"],
  })
  .refine((data) => data.newPin === undefined || data.newPin === data.newPinConfirmation, {
    error: "Os PINs não conferem.",
    path: ["newPinConfirmation"],
  })

export type AcceptInviteDTO = z.infer<typeof AcceptInviteSchema>
