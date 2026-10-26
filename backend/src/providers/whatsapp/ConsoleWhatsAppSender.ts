import type { WhatsAppSender } from "./WhatsAppSender"

// Só para desenvolvimento: o env.ts recusa este provedor em produção, porque
// imprimir o código no log equivale a entregá-lo a quem lê o log
export class ConsoleWhatsAppSender implements WhatsAppSender {
  async sendRecoveryCode(phone: string, code: string): Promise<void> {
    console.info(`[whatsapp:console] código de recuperação para ${phone}: ${code}`)
  }
}
