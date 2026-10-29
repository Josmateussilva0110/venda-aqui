import { beforeEach, describe, expect, it, vi } from "vitest"
import ProductService from "../src/services/ProductService"

// Cliente do Supabase falso (vi.mock sobe para antes dos imports): registra cada consulta
// à tabela de produtos e responde com uma contagem fixa
const queries: Array<{ head: boolean }> = []
const PAGE_COUNT = 7

vi.mock("../src/config/supabase", () => {
  const builder = (record: { head: boolean }) => {
    const chain: Record<string, unknown> = {}
    for (const method of ["eq", "ilike", "gt", "lte", "order", "range", "returns"]) {
      chain[method] = () => chain
    }
    chain.then = (resolve: (value: unknown) => unknown) =>
      resolve({ data: record.head ? null : [], count: record.head ? 1 : PAGE_COUNT, error: null })
    return chain
  }
  return {
    supabase: {
      from: () => ({
        select: (_columns: string, options?: { head?: boolean }) => {
          const record = { head: options?.head ?? false }
          queries.push(record)
          return builder(record)
        },
      }),
    },
  }
})

describe("listagem de produtos: consultas por página", () => {
  beforeEach(() => {
    queries.length = 0
  })

  it("páginas seguintes fazem só a consulta da página, sem as contagens das abas", async () => {
    const result = await ProductService.list("m1", { stockLevel: "all", limit: 30, offset: 30 })

    expect(queries).toHaveLength(1)
    expect(result.status && result.data.stockCounts).toBeUndefined()
  })

  it("primeira página sem busca reaproveita o total da página como contagem do filtro", async () => {
    const result = await ProductService.list("m1", { stockLevel: "low", limit: 30, offset: 0 })

    // Página + contagens de "all" e "out"; a de "low" é o próprio total da página
    expect(queries).toHaveLength(3)
    expect(result.status && result.data.stockCounts).toEqual({ all: 1, low: PAGE_COUNT, out: 1 })
  })

  it("com busca o total da página não vale como contagem das abas", async () => {
    const result = await ProductService.list("m1", { search: "café", stockLevel: "all", limit: 30, offset: 0 })

    expect(queries).toHaveLength(4)
    expect(result.status && result.data.stockCounts).toEqual({ all: 1, low: 1, out: 1 })
  })
})
