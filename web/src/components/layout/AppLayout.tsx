import { useEffect, useRef, useState } from 'react'
import { Link, Outlet, useNavigate } from 'react-router-dom'
import { ChevronDown } from 'lucide-react'
import { Sidebar } from '@/components/layout/Sidebar'
import { ROUTES } from '@/constants/routes'
import { useAuth } from '@/hooks/useAuth'

const appName = import.meta.env.VITE_APP_NAME ?? 'AnalyticsApp'

function initials(first?: string, last?: string) {
  const a = first?.charAt(0) ?? ''
  const b = last?.charAt(0) ?? ''
  return (a + b).toUpperCase() || '?'
}

export function AppLayout() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [open, setOpen] = useState(false)
  const menuRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    const close = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setOpen(false)
      }
    }
    document.addEventListener('mousedown', close)
    return () => document.removeEventListener('mousedown', close)
  }, [open])

  return (
    <div className="flex min-h-svh bg-gray-50 dark:bg-gray-950">
      <Sidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-14 items-center justify-between border-b border-gray-200 bg-white px-4 dark:border-gray-800 dark:bg-gray-900 sm:px-6">
          <Link
            to={ROUTES.dashboard}
            className="text-sm font-semibold text-gray-900 dark:text-white md:hidden"
          >
            {appName}
          </Link>
          <span className="hidden text-sm font-semibold text-gray-900 dark:text-white md:inline">
            {appName}
          </span>
          <div className="relative" ref={menuRef}>
            <button
              type="button"
              className="flex items-center gap-2 rounded-full border border-gray-200 bg-white p-1 pr-2 text-left dark:border-gray-700 dark:bg-gray-800"
              aria-haspopup="menu"
              aria-expanded={open}
              onClick={() => setOpen((o) => !o)}
            >
              <span className="flex size-9 items-center justify-center rounded-full bg-primary text-sm font-semibold text-white">
                {initials(user?.firstName, user?.lastName)}
              </span>
              <ChevronDown className="size-4 text-gray-500" aria-hidden />
            </button>
            {open && (
              <div
                role="menu"
                className="absolute right-0 z-50 mt-2 w-48 rounded-xl border border-gray-200 bg-white py-1 shadow-lg dark:border-gray-700 dark:bg-gray-900"
              >
                <button
                  type="button"
                  role="menuitem"
                  className="block w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 dark:text-gray-200 dark:hover:bg-gray-800"
                  onClick={() => {
                    setOpen(false)
                    navigate(ROUTES.profile)
                  }}
                >
                  Profile
                </button>
                <button
                  type="button"
                  role="menuitem"
                  className="block w-full px-4 py-2 text-left text-sm text-danger hover:bg-red-50 dark:hover:bg-red-950/30"
                  onClick={() => {
                    setOpen(false)
                    logout()
                    window.location.assign(ROUTES.login)
                  }}
                >
                  Logout
                </button>
              </div>
            )}
          </div>
        </header>
        <div className="flex-1 overflow-auto p-4 sm:p-6">
          <Outlet />
        </div>
      </div>
    </div>
  )
}
