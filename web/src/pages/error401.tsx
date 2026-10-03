import { Link } from 'react-router-dom'
import { ROUTES } from '@/constants/routes'

export default function Error401Page() {
  return (
    <div className="flex min-h-[calc(100svh-4rem)] flex-col items-center justify-center px-4 py-16">
      <div className="flex flex-col items-center gap-2 text-center">
        <span className="text-6xl font-bold tracking-tight text-gray-900 sm:text-5xl dark:text-white">
          Opps!!!
        </span>
        <p className="text-xl font-medium text-gray-900 dark:text-white">Something went wrong!</p>
        <p className="text-xl font-medium text-gray-900 dark:text-white">Try Logging in again.</p>
        <Link
          to={ROUTES.login}
          className="rounded-lg bg-primary px-5 py-2.5 font-medium text-white hover:bg-primary-hover"
        >
          Login
        </Link>
      </div>
    </div>
  )
}
