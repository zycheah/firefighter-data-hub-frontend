import { useQuery } from '@tanstack/react-query'
import { Building2, Flame, ShieldCheck } from 'lucide-react'
import { getDashboardSummary } from '@/api/dashboard.api'
import { queryKeys } from '@/constants/queryKeys'
import { KPICard } from '@/features/dashboard/KPICard'

export function DashboardStats() {
  const { data, isPending, isError, refetch, isFetching } = useQuery({
    queryKey: queryKeys.dashboardSummary,
    queryFn: getDashboardSummary,
  })

  if (isPending) {
    return (
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {[0, 1, 2].map((i) => (
          <div
            key={i}
            className="h-36 animate-pulse rounded-2xl bg-gray-200 dark:bg-gray-800"
          />
        ))}
      </div>
    )
  }

  if (isError || !data) {
    return (
      <div className="rounded-xl border border-red-200 bg-red-50 p-4 dark:border-red-900 dark:bg-red-950/40">
        <p className="text-sm font-medium text-danger">Could not load dashboard summary.</p>
        <button
          type="button"
          className="mt-3 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-white hover:bg-primary-hover disabled:opacity-60"
          onClick={() => refetch()}
          disabled={isFetching}
        >
          Retry
        </button>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
      <KPICard title="Total Firefighter Users" value={data.totalFirefighters} icon={Flame} />
      <KPICard title="Total Chief Users" value={data.totalChiefs} icon={ShieldCheck} />
      <KPICard title="Total Fire Stations" value={data.totalFireStations} icon={Building2} />
    </div>
  )
}
