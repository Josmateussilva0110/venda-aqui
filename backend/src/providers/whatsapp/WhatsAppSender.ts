export interface WhatsAppSender {
  sendRecoveryCode(phone: string, code: string): Promise<void>
}
