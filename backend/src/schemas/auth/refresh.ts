import { z } from "zod"
import { deviceIdField } from "../fields/deviceId"

export const RefreshSchema = z.object({
  refreshToken: z.string({ error: "Sessão ausente." }).min(1, { error: "Sessão ausente." }).max(200),
  deviceId: deviceIdField,
})

export type RefreshDTO = z.infer<typeof RefreshSchema>
