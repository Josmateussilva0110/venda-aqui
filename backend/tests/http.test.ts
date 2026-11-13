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

  it("remoção de produto exige token e id válido antes de tocar no banco", async () => {
    const anonymous = await request(app).delete("/api/products/6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11")
    expect(anonymous.status).toBe(401)

    const token = signAccessToken({ merchantId: "6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11", sessionId: "s" })
    const invalidId = await request(app).delete("/api/products/abc").set("Authorization", `Bearer ${token}`)
    expect(invalidId.status).toBe(422)
    expect(invalidId.body.errors[0].field).toBe("id")
  })

  it("exige token nas rotas de cliente", async () => {
    const response = await request(app).get("/api/customers")
    expect(response.status).toBe(401)
    expect(response.body.code).toBe("ACCESS_TOKEN_INVALID")
  })

  it("exige token nas rotas de venda", async () => {
    const response = await request(app).post("/api/sales").send({})
    expect(response.status).toBe(401)
    expect(response.body.code).toBe("ACCESS_TOKEN_INVALID")
  })

  it("exige token no relatório e valida o período antes de consultar o banco", async () => {
    const anonymous = await request(app).get("/api/reports/sales")
    const token = signAccessToken({ merchantId: "6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11", sessionId: "s" })
    const invalid = await request(app).get("/api/reports/sales").query({ from: "2026-11-02T00:00:00Z", to: "2026-11-01T00:00:00Z" }).set("Authorization", `Bearer ${token}`)
    expect([anonymous.status, invalid.status]).toEqual([401, 422])
  })

  it("valida o id da venda e do pagamento antes de consultar o banco", async () => {
    const token = signAccessToken({ merchantId: "6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11", sessionId: "s" })
    const sale = await request(app).get("/api/sales/abc").set("Authorization", `Bearer ${token}`)
    const payment = await request(app).post("/api/customers/abc/payments").set("Authorization", `Bearer ${token}`).send({ amountCents: 100, paymentMethod: "pix" })
    expect([sale.status, payment.status]).toEqual([422, 422])
  })

  it.each(["get", "put", "delete"] as const)("valida o id do cliente no %s antes de consultar o banco", async (method) => {
    const token = signAccessToken({ merchantId: "6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11", sessionId: "s" })
    const response = await request(app)[method]("/api/customers/abc").set("Authorization", `Bearer ${token}`)
    expect(response.status).toBe(422)
    expect(response.body.errors[0].field).toBe("id")
  })

  // Se /reminders ficar depois de /:id, "reminders" vira id inválido e a tela de lembretes quebra
  it("lista de lembretes não é confundida com o id de um cliente", async () => {
    const token = signAccessToken({ merchantId: "6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11", sessionId: "s" })
    const response = await request(app).get("/api/customers/reminders").query({ limit: 0 }).set("Authorization", `Bearer ${token}`)
    expect(response.status).toBe(422)
    expect(response.body.errors[0].field).toBe("limit")
  })

  it("vencimento, lembrete e configuração do fiado exigem token e validam antes do banco", async () => {
    const id = "6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11"
    const anonymous = await Promise.all([
      request(app).put(`/api/customers/${id}/due-date`).send({ dueDate: "2026-12-01" }),
      request(app).post(`/api/customers/${id}/reminders`),
      request(app).get("/api/settings/credit"),
    ])
    expect(anonymous.map((response) => response.status)).toEqual([401, 401, 401])

    const token = signAccessToken({ merchantId: id, sessionId: "s" })
    const dueDate = await request(app).put(`/api/customers/${id}/due-date`).set("Authorization", `Bearer ${token}`).send({ dueDate: "01/12/2026" })
    const reminder = await request(app).post("/api/customers/abc/reminders").set("Authorization", `Bearer ${token}`)
    const openAccount = await request(app).get("/api/customers/abc/open-account").set("Authorization", `Bearer ${token}`)
    expect(openAccount.status).toBe(422)
    const settings = await request(app).put("/api/settings/credit").set("Authorization", `Bearer ${token}`).send({})
    expect([dueDate.status, reminder.status, settings.status]).toEqual([422, 422, 422])
    expect(dueDate.body.errors[0].field).toBe("dueDate")
    expect(reminder.body.errors[0].field).toBe("id")
  })
})
