import { createApp } from "./app"
import { env } from "./config/env"

createApp().listen(env.PORT, () => {
  console.info(`[server] Vendaqui API ouvindo na porta ${env.PORT}`)
})
