import { config as loadDotenv } from "dotenv"
import path from "node:path"
import { z } from "zod"

// O .env fica na raiz do repositório. O caminho parte deste arquivo, e não do diretório
// atual, para funcionar tanto em src/config (tsx) quanto em dist/config (build)
loadDotenv({ path: path.resolve(__dirname, "../../../.env"), quiet: true })

const EnvSchema = z
  .object({
    NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
    PORT: z.coerce.number().int().positive().default(3333),
    SUPABASE_URL: z.url(),
    SUPABASE_SECRET_KEY: z.string().min(1),
    JWT_SECRET: z.string().min(32, "JWT_SECRET precisa de pelo menos 32 caracteres."),
    WHATSAPP_PROVIDER: z.enum(["console", "meta"]).default("console"),
    WHATSAPP_PHONE_NUMBER_ID: z.string().optional(),
    WHATSAPP_ACCESS_TOKEN: z.string().optional(),
    WHATSAPP_TEMPLATE_NAME: z.string().optional(),
    WHATSAPP_TEMPLATE_LANGUAGE: z.string().default("pt_BR"),
  })
  .superRefine((env, context) => {
    // O provedor "console" imprime o código no log: aceitável em dev, vazamento em produção
    if (env.NODE_ENV === "production" && env.WHATSAPP_PROVIDER === "console") {
      context.addIssue({ code: "custom", path: ["WHATSAPP_PROVIDER"], message: "Use \"meta\" em produção." })
    }

    if (env.WHATSAPP_PROVIDER === "meta") {
      for (const key of ["WHATSAPP_PHONE_NUMBER_ID", "WHATSAPP_ACCESS_TOKEN", "WHATSAPP_TEMPLATE_NAME"] as const) {
        if (!env[key]) context.addIssue({ code: "custom", path: [key], message: "Obrigatório com WHATSAPP_PROVIDER=meta." })
      }
    }
  })

function loadEnv() {
  const parsed = EnvSchema.safeParse(process.env)

  if (!parsed.success) {
    const details = parsed.error.issues.map((issue) => `  - ${issue.path.join(".")}: ${issue.message}`).join("\n")
    console.error(`[env] Variáveis de ambiente inválidas:\n${details}`)
    process.exit(1)
  }

  return parsed.data
}

export const env = loadEnv()
