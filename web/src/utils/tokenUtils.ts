/** Reads Bearer token from Authorization header value. */
export function parseBearerToken(header: string | undefined): string | null {
  if (!header?.startsWith('Bearer ')) return null
  return header.slice(7).trim() || null
}
