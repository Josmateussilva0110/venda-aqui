import "express"

declare global {
  namespace Express {
    interface Request {
      // Preenchidos pelo authMiddleware a partir do access token
      merchantId?: string
      sessionId?: string
    }
  }
}

export {}
