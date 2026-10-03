import { Link } from 'react-router-dom'
import { ROUTES } from '@/constants/routes'

export function NotFound() {
  return (
    <div className="flex min-h-svh flex-col items-center justify-center gap-4 bg-white p-6 dark:bg-gray-950">
      <p className="text-9xl font-black text-blue-100 dark:text-gray-700">404</p>
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Page Not Found</h1>
      <p className="max-w-md text-center text-gray-600 dark:text-gray-300">
        The page you&apos;re looking for doesn&apos;t exist or has been moved.
      </p>
      <Link
        to={ROUTES.home}
        className="rounded-lg bg-primary px-5 py-2.5 font-medium text-white hover:bg-primary-hover"
      >
        Back to Home
      </Link>
    </div>
  )
}
