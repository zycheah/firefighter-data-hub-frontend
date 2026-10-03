export interface PaginatedResponse<T> {
  data: T[]
  total: number
  page: number
  pageSize: number
  totalPages: number
}

export interface TableQueryParams {
  page: number
  pageSize: number
  search?: string
  sortBy?: string
  sortOrder?: 'asc' | 'desc'
}

/** Row shape for location / exposure table (align with backend). */
export interface LocationTableRow {
  id: string
  user_id: string
  latitude: number
  longitude: number
  timestamp: string
  locationTimestamp: string
  altitude: number
}
