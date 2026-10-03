export const queryKeys = {
  dashboardSummary: ['dashboard-summary'] as const,
  authMe: ['auth-me'] as const,
  tableData: (params: {
    page: number
    pageSize: number
    search?: string
    sortBy?: string
    sortOrder?: 'asc' | 'desc'
  }) => ['table-data', params] as const,
  eventTableData: (params: { page: number; pageSize: number }) => ['event-table-data', params] as const,
} as const
