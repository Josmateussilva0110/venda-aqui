import { createClient } from "@supabase/supabase-js"
import { env } from "./env"

// A autenticação é própria (telefone + PIN), então não existe usuário do Supabase Auth
// para o RLS avaliar. Este cliente ignora o RLS: todo acesso a dado de comerciante
// precisa filtrar por merchant_id vindo do token, nunca do corpo ou da URL.
export const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SECRET_KEY, {
  auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false },
})
