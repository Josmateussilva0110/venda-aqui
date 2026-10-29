import { randomUUID } from "node:crypto"
import { supabase } from "../config/supabase"
import { PRODUCT_COLUMNS } from "../constants/columns"
import { LOW_STOCK_THRESHOLD } from "../constants/products"
import { PHOTO_EXTENSIONS, PHOTO_THUMB_SUFFIX, PRODUCT_PHOTOS_BUCKET, type PhotoContentType } from "../constants/storage"
import type { ListProductsDTO } from "../schemas/products/listProducts"
import type { ProductDTO } from "../schemas/products/product"
import {
  ProductErrorCode,
  type PhotoUploadTarget,
  type Product,
  type ProductList,
  type StockCounts,
  type StockLevel,
  type UploadTarget,
} from "../types/products"
import type { ServiceResult } from "../types/serviceResult"
import { escapeLikePattern, isCheckViolation, isUniqueViolation } from "../utils/database"

type ProductResult<T> = Promise<ServiceResult<T, ProductErrorCode>>
type StockCountKey = keyof StockCounts

const STOCK_COUNT_KEYS: StockCountKey[] = ["all", "low", "out"]

interface ProductRow {
  id: string
  name: string
  photo_path: string | null
  thumb_path: string | null
  sale_price_cents: number
  cost_price_cents: number
  quantity: number | string
  sold_by_weight: boolean
  created_at: string
  updated_at: string
}

const NOT_FOUND_ERROR = { code: ProductErrorCode.PRODUCT_NOT_FOUND, message: "Produto não encontrado." }
const NAME_TAKEN_ERROR = { code: ProductErrorCode.PRODUCT_NAME_TAKEN, message: "Você já tem um produto com esse nome." }

// Todas as consultas filtram por merchant_id vindo do token: o cliente do Supabase
// usado aqui ignora o RLS, então esse filtro é o que separa uma conta da outra
class ProductService {
  async list(merchantId: string, filters: ListProductsDTO): ProductResult<ProductList> {
    try {
      let query = supabase
        .from("products")
        .select(PRODUCT_COLUMNS, { count: "exact" })
        .eq("merchant_id", merchantId)

      if (filters.search) {
        query = query.ilike("name", `%${escapeLikePattern(filters.search)}%`)
      }
      if (filters.stockLevel === "low") {
        query = query.gt("quantity", 0).lte("quantity", LOW_STOCK_THRESHOLD)
      } else if (filters.stockLevel === "out") {
        query = query.lte("quantity", 0)
      } else if (filters.stockLevel === "attention") {
        query = query.lte("quantity", LOW_STOCK_THRESHOLD).order("quantity", { ascending: true })
      }

      // As abas só precisam das contagens na primeira página (o app guarda as que já tem). Sem busca,
      // o total da própria página já é a contagem do filtro escolhido e não é consultado de novo
      const reusedCountKey = filters.search ? null : this.countKeyOf(filters.stockLevel)
      const [page, partialCounts] = await Promise.all([
        query
          .order("name", { ascending: true })
          .range(filters.offset, filters.offset + filters.limit - 1)
          .returns<ProductRow[]>(),
        filters.offset === 0 ? this.countByStockLevel(merchantId, reusedCountKey) : null,
      ])

      if (page.error) {
        console.error("[ProductService.list]", page.error)
        return { status: false, error: { code: ProductErrorCode.PRODUCT_LIST_FAILED, message: "Erro ao carregar os produtos." } }
      }

      return {
        status: true,
        data: {
          items: page.data.map((row) => this.toProduct(row)),
          total: page.count ?? 0,
          limit: filters.limit,
          offset: filters.offset,
          stockCounts: partialCounts ? this.completeCounts(partialCounts, reusedCountKey, page.count ?? 0) : undefined,
          lowStockThreshold: LOW_STOCK_THRESHOLD,
        },
      }
    } catch (error) {
      console.error("[ProductService.list] error:", error)
      return { status: false, error: { code: ProductErrorCode.PRODUCT_LIST_FAILED, message: "Erro ao carregar os produtos." } }
    }
  }

