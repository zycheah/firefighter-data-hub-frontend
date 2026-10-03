import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Menu, X } from 'lucide-react'
import { ROUTES } from '@/constants/routes'
import { cn } from '@/utils/cn'

const appName = import.meta.env.VITE_APP_NAME ?? 'AnalyticsApp'

export function Navbar() {
  const [scrolled, setScrolled] = useState(false)
  const [open, setOpen] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8)
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    if (open) document.body.style.overflow = 'hidden'
    else document.body.style.overflow = ''
    return () => {
      document.body.style.overflow = ''
    }
  }, [open])

  const linkClass =
    'block rounded-lg px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-800'

  return (
    <header
      className={cn(
        'sticky top-0 z-50 border-b border-transparent bg-white/90 backdrop-blur dark:bg-gray-950/90',
        scrolled && 'border-gray-200 shadow-sm dark:border-gray-800'
      )}
    >
      <nav className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-3 sm:px-6">
        <Link
          to={ROUTES.home}
          className="text-lg font-semibold text-gray-900 dark:text-white"
        >
          {appName}
        </Link>

        <div className="hidden items-center gap-3 md:flex">
          <Link
            to={ROUTES.login}
            className="rounded-lg border border-primary px-4 py-2 text-sm font-medium text-primary hover:bg-blue-50 dark:hover:bg-gray-900"
          >
            Login
          </Link>
          <Link
            to={ROUTES.register}
            className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-white hover:bg-primary-hover"
          >
            Sign Up
          </Link>
        </div>

        <button
          type="button"
          className="inline-flex rounded-lg p-2 text-gray-700 hover:bg-gray-100 md:hidden dark:text-gray-200 dark:hover:bg-gray-800"
          aria-label={open ? 'Close menu' : 'Open menu'}
          aria-expanded={open}
          onClick={() => setOpen((v) => !v)}
        >
          {open ? <X className="size-6" /> : <Menu className="size-6" />}
        </button>
      </nav>

      <div
        className={cn(
          'border-t border-gray-200 bg-white dark:border-gray-800 dark:bg-gray-950 md:hidden',
          open ? 'max-h-[80vh] overflow-y-auto shadow-lg' : 'max-h-0 overflow-hidden border-t-0'
        )}
      >
        <div className="flex flex-col gap-1 px-4 py-3">
          <Link to={ROUTES.login} className={linkClass} onClick={() => setOpen(false)}>
            Login
          </Link>
          <Link to={ROUTES.register} className={linkClass} onClick={() => setOpen(false)}>
            Sign Up
          </Link>
        </div>
      </div>
    </header>
  )
}
