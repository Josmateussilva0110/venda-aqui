import "express"

declare global {
  namespace Express {
    interface Request {
      // Preenchidos pelo authMiddleware a partir do access token
      merchantId?: string
      sessionId?: string
      // Preenchidos pelo portalAuthMiddleware, nas rotas do app do cliente
      portalAccountId?: string
      portalSessionId?: string
    }
  }
}

export {}
