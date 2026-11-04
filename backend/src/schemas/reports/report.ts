import { z } from "zod"
import { periodFields, withPeriodRules } from "../fields/period"

export const ReportSchema = withPeriodRules(z.object({ ...periodFields }))

export type ReportDTO = z.infer<typeof ReportSchema>
