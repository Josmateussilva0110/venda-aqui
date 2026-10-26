import { z } from "zod"

export const uuidField = z.uuid({ error: "Identificador inválido." })
