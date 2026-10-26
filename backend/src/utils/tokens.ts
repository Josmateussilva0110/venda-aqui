import { createHash, randomBytes, randomInt, timingSafeEqual } from "node:crypto"
import jwt from "jsonwebtoken"
import { env } from "../config/env"
import { ACCESS_TOKEN_TTL_SECONDS } from "../constants/auth"

const JWT_ISSUER = "vendaqui-api"
const JWT_ALGORITHM = "HS256"

export interface AccessTokenClaims {
  merchantId: string
  sessionId: string
}

export function signAccessToken(claims: AccessTokenClaims): string {
  return jwt.sign({ sid: claims.sessionId }, env.JWT_SECRET, {
    subject: claims.merchantId,
    issuer: JWT_ISSUER,
    algorithm: JWT_ALGORITHM,
    expiresIn: ACCESS_TOKEN_TTL_SECONDS,
  })
}

export function verifyAccessToken(token: string): AccessTokenClaims | null {
  try {
    // Fixar o algoritmo impede o truque de trocar o "alg" do cabeçalho
    const payload = jwt.verify(token, env.JWT_SECRET, { issuer: JWT_ISSUER, algorithms: [JWT_ALGORITHM] })
    if (typeof payload === "string" || !payload.sub || typeof payload.sid !== "string") return null
    return { merchantId: payload.sub, sessionId: payload.sid }
  } catch {
    return null
  }
}

export function generateRefreshToken(): string {
  return randomBytes(48).toString("base64url")
}

// Refresh token e código de recuperação têm entropia alta ou vida curta,
// então SHA-256 basta; bcrypt aqui só tornaria a busca por hash impossível
export function hashSecret(value: string): string {
  return createHash("sha256").update(value).digest("hex")
}

export function secretMatchesHash(value: string, hash: string): boolean {
  const expected = Buffer.from(hash, "hex")
  const actual = Buffer.from(hashSecret(value), "hex")
  return expected.length === actual.length && timingSafeEqual(expected, actual)
}

export function generateNumericCode(length: number): string {
  return Array.from({ length }, () => randomInt(0, 10)).join("")
}
