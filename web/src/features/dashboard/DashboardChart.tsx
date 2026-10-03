import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import type { DashboardSummary } from '@/types/dashboard.types'

interface DashboardChartProps {
  summary: DashboardSummary
}

export function DashboardChart({ summary }: DashboardChartProps) {
  const data = [
    { name: 'Firefighters', value: summary.totalFirefighters },
    { name: 'Chiefs', value: summary.totalChiefs },
    { name: 'Stations', value: summary.totalFireStations },
  ]

  return (
    <div className="mt-8 rounded-2xl border border-gray-200 bg-white p-4 shadow-md dark:border-gray-700 dark:bg-gray-800 sm:p-6">
      <h2 className="mb-4 text-lg font-semibold text-gray-900 dark:text-white">Overview</h2>
      <div className="h-64 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" className="stroke-gray-200 dark:stroke-gray-700" />
            <XAxis dataKey="name" tick={{ fill: 'currentColor', fontSize: 12 }} />
            <YAxis tick={{ fill: 'currentColor', fontSize: 12 }} allowDecimals={false} />
            <Tooltip
              contentStyle={{
                borderRadius: 8,
                border: '1px solid #e5e7eb',
              }}
            />
            <Bar dataKey="value" fill="#2563eb" radius={[6, 6, 0, 0]} name="Count" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}
