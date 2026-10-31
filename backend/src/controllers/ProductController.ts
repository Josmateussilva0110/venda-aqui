import type { Request, Response } from "express"
import { productErrorHttpStatusMap } from "../errors/products"
import type { ListProductsDTO } from "../schemas/products/listProducts"
import type { PhotoDTO } from "../schemas/products/photo"
import type { PhotoUploadUrlDTO } from "../schemas/products/photoUploadUrl"
import type { ProductDTO } from "../schemas/products/product"
import type { ProductParamsDTO } from "../schemas/products/productParams"
import type { RestockDTO } from "../schemas/products/restock"
import ProductService from "../services/ProductService"
import { sendFailure } from "../utils/sendFailure"
import { sendSuccess } from "../utils/sendSuccess"
import { requireAuthField } from "../utils/requireAuthField"

class ProductController {
  async list(request: Request, response: Response): Promise<Response> {
    const result = await ProductService.list(requireAuthField(request, "merchantId"), request.query as unknown as ListProductsDTO)
    if (!result.status) return sendFailure(response, result.error, productErrorHttpStatusMap)
    return sendSuccess(response, "Produtos carregados.", result.data)
  }

  async get(request: Request<ProductParamsDTO>, response: Response): Promise<Response> {
    const result = await ProductService.get(requireAuthField(request, "merchantId"), request.params.id)
    if (!result.status) return sendFailure(response, result.error, productErrorHttpStatusMap)
    return sendSuccess(response, "Produto carregado.", result.data)
  }

  async create(request: Request<unknown, unknown, ProductDTO>, response: Response): Promise<Response> {
    const result = await ProductService.create(requireAuthField(request, "merchantId"), request.body)
    if (!result.status) return sendFailure(response, result.error, productErrorHttpStatusMap)
    return sendSuccess(response, "Produto cadastrado com sucesso.", result.data, 201)
  }

  async update(request: Request<ProductParamsDTO, unknown, ProductDTO>, response: Response): Promise<Response> {
    const result = await ProductService.update(requireAuthField(request, "merchantId"), request.params.id, request.body)
    if (!result.status) return sendFailure(response, result.error, productErrorHttpStatusMap)
    return sendSuccess(response, "Produto atualizado com sucesso.", result.data)
  }

  async restock(request: Request<ProductParamsDTO, unknown, RestockDTO>, response: Response): Promise<Response> {
    const result = await ProductService.restock(requireAuthField(request, "merchantId"), request.params.id, request.body.quantity)
    if (!result.status) return sendFailure(response, result.error, productErrorHttpStatusMap)
    return sendSuccess(response, "Estoque atualizado.", result.data)
  }

  async createPhotoUploadUrl(request: Request<ProductParamsDTO, unknown, PhotoUploadUrlDTO>, response: Response): Promise<Response> {
    const result = await ProductService.createPhotoUploadUrl(requireAuthField(request, "merchantId"), request.params.id, request.body.contentType)
    if (!result.status) return sendFailure(response, result.error, productErrorHttpStatusMap)
    return sendSuccess(response, "Envie a foto para a URL indicada.", result.data)
  }

  async updatePhoto(request: Request<ProductParamsDTO, unknown, PhotoDTO>, response: Response): Promise<Response> {
    const result = await ProductService.updatePhoto(requireAuthField(request, "merchantId"), request.params.id, request.body.path)
    if (!result.status) return sendFailure(response, result.error, productErrorHttpStatusMap)
    return sendSuccess(response, "Foto atualizada com sucesso.", result.data)
  }
}

export default new ProductController()
