import { env } from "../../config/env"
import { ConsoleWhatsAppSender } from "./ConsoleWhatsAppSender"
import { MetaWhatsAppSender } from "./MetaWhatsAppSender"
import type { WhatsAppSender } from "./WhatsAppSender"

function createWhatsAppSender(): WhatsAppSender {
  if (env.WHATSAPP_PROVIDER === "meta") {
    return new MetaWhatsAppSender({
      phoneNumberId: env.WHATSAPP_PHONE_NUMBER_ID!,
      accessToken: env.WHATSAPP_ACCESS_TOKEN!,
      templateName: env.WHATSAPP_TEMPLATE_NAME!,
      templateLanguage: env.WHATSAPP_TEMPLATE_LANGUAGE,
    })
  }
  return new ConsoleWhatsAppSender()
}

export const whatsAppSender = createWhatsAppSender()
export type { WhatsAppSender }
