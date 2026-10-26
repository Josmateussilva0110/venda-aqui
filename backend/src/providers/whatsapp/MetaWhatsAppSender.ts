import type { WhatsAppSender } from "./WhatsAppSender"

const GRAPH_API_URL = "https://graph.facebook.com/v21.0"
const REQUEST_TIMEOUT_MS = 10_000

interface MetaConfig {
  phoneNumberId: string
  accessToken: string
  templateName: string
  templateLanguage: string
}

// WhatsApp Cloud API com template de autenticação (categoria AUTHENTICATION,
// botão "copiar código"), que precisa estar aprovado no Meta Business
export class MetaWhatsAppSender implements WhatsAppSender {
  constructor(private readonly config: MetaConfig) {}

  async sendRecoveryCode(phone: string, code: string): Promise<void> {
    const response = await fetch(`${GRAPH_API_URL}/${this.config.phoneNumberId}/messages`, {
      method: "POST",
      headers: { Authorization: `Bearer ${this.config.accessToken}`, "Content-Type": "application/json" },
      body: JSON.stringify(this.buildTemplateMessage(phone, code)),
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    })

    if (!response.ok) {
      // O corpo de erro da Meta não contém o código enviado, então pode ir para o log
      throw new Error(`WhatsApp Cloud API respondeu ${response.status}: ${await response.text()}`)
    }
  }

  private buildTemplateMessage(phone: string, code: string) {
    return {
      messaging_product: "whatsapp",
      to: phone.replace("+", ""),
      type: "template",
      template: {
        name: this.config.templateName,
        language: { code: this.config.templateLanguage },
        components: [
          { type: "body", parameters: [{ type: "text", text: code }] },
          { type: "button", sub_type: "url", index: "0", parameters: [{ type: "text", text: code }] },
        ],
      },
    }
  }
}
