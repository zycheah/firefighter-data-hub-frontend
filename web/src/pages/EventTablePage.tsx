import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { isAxiosError } from 'axios'
import { ROUTES } from '@/constants/routes'
import { queryKeys } from '@/constants/queryKeys'
import { useAuth } from '@/hooks/useAuth'
import { getEventTableData } from '@/api/eventTable.api'
import { EventDataTable } from '@/features/eventTable/EventDataTable'

export default function EventTablePage() {
  const { logout } = useAuth()

  // Lightweight auth-check: if token is invalid, backend will 401 and we redirect.
  const pingQuery = useQuery({
    queryKey: queryKeys.eventTableData({ page: 1, pageSize: 1 }),
    queryFn: () => getEventTableData({ page: 1, pageSize: 1 }),
  })

  useEffect(() => {
    if (!pingQuery.isError || !pingQuery.error) return
    if (!isAxiosError(pingQuery.error)) return
    const status = pingQuery.error.response?.status
    if (status !== 401 && status !== 403) return
    logout()
    window.location.assign(ROUTES.error401)
  }, [pingQuery.isError, pingQuery.error, logout])

  return (
    <div>
      <div className="mb-6 flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Event Table</h1>
          <p className="mt-1 text-gray-600 dark:text-gray-400">
            Browse paginated log events. Export the full dataset as CSV.
          </p>
        </div>
      </div>
      <EventDataTable />
    </div>
  )
}

