import type { PostgrestError } from "@supabase/supabase-js"

export function isUniqueViolation(error: unknown): boolean {
  return (error as PostgrestError | null)?.code === "23505"
}

// Escapa os curingas do LIKE para a busca tratar "%" e "_" digitados como texto
export function escapeLikePattern(value: string): string {
  return value.replace(/[\\%_]/g, (char) => `\\${char}`)
}

export function isCheckViolation(error: unknown): boolean {
  return (error as PostgrestError | null)?.code === "23514"
}
