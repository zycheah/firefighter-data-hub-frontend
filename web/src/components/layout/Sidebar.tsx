import { useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import { LayoutDashboard, PanelLeftClose, PanelLeft, Table2, ListChecks } from 'lucide-react'
import { ROUTES } from '@/constants/routes'
import { cn } from '@/utils/cn'

const appName = import.meta.env.VITE_APP_NAME ?? 'AnalyticsApp'

const links = [
  { to: ROUTES.dashboard, label: 'Dashboard', icon: LayoutDashboard },
  { to: ROUTES.table, label: 'Table View', icon: Table2 },
  { to: ROUTES.eventTable, label: 'Event Table', icon: ListChecks },
] as const

export function Sidebar() {
  const [collapsed, setCollapsed] = useState(false)
  const location = useLocation()

  return (
    <aside
      className={cn(
        'flex shrink-0 flex-col border-r border-gray-200 bg-white transition-[width] dark:border-gray-800 dark:bg-gray-900',
        collapsed ? 'w-[72px]' : 'w-56'
      )}
    >
      <div className="flex h-14 items-center justify-between gap-2 border-b border-gray-200 px-3 dark:border-gray-800">
        {!collapsed && (
          <span className="truncate text-sm font-semibold text-gray-900 dark:text-white">
            {appName}
          </span>
        )}
        <button
          type="button"
          onClick={() => setCollapsed((c) => !c)}
          className="rounded-lg p-2 text-gray-600 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800"
          aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          {collapsed ? <PanelLeft className="size-5" /> : <PanelLeftClose className="size-5" />}
        </button>
      </div>
      <nav className="flex flex-1 flex-col gap-1 p-2">
        {links.map(({ to, label, icon: Icon }) => {
          const active = location.pathname === to
          return (
            <Link
              key={to}
              to={to}
              className={cn(
                'flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors',
                active
                  ? 'bg-blue-50 text-primary dark:bg-blue-950/40 dark:text-blue-300'
                  : 'text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-800'
              )}
              title={collapsed ? label : undefined}
            >
              <Icon className="size-5 shrink-0" aria-hidden />
              {!collapsed && <span>{label}</span>}
            </Link>
          )
        })}
      </nav>
    </aside>
  )
}
