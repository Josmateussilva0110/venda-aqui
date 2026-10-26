import { z } from "zod"

export const PhotoSchema = z.object({
  path: z.string({ error: "Informe o caminho da foto enviada." }).trim().min(1).max(300),
})

export type PhotoDTO = z.infer<typeof PhotoSchema>
