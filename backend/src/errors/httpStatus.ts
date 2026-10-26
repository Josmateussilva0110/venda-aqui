export function getHttpStatusFromError<E extends string>(code: E, statusMap: Record<E, number>): number {
  return statusMap[code] ?? 500
}
