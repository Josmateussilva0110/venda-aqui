import { z } from "zod"

// base64url de PORTAL_INVITE_TOKEN_BYTES bytes (43 caracteres); a faixa folgada só barra lixo antes do banco
export const inviteTokenField = z
  .string({ error: "Link inválido." })
  .trim()
  .regex(/^[A-Za-z0-9_-]{32,128}$/, { error: "Link inválido." })

export const InviteTokenSchema = z.object({
  token: inviteTokenField,
})

export type InviteTokenDTO = z.infer<typeof InviteTokenSchema>
