import request from "supertest"
import { describe, expect, it } from "vitest"
import { createApp } from "../src/app"
import { signAccessToken } from "../src/utils/tokens"

const app = createApp()

describe("contrato HTTP sem banco", () => {
  it("responde 404 no envelope padrão", async () => {
    const response = await request(app).get("/api/nao-existe")
    expect(response.status).toBe(404)
    expect(response.body).toEqual({ success: false, message: "Rota não encontrada." })
  })

  it("responde 422 com errors[].field na validação", async () => {
    const response = await request(app).post("/api/auth/login").send({ phone: "123", pin: "12" })
    expect(response.status).toBe(422)
    expect(response.body.success).toBe(false)
    expect(response.body.errors.map((error: { field: string }) => error.field)).toEqual(["phone", "pin", "deviceId"])
  })

  it("responde 400 para JSON malformado", async () => {
    const response = await request(app).post("/api/auth/login").set("Content-Type", "application/json").send("{oops")
    expect(response.status).toBe(400)
    expect(response.body).toEqual({ success: false, message: "JSON inválido." })
  })

  it("responde 413 para corpo acima do limite", async () => {
    const response = await request(app).post("/api/auth/login").send({ phone: "x".repeat(20_000) })
    expect(response.status).toBe(413)
  })

  it("exige token nas rotas de produto, com código para o app renovar a sessão", async () => {
    const response = await request(app).get("/api/products")
    expect(response.status).toBe(401)
    expect(response.body.code).toBe("ACCESS_TOKEN_INVALID")
  })

  it("recusa token assinado com outro segredo", async () => {
    const response = await request(app)
      .get("/api/products")
      .set("Authorization", "Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ4In0.invalid")
    expect(response.status).toBe(401)
  })

  it("valida o id antes de consultar o banco", async () => {
    const token = signAccessToken({ merchantId: "6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11", sessionId: "s" })
    const response = await request(app).get("/api/products/abc").set("Authorization", `Bearer ${token}`)
    expect(response.status).toBe(422)
    expect(response.body.errors[0].field).toBe("id")
  })
})