  async get(merchantId: string, productId: string): ProductResult<Product> {
    try {
      const { data, error } = await supabase
        .from("products")
        .select(PRODUCT_COLUMNS)
        .eq("id", productId)
        .eq("merchant_id", merchantId)
        .maybeSingle<ProductRow>()

      if (error) {
        console.error("[ProductService.get]", error)
        return { status: false, error: { code: ProductErrorCode.PRODUCT_FETCH_FAILED, message: "Erro ao carregar o produto." } }
      }
      if (!data) return { status: false, error: NOT_FOUND_ERROR }

      return { status: true, data: this.toProduct(data) }
    } catch (error) {
      console.error("[ProductService.get] error:", error)
      return { status: false, error: { code: ProductErrorCode.PRODUCT_FETCH_FAILED, message: "Erro ao carregar o produto." } }
    }
  }

  async create(merchantId: string, input: ProductDTO): ProductResult<{ id: string }> {
    try {
      const { data, error } = await supabase
        .from("products")
        .insert({ merchant_id: merchantId, ...this.toRow(input) })
        .select("id")
        .single<{ id: string }>()

      if (isUniqueViolation(error)) return { status: false, error: NAME_TAKEN_ERROR }
      if (error || !data) {
        console.error("[ProductService.create]", error)
        return { status: false, error: { code: ProductErrorCode.PRODUCT_CREATE_FAILED, message: "Erro ao cadastrar o produto." } }
      }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[ProductService.create] error:", error)
      return { status: false, error: { code: ProductErrorCode.PRODUCT_CREATE_FAILED, message: "Erro ao cadastrar o produto." } }
    }
  }

  async update(merchantId: string, productId: string, input: ProductDTO): ProductResult<{ id: string }> {
    try {
      const { data, error } = await supabase
        .from("products")
        .update(this.toRow(input))
        .eq("id", productId)
        .eq("merchant_id", merchantId)
        .select("id")
        .maybeSingle<{ id: string }>()

      if (isUniqueViolation(error)) return { status: false, error: NAME_TAKEN_ERROR }
      if (error) {
        console.error("[ProductService.update]", error)
        return { status: false, error: { code: ProductErrorCode.PRODUCT_UPDATE_FAILED, message: "Erro ao salvar o produto." } }
      }
      if (!data) return { status: false, error: NOT_FOUND_ERROR }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[ProductService.update] error:", error)
      return { status: false, error: { code: ProductErrorCode.PRODUCT_UPDATE_FAILED, message: "Erro ao salvar o produto." } }
    }
  }

  async restock(merchantId: string, productId: string, quantity: number): ProductResult<{ id: string }> {
    try {
      const { data, error } = await supabase
        .rpc("restock_product", { p_merchant_id: merchantId, p_product_id: productId, p_quantity: quantity })
        .maybeSingle<{ id: string }>()

      if (isCheckViolation(error)) {
        return {
          status: false,
          error: { code: ProductErrorCode.RESTOCK_QUANTITY_NOT_INTEGER, message: "Este produto é vendido por unidade: use um número inteiro." },
        }
      }
      if (error) {
        console.error("[ProductService.restock]", error)
        return { status: false, error: { code: ProductErrorCode.PRODUCT_RESTOCK_FAILED, message: "Erro ao repor o estoque." } }
      }
      if (!data) return { status: false, error: NOT_FOUND_ERROR }

      return { status: true, data: { id: data.id } }
    } catch (error) {
      console.error("[ProductService.restock] error:", error)
      return { status: false, error: { code: ProductErrorCode.PRODUCT_RESTOCK_FAILED, message: "Erro ao repor o estoque." } }
    }
  }

