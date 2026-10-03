import { Link } from 'react-router-dom'
import { Moon, Sun } from 'lucide-react'
import { ROUTES } from '@/constants/routes'
import { useTheme } from '@/hooks/useTheme'

const appName = import.meta.env.VITE_APP_NAME ?? 'AnalyticsApp'

export function Footer() {
  const { dark, toggle } = useTheme()
  const year = new Date().getFullYear()

  return (
    <footer className="bg-gray-900 text-gray-300">
      <div className="mx-auto grid max-w-6xl gap-10 px-4 py-12 sm:grid-cols-3 sm:px-6">
        <div>
          <h3 className="mb-3 text-sm font-semibold uppercase tracking-wide text-white">
            Contact
          </h3>
          <p className="text-sm">support@example.edu</p>
          <p className="text-sm">+1 (555) 000-0000</p>
        </div>
        <div>
          <h3 className="mb-3 text-sm font-semibold uppercase tracking-wide text-white">
            About Us
          </h3>
          <p className="mb-3 text-sm leading-relaxed">
            {appName} connects researchers with firefighter exposure data in one secure hub.
          </p>
          <Link
            to={ROUTES.about}
            className="text-sm font-medium text-white underline-offset-2 hover:underline"
          >
            Learn more
          </Link>
        </div>
        <div>
          <h3 className="mb-3 text-sm font-semibold uppercase tracking-wide text-white">
            Quick Links
          </h3>
          <ul className="space-y-2 text-sm">
            <li>
              <Link to={ROUTES.home} className="hover:text-white">
                Home
              </Link>
            </li>
            <li>
              <Link to={ROUTES.dashboard} className="hover:text-white">
                Dashboard
              </Link>
            </li>
            <li>
              <Link to={ROUTES.download} className="hover:text-white">
                Download
              </Link>
            </li>
            <li>
              <span className="cursor-not-allowed opacity-60">Privacy Policy</span>
            </li>
          </ul>
        </div>
      </div>
      <div className="border-t border-gray-800">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-4 py-4 sm:px-6">
          <p className="text-xs text-gray-400">
            © {year} {appName}. All rights reserved.
          </p>
          <button
            type="button"
            onClick={toggle}
            className="rounded-lg p-2 text-gray-300 hover:bg-gray-800 hover:text-white"
            aria-label={dark ? 'Switch to light mode' : 'Switch to dark mode'}
          >
            {dark ? <Sun className="size-5" /> : <Moon className="size-5" />}
          </button>
        </div>
      </div>
    </footer>
  )
}
