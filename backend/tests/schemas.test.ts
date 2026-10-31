import { describe, expect, it } from "vitest"
import { phoneField } from "../src/schemas/fields/phone"
import { newPinField, pinField } from "../src/schemas/fields/pin"
import { RegisterSchema } from "../src/schemas/auth/register"
import { ProductSchema } from "../src/schemas/products/product"
import { ListProductsSchema } from "../src/schemas/products/listProducts"
import { RestockSchema } from "../src/schemas/products/restock"
import { CustomerSchema } from "../src/schemas/customers/customer"
import { ListCustomersSchema } from "../src/schemas/customers/listCustomers"

describe("phoneField", () => {
  it.each([
    ["(86) 99999-0000", "+5586999990000"],
    ["+55 86 99999-0000", "+5586999990000"],
    ["5586999990000", "+5586999990000"],
    ["86 3222-1100", "+558632221100"],
    // Celular sem o 9 vira o mesmo número com o 9: não dá para cadastrar a mesma linha duas vezes
    ["(86) 9999-0000", "+5586999990000"],
    ["+55 86 8888-1234", "+5586988881234"],
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
    expect(ListProductsSchema.parse({ limit: "20", search: "  tom " })).toEqual({ limit: 20, offset: 0, search: "tom", stockLevel: "all" })
  })

  it("limita o tamanho da página", () => {
    expect(ListProductsSchema.safeParse({ limit: "500" }).success).toBe(false)
  })
})

describe("ListProductsSchema stockLevel", () => {
  it("recusa filtro de estoque desconhecido", () => {
    expect(ListProductsSchema.safeParse({ stockLevel: "zero" }).success).toBe(false)
  })
})

describe("RestockSchema", () => {
  it("recusa quantidade zero ou negativa", () => {
    expect(RestockSchema.safeParse({ quantity: 0 }).success).toBe(false)
    expect(RestockSchema.safeParse({ quantity: -2 }).success).toBe(false)
  })

  it("aceita peso com até 3 casas", () => {
    expect(RestockSchema.safeParse({ quantity: 1.25 }).success).toBe(true)
    expect(RestockSchema.safeParse({ quantity: 1.2345 }).success).toBe(false)
  })
})

describe("CustomerSchema", () => {
  it("normaliza nome e telefone", () => {
    expect(CustomerSchema.parse({ name: "  Maria  ", phone: "(86) 99999-0000" })).toEqual({ name: "Maria", phone: "+5586999990000" })
  })

  it("aponta os campos inválidos", () => {
    const result = CustomerSchema.safeParse({ name: "M", phone: "123" })
    expect(result.success).toBe(false)
    expect(result.error?.issues.map((issue) => issue.path.join("."))).toEqual(["name", "phone"])
  })
})

describe("ListCustomersSchema", () => {
  it("converte a query string e aplica padrões", () => {
    expect(ListCustomersSchema.parse({ limit: "20", search: "  ana " })).toEqual({ limit: 20, offset: 0, search: "ana" })
  })

  it("responde em português quando a página é inválida", () => {
    const result = ListCustomersSchema.safeParse({ limit: "500", offset: "-1" })
    expect(result.error?.issues.map((issue) => issue.message)).toEqual(["A página tem no máximo 100 itens.", "Posição da página inválida."])
  })
})
