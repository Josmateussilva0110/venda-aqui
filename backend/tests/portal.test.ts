import request from "supertest"
import { describe, expect, it } from "vitest"
import { createApp } from "../src/app"
import { AcceptInviteSchema } from "../src/schemas/portal/acceptInvite"
import { PortalLoginSchema } from "../src/schemas/portal/login"
import { cpfField } from "../src/schemas/fields/cpf"
import { signAccessToken, signPortalAccessToken } from "../src/utils/tokens"

const app = createApp()
const id = "6f1c1a52-6d0b-4a40-9d0a-9c1b5a0f2f11"
const token = "a".repeat(43)
const deviceId = "device-123456"

describe("portal do cliente: contrato HTTP sem banco", () => {
  it("exige token do portal nas consultas", async () => {
    const response = await request(app).get("/api/portal/stores")
    expect(response.status).toBe(401)
    expect(response.body.code).toBe("PORTAL_ACCESS_TOKEN_INVALID")
  })

  // Mesmo segredo nos dois tokens: só o emissor separa, então isto não pode regredir
  it("token do comerciante não vale no portal e o do cliente não vale nas rotas do comerciante", async () => {
    const merchantToken = signAccessToken({ merchantId: id, sessionId: "s" })
    const portalToken = signPortalAccessToken({ accountId: id, sessionId: "s" })

    const inPortal = await request(app).get("/api/portal/stores").set("Authorization", `Bearer ${merchantToken}`)
    const inMerchant = await request(app).get("/api/customers").set("Authorization", `Bearer ${portalToken}`)
    expect([inPortal.status, inMerchant.status]).toEqual([401, 401])
  })

  it("valida o id da loja e a página antes do banco", async () => {
    const portalToken = signPortalAccessToken({ accountId: id, sessionId: "s" })
    const invalidId = await request(app).get("/api/portal/stores/abc/statement").set("Authorization", `Bearer ${portalToken}`)
    const invalidPage = await request(app)
      .get(`/api/portal/stores/${id}/statement`)
      .query({ limit: 0 })
      .set("Authorization", `Bearer ${portalToken}`)
    expect([invalidId.status, invalidPage.status]).toEqual([422, 422])
    expect(invalidId.body.errors[0].field).toBe("id")
    expect(invalidPage.body.errors[0].field).toBe("limit")
  })

  it("login valida o método e os campos dele", async () => {
    const noMethod = await request(app).post("/api/portal/auth/login").send({ pin: "1357", deviceId })
    const badCpf = await request(app).post("/api/portal/auth/login").send({ method: "cpf", cpf: "123", pin: "1357", deviceId })
    expect([noMethod.status, badCpf.status]).toEqual([422, 422])
    expect(badCpf.body.errors[0].field).toBe("cpf")
  })

  it("link do convite é validado antes do banco", async () => {
    const response = await request(app).post("/api/portal/invites/inspect").send({ token: "curto" })
    expect(response.status).toBe(422)
    expect(response.body.errors[0].field).toBe("token")
  })

  it("gerar o link exige token do comerciante e id válido", async () => {
    const anonymous = await request(app).post(`/api/customers/${id}/portal-invite`)
    const merchantToken = signAccessToken({ merchantId: id, sessionId: "s" })
    const invalidId = await request(app).post("/api/customers/abc/portal-invite").set("Authorization", `Bearer ${merchantToken}`)
    expect([anonymous.status, invalidId.status]).toEqual([401, 422])
  })
})

describe("cpfField", () => {
  it("aceita com pontuação e devolve só os dígitos", () => {
    expect(cpfField.parse("529.982.247-25")).toBe("52998224725")
  })

  it.each(["", "111.111.111-11", "529.982.247-26"])("recusa %s", (input) => {
    expect(cpfField.safeParse(input).success).toBe(false)
  })
})

describe("PortalLoginSchema", () => {
  it("entra pelo telefone normalizado", () => {
    const result = PortalLoginSchema.parse({ method: "phone", phone: "(86) 99999-0000", pin: "1357", deviceId })
    expect(result).toMatchObject({ method: "phone", phone: "+5586999990000" })
  })
})

describe("AcceptInviteSchema", () => {
  it("aceita o PIN atual (conta existente)", () => {
    expect(AcceptInviteSchema.safeParse({ token, deviceId, currentPin: "1357" }).success).toBe(true)
  })

  it("aceita PIN novo com confirmação (conta nova ou esqueci o PIN)", () => {
    expect(AcceptInviteSchema.safeParse({ token, deviceId, newPin: "1357", newPinConfirmation: "1357" }).success).toBe(true)
  })

  it.each([
    ["nenhum PIN", {}, "newPin"],
    ["os dois PINs", { currentPin: "1357", newPin: "2468", newPinConfirmation: "2468" }, "newPin"],
    ["confirmação diferente", { newPin: "1357", newPinConfirmation: "1358" }, "newPinConfirmation"],
    ["PIN novo fácil demais", { newPin: "1234", newPinConfirmation: "1234" }, "newPin"],
  ])("recusa %s", (_label, pins, field) => {
    const result = AcceptInviteSchema.safeParse({ token, deviceId, ...pins })
    expect(result.success).toBe(false)
    expect(result.error?.issues[0]?.path).toEqual([field])
  })
})
