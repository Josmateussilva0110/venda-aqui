import { z } from "zod"
import { cpfField } from "../fields/cpf"
import { deviceIdField } from "../fields/deviceId"
import { phoneField } from "../fields/phone"
import { pinField } from "../fields/pin"

// O método vem explícito: um celular com DDD também tem 11 dígitos e poderia ser lido como CPF
export const PortalLoginSchema = z.discriminatedUnion(
  "method",
  [
    z.object({ method: z.literal("phone"), phone: phoneField, pin: pinField, deviceId: deviceIdField }),
    z.object({ method: z.literal("cpf"), cpf: cpfField, pin: pinField, deviceId: deviceIdField }),
  ],
  { error: "Escolha entrar pelo telefone ou pelo CPF." },
)

export type PortalLoginDTO = z.infer<typeof PortalLoginSchema>
