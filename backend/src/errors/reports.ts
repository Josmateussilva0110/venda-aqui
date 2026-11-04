import { ReportErrorCode } from "../types/reports"

export const REPORT_FAILED_ERROR = { code: ReportErrorCode.REPORT_FAILED, message: "Erro ao carregar o relatório." }

export const reportErrorHttpStatusMap: Record<ReportErrorCode, number> = {
  [ReportErrorCode.REPORT_FAILED]: 500,
}
