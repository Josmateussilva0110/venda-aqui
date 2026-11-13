import { z } from "zod"

// O intervalo aceito (de hoje a um ano) depende do dia no servidor e é conferido no banco
export const DueDateSchema = z.object({
  dueDate: z.iso.date({ error: "Informe a data no formato AAAA-MM-DD." }),
})

export type DueDateDTO = z.infer<typeof DueDateSchema>
