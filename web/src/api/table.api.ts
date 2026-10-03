import { axiosInstance } from '@/api/axiosInstance'
import type { LocationTableRow, PaginatedResponse, TableQueryParams } from '@/types/table.types'

/** Raw API may return spec shape or legacy `{ results, count }`. */
type LegacyTableResponse = {
  results?: LocationTableRow[]
  count?: number
}

type SpecTableResponse = {
  data?: LocationTableRow[]
  total?: number
  page?: number
  pageSize?: number
  totalPages?: number
}

export async function getTableData(
  params: TableQueryParams
): Promise<PaginatedResponse<LocationTableRow>> {
  const { page, pageSize, search, sortBy, sortOrder } = params

  const { data: raw } = await axiosInstance.get<LegacyTableResponse & SpecTableResponse>(
    '/data/tabledata',
    {
      params: {
        page,
        limit: pageSize,
        search,
        sortBy,
        sortOrder,
      },
    }
  )

  const rows = Array.isArray(raw.data)
    ? raw.data
    : Array.isArray(raw.results)
      ? raw.results
      : []

  const total = Number(raw.total ?? raw.count ?? rows.length)
  const totalPages = Math.max(1, Math.ceil(total / pageSize))

  return {
    data: rows,
    total,
    page,
    pageSize,
    totalPages,
  }
}

export async function downloadCSV(): Promise<void> {
  const response = await axiosInstance.get('/table/export-csv', {
    responseType: 'blob',
  })
  const url = window.URL.createObjectURL(new Blob([response.data]))
  const link = document.createElement('a')
  link.href = url
  link.setAttribute('download', 'data-export.csv')
  document.body.appendChild(link)
  link.click()
  link.remove()
  window.URL.revokeObjectURL(url)
}