  // O app envia a imagem direto ao Storage por URL assinada, sem passar pela API
  // (que só aceita JSON pequeno), e depois confirma com updatePhoto
  async createPhotoUploadUrl(merchantId: string, productId: string, contentType: PhotoContentType): ProductResult<PhotoUploadTarget> {
    try {
      const productExists = await this.belongsToMerchant(merchantId, productId)
      if (!productExists) return { status: false, error: NOT_FOUND_ERROR }

      const path = `${this.photoFolder(merchantId, productId)}/${randomUUID()}.${PHOTO_EXTENSIONS[contentType]}`
      const [photo, thumb] = await Promise.all([this.createUploadTarget(path), this.createUploadTarget(this.thumbPathOf(path))])

      if (!photo || !thumb) {
        return { status: false, error: { code: ProductErrorCode.PHOTO_UPLOAD_URL_FAILED, message: "Erro ao preparar o envio da foto." } }
      }

      return { status: true, data: { ...photo, thumb } }
    } catch (error) {
      console.error("[ProductService.createPhotoUploadUrl] error:", error)
      return { status: false, error: { code: ProductErrorCode.PHOTO_UPLOAD_URL_FAILED, message: "Erro ao preparar o envio da foto." } }
    }
  }

  async updatePhoto(merchantId: string, productId: string, path: string): ProductResult<{ id: string }> {
    try {
      if (!this.isPhotoPathOf(merchantId, productId, path)) {
        return { status: false, error: { code: ProductErrorCode.PHOTO_PATH_INVALID, message: "Foto inválida para este produto." } }
      }

      const thumbPath = this.thumbPathOf(path)
      const [current, uploaded, thumbUploaded] = await Promise.all([
        supabase
          .from("products")
          .select("photo_path, thumb_path")
          .eq("id", productId)
          .eq("merchant_id", merchantId)
          .maybeSingle<Pick<ProductRow, "photo_path" | "thumb_path">>(),
        supabase.storage.from(PRODUCT_PHOTOS_BUCKET).exists(path),
        supabase.storage.from(PRODUCT_PHOTOS_BUCKET).exists(thumbPath),
      ])

      if (current.error) {
        console.error("[ProductService.updatePhoto]", current.error)
        return { status: false, error: { code: ProductErrorCode.PHOTO_UPDATE_FAILED, message: "Erro ao salvar a foto." } }
      }
      if (!current.data) return { status: false, error: NOT_FOUND_ERROR }
      if (!uploaded.data) {
        return { status: false, error: { code: ProductErrorCode.PHOTO_NOT_UPLOADED, message: "A foto ainda não foi enviada." } }
      }

      // Sem miniatura (falhou no aparelho ou app antigo), as listas usam a foto inteira
      const { error } = await supabase
        .from("products")
        .update({ photo_path: path, thumb_path: thumbUploaded.data ? thumbPath : null })
        .eq("id", productId)
        .eq("merchant_id", merchantId)
      if (error) {
        console.error("[ProductService.updatePhoto]", error)
        return { status: false, error: { code: ProductErrorCode.PHOTO_UPDATE_FAILED, message: "Erro ao salvar a foto." } }
      }

      await this.removeReplacedPhoto([current.data.photo_path, current.data.thumb_path], path)
      return { status: true, data: { id: productId } }
    } catch (error) {
      console.error("[ProductService.updatePhoto] error:", error)
      return { status: false, error: { code: ProductErrorCode.PHOTO_UPDATE_FAILED, message: "Erro ao salvar a foto." } }
    }
  }

  private async belongsToMerchant(merchantId: string, productId: string): Promise<boolean> {
    const { count, error } = await supabase
      .from("products")
      .select("id", { count: "exact", head: true })
      .eq("id", productId)
      .eq("merchant_id", merchantId)
    if (error) throw error
    return (count ?? 0) > 0
  }

