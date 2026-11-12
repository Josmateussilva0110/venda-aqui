import { SettingsErrorCode } from "../types/settings"

export const CREDIT_SETTINGS_FETCH_FAILED_ERROR = {
  code: SettingsErrorCode.CREDIT_SETTINGS_FETCH_FAILED,
  message: "Erro ao carregar as configurações do fiado.",
}
export const CREDIT_SETTINGS_UPDATE_FAILED_ERROR = {
  code: SettingsErrorCode.CREDIT_SETTINGS_UPDATE_FAILED,
  message: "Erro ao salvar as configurações do fiado.",
}

export const settingsErrorHttpStatusMap: Record<SettingsErrorCode, number> = {
  [SettingsErrorCode.CREDIT_SETTINGS_FETCH_FAILED]: 500,
  [SettingsErrorCode.CREDIT_SETTINGS_UPDATE_FAILED]: 500,
}
