import type { LucideIcon } from 'lucide-react'
import { cn } from '@/utils/cn'

/** TODO: Replace placeholder trend with API fields when backend exposes month-over-month deltas. */
interface KPICardProps {
  title: string
  value: number
  icon: LucideIcon
  trendPercent?: number
}

export function KPICard({ title, value, icon: Icon, trendPercent = 12 }: KPICardProps) {
  const positive = trendPercent >= 0
  return (
    <div className="flex flex-col gap-2 rounded-2xl bg-white p-6 shadow-md dark:bg-gray-800">
      <div className="flex items-center justify-between gap-3">
        <span className="text-sm font-medium text-gray-600 dark:text-gray-300">{title}</span>
        <span className="flex size-10 items-center justify-center rounded-xl bg-blue-50 text-primary dark:bg-blue-950/50 dark:text-blue-300">
          <Icon className="size-5" aria-hidden />
        </span>
      </div>
      <p className="text-4xl font-bold text-gray-900 dark:text-white">
        {value.toLocaleString()}
      </p>
      <p
        className={cn(
          'text-sm font-medium',
          positive ? 'text-success' : 'text-danger'
        )}
      >
        {positive ? '↑' : '↓'} {Math.abs(trendPercent)}% from last month (placeholder)
      </p>
    </div>
  )
}