  // Contagens das abas do estoque; ignoram a busca para os números não mudarem enquanto o usuário digita.
  // [skip] é a contagem que a própria página já traz
  private async countByStockLevel(merchantId: string, skip: StockCountKey | null): Promise<Partial<StockCounts>> {
    const base = () => supabase.from("products").select("id", { count: "exact", head: true }).eq("merchant_id", merchantId)
    const queries = {
      all: () => base(),
      low: () => base().gt("quantity", 0).lte("quantity", LOW_STOCK_THRESHOLD),
      out: () => base().lte("quantity", 0),
    }
    const entries = await Promise.all(
      STOCK_COUNT_KEYS.filter((key) => key !== skip).map(async (key) => {
        const { count, error } = await queries[key]()
        if (error) throw error
        return [key, count ?? 0] as const
      }),
    )
    return Object.fromEntries(entries)
  }

  private completeCounts(partial: Partial<StockCounts>, reusedKey: StockCountKey | null, pageCount: number): StockCounts {
    const counts = reusedKey ? { ...partial, [reusedKey]: pageCount } : partial
    return { all: counts.all ?? 0, low: counts.low ?? 0, out: counts.out ?? 0 }
  }

  // Filtro da página cujo total coincide com uma das contagens das abas
  private countKeyOf(stockLevel: ListProductsDTO["stockLevel"]): StockCountKey | null {
    return stockLevel === "attention" ? null : stockLevel
  }

  private stockLevelOf(quantity: number): StockLevel {
    if (quantity <= 0) return "out"
    if (quantity <= LOW_STOCK_THRESHOLD) return "low"
    return "ok"
  }

  private photoFolder(merchantId: string, productId: string): string {
    return `${merchantId}/${productId}`
  }

  // Só aceita caminhos gerados por createPhotoUploadUrl para este produto,
  // senão daria para apontar a foto para o arquivo de outra conta
  private isPhotoPathOf(merchantId: string, productId: string, path: string): boolean {
    const prefix = `${this.photoFolder(merchantId, productId)}/`
    const fileName = path.slice(prefix.length)
    return path.startsWith(prefix) && /^[0-9a-f-]{36}\.(jpg|png|webp)$/.test(fileName)
  }

  private thumbPathOf(photoPath: string): string {
    return photoPath.replace(/\.[a-z]+$/, PHOTO_THUMB_SUFFIX)
  }

  private async createUploadTarget(path: string): Promise<UploadTarget | null> {
    const { data, error } = await supabase.storage.from(PRODUCT_PHOTOS_BUCKET).createSignedUploadUrl(path)
    if (error || !data) {
      console.error("[ProductService.createUploadTarget]", error)
      return null
    }
    return { path: data.path, signedUrl: data.signedUrl, token: data.token }
  }

  // Falhar aqui só deixa arquivos órfãos no bucket; não vale desfazer a troca por isso
  private async removeReplacedPhoto(previousPaths: Array<string | null>, newPath: string): Promise<void> {
    const stale = previousPaths.filter((path): path is string => path !== null && path !== newPath)
    if (stale.length === 0) return
    const { error } = await supabase.storage.from(PRODUCT_PHOTOS_BUCKET).remove(stale)
    if (error) console.error("[ProductService.removeReplacedPhoto]", error)
  }

  private publicUrlOf(path: string | null): string | null {
    return path ? supabase.storage.from(PRODUCT_PHOTOS_BUCKET).getPublicUrl(path).data.publicUrl : null
  }

  private toRow(input: ProductDTO) {
    return {
      name: input.name,
      sale_price_cents: input.salePriceCents,
      cost_price_cents: input.costPriceCents,
      quantity: input.quantity,
      sold_by_weight: input.soldByWeight,
    }
  }

  private toProduct(row: ProductRow): Product {
    // numeric pode chegar como string dependendo da configuração do PostgREST
    const quantity = Number(row.quantity)
    return {
      id: row.id,
      name: row.name,
      photoUrl: this.publicUrlOf(row.photo_path),
      thumbUrl: this.publicUrlOf(row.thumb_path),
      salePriceCents: row.sale_price_cents,
      costPriceCents: row.cost_price_cents,
      quantity,
      soldByWeight: row.sold_by_weight,
      stockLevel: this.stockLevelOf(quantity),
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    }
  }
}

export default new ProductService()
