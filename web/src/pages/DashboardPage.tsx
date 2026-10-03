import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { isAxiosError } from 'axios'
import { getDashboardSummary } from '@/api/dashboard.api'
import { ROUTES } from '@/constants/routes'
import { queryKeys } from '@/constants/queryKeys'
import { useAuth } from '@/hooks/useAuth'
import { DashboardChart } from '@/features/dashboard/DashboardChart'
import { DashboardStats } from '@/features/dashboard/DashboardStats'

export default function DashboardPage() {
  const { logout } = useAuth()
  const summaryQuery = useQuery({
    queryKey: queryKeys.dashboardSummary,
    queryFn: getDashboardSummary,
  })

  useEffect(() => {
    if (!summaryQuery.isError || !summaryQuery.error) return
    if (!isAxiosError(summaryQuery.error)) return
    const status = summaryQuery.error.response?.status
    if (status !== 401 && status !== 403) return
    logout()
    window.location.assign(ROUTES.error401)
  }, [summaryQuery.isError, summaryQuery.error, logout])

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Dashboard</h1>
      <p className="mt-1 text-gray-600 dark:text-gray-400">Summary metrics for your organization.</p>
      <div className="mt-8">
        <DashboardStats />
      </div>
      {summaryQuery.data && <DashboardChart summary={summaryQuery.data} />}
    </div>
  )
}
