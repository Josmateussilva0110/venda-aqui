import { describe, expect, it } from "vitest"
import { phoneField } from "../src/schemas/fields/phone"
import { newPinField, pinField } from "../src/schemas/fields/pin"
import { RegisterSchema } from "../src/schemas/auth/register"
import { ProductSchema } from "../src/schemas/products/product"
import { ListProductsSchema } from "../src/schemas/products/listProducts"

describe("phoneField", () => {
  it.each([
    ["(86) 99999-0000", "+5586999990000"],
    ["+55 86 99999-0000", "+5586999990000"],
    ["5586999990000", "+5586999990000"],
    ["86 3222-1100", "+558632221100"],
  ])("normaliza %s", (input, expected) => {
    expect(phoneField.parse(input)).toBe(expected)
  })

  it.each(["123", "00 99999-0000", "86 99999-00000"])("recusa %s", (input) => {
    expect(phoneField.safeParse(input).success).toBe(false)
  })
})

describe("PIN", () => {
  it("aceita de 4 a 6 dígitos", () => {
    expect(pinField.safeParse("1234").success).toBe(true)
    expect(pinField.safeParse("123").success).toBe(false)
    expect(pinField.safeParse("1234567").success).toBe(false)
    expect(pinField.safeParse("12a4").success).toBe(false)
  })

  it.each(["0000", "1234", "4321", "890123", "999999"])("recusa PIN trivial no cadastro: %s", (pin) => {
    expect(newPinField.safeParse(pin).success).toBe(false)
  })

  it("aceita PIN não trivial no cadastro", () => {
    expect(newPinField.safeParse("2580").success).toBe(true)
  })
})

describe("RegisterSchema", () => {
  const valid = { name: "  Banca   da Maria ", phone: "86999990000", pin: "2580", pinConfirmation: "2580", deviceId: "device-123456" }

  it("normaliza nome e telefone", () => {
    const data = RegisterSchema.parse(valid)
    expect(data.name).toBe("Banca da Maria")
    expect(data.phone).toBe("+5586999990000")
  })

  it("aponta o campo pinConfirmation quando os PINs divergem", () => {
    const result = RegisterSchema.safeParse({ ...valid, pinConfirmation: "2581" })
    expect(result.success).toBe(false)
    expect(result.error?.issues[0]?.path).toEqual(["pinConfirmation"])
  })
})

describe("ProductSchema", () => {
  const valid = { name: "Tomate", salePriceCents: 800, costPriceCents: 500, quantity: 10 }

  it("assume vendido por unidade quando não informado", () => {
    expect(ProductSchema.parse(valid).soldByWeight).toBe(false)
  })

  it("exige quantidade inteira para produto por unidade", () => {
    const result = ProductSchema.safeParse({ ...valid, quantity: 1.5 })
    expect(result.success).toBe(false)
    expect(result.error?.issues[0]?.path).toEqual(["quantity"])
  })

  it("aceita fração para produto por peso, até 3 casas", () => {
    expect(ProductSchema.safeParse({ ...valid, quantity: 2.345, soldByWeight: true }).success).toBe(true)
    expect(ProductSchema.safeParse({ ...valid, quantity: 0.1, soldByWeight: true }).success).toBe(true)
    expect(ProductSchema.safeParse({ ...valid, quantity: 2.3456, soldByWeight: true }).success).toBe(false)
  })

  it("recusa preço com centavos fracionados ou negativo", () => {
    expect(ProductSchema.safeParse({ ...valid, salePriceCents: 8.5 }).success).toBe(false)
    expect(ProductSchema.safeParse({ ...valid, costPriceCents: -1 }).success).toBe(false)
  })
})

describe("ListProductsSchema", () => {
  it("converte a query string e aplica padrões", () => {
    expect(ListProductsSchema.parse({ limit: "20", search: "  tom " })).toEqual({ limit: 20, offset: 0, search: "tom" })
  })

  it("limita o tamanho da página", () => {
    expect(ListProductsSchema.safeParse({ limit: "500" }).success).toBe(false)
  })
})
