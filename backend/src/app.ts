import cors from "cors"
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
  app.use(
    cors({
      origin(origin, callback) {
        // Apps nativos não mandam Origin; navegadores só passam se estiverem na lista
        callback(null, !origin || env.CORS_ORIGINS.includes(origin))
      },
    }),
  )
  app.use(express.json({ limit: "10kb" }))

  app.use("/api", routes)
  app.use(notFound)
  app.use(errorHandler)

  return app
}
