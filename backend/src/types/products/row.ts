// Linha da tabela products como vem do Supabase, antes de virar Product
export interface ProductRow {
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
