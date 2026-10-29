import express from "express"
import helmet from "helmet"
import { env } from "./config/env"
import { errorHandler } from "./middleware/errorHandler"
import { notFound } from "./middleware/notFound"
import routes from "./routes"

export function createApp() {
  const app = express()

  app.disable("x-powered-by")
  // Atrás do proxy da hospedagem, sem isso o rate limit veria um IP só para todo mundo
  if (env.NODE_ENV === "production") app.set("trust proxy", 1)

  app.use(helmet())
  // Sem CORS: o único cliente é o app Android, que não passa pela política de origem dos navegadores.
  // Sem os cabeçalhos, nenhum site consegue ler as respostas da API a partir do navegador de alguém
  app.use(express.json({ limit: "10kb" }))

  app.use("/api", routes)
  app.use(notFound)
  app.use(errorHandler)

  return app
}
