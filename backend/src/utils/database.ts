import type { PostgrestError } from "@supabase/supabase-js"

export function isUniqueViolation(error: unknown): boolean {
  return (error as PostgrestError | null)?.code === "23505"
}

// Qual índice único recusou ("... violates unique constraint \"nome\""), para dizer ao usuário qual campo repetiu
export function isUniqueViolationOf(error: unknown, constraint: string): boolean {
  return isUniqueViolation(error) && ((error as PostgrestError).message ?? "").includes(`"${constraint}"`)
}

// Escapa os curingas do LIKE para a busca tratar "%" e "_" digitados como texto
export function escapeLikePattern(value: string): string {
  return value.replace(/[\\%_]/g, (char) => `\\${char}`)
}

// Chave estrangeira com restrict: o registro ainda é usado por outra tabela
export function isForeignKeyViolation(error: unknown): boolean {
  return (error as PostgrestError | null)?.code === "23503"
}

export function isCheckViolation(error: unknown): boolean {
  return (error as PostgrestError | null)?.code === "23514"
}
