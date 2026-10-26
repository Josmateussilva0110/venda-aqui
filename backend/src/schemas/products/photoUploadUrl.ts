import { z } from "zod"
import { PHOTO_EXTENSIONS, type PhotoContentType } from "../../constants/storage"

const contentTypes = Object.keys(PHOTO_EXTENSIONS) as [PhotoContentType, ...PhotoContentType[]]

export const PhotoUploadUrlSchema = z.object({
  contentType: z.enum(contentTypes, { error: "Formato de imagem não suportado. Use JPEG, PNG ou WebP." }),
})

export type PhotoUploadUrlDTO = z.infer<typeof PhotoUploadUrlSchema>
