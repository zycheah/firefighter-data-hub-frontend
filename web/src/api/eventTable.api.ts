import { axiosInstance } from '@/api/axiosInstance'
import type { PaginatedResponse } from '@/types/table.types'
import type { EventTableQueryParams, EventTableRow } from '@/types/eventTable.types'

type LegacyEventResponse = {
  results?: EventTableRow[]
  count?: number
}

type SpecEventResponse = {
  data?: EventTableRow[]
  total?: number
}

export async function getEventTableData(
  params: EventTableQueryParams
): Promise<PaginatedResponse<EventTableRow>> {
  const { page, pageSize } = params

  const { data: raw } = await axiosInstance.get<LegacyEventResponse & SpecEventResponse>(
    '/table/eventdata',
    {
      params: {
        page,
        limit: pageSize,
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

export async function downloadEventCSV(): Promise<void> {
  const response = await axiosInstance.get('/table/export-event-data', {
    responseType: 'blob',
  })
  const url = window.URL.createObjectURL(new Blob([response.data]))
  const link = document.createElement('a')
  link.href = url
  link.setAttribute('download', 'event-data.csv')
  document.body.appendChild(link)
  link.click()
  link.remove()
  window.URL.revokeObjectURL(url)
}

