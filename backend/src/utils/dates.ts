export function addDays(date: Date, days: number): Date {
  return new Date(date.getTime() + days * 24 * 60 * 60 * 1000)
}

export function addMinutes(date: Date, minutes: number): Date {
  return new Date(date.getTime() + minutes * 60 * 1000)
}

export function isPast(isoDate: string | null): boolean {
  return isoDate !== null && new Date(isoDate).getTime() <= Date.now()
}

export function isFuture(isoDate: string | null): boolean {
  return isoDate !== null && new Date(isoDate).getTime() > Date.now()
}
