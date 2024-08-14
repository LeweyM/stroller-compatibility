export function parseQueryParams(queryParams: Record<string, any>) {
    return Object.entries(queryParams)
        .filter(([key, value]) => value !== undefined)
        .flatMap(([key, value]) => {
            if (Array.isArray(value)) {
                return value.map(v => `${encodeURIComponent(key)}[]=${encodeURIComponent(v)}`)
            }
            return `${encodeURIComponent(key)}=${encodeURIComponent(value)}`
        })
        .join('&')
}