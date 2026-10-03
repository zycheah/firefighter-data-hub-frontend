import { Link } from 'react-router-dom'
import { CheckCircle2 } from 'lucide-react'
import { ROUTES } from '@/constants/routes'

export default function EmailVerifiedPage() {
  return (
    <div className="flex min-h-[calc(100svh-4rem)] items-center justify-center px-4 py-16">
      <div className="w-full max-w-md rounded-2xl border border-gray-200 bg-white p-10 text-center shadow-sm dark:border-gray-700 dark:bg-gray-900">
        <CheckCircle2 className="mx-auto size-20 text-green-500" aria-hidden />
        <h1 className="mt-6 text-2xl font-bold text-gray-900">Email Verified Successfully!</h1>
        <p className="mt-3 text-gray-600 dark:text-gray-300">
          Your account is now active. You can now log in.
        </p>
        <Link
          to={ROUTES.login}
          className="mt-8 inline-flex rounded-lg bg-primary px-6 py-3 font-medium text-white hover:bg-primary-hover"
        >
          Go to Login
        </Link>
      </div>
    </div>
  )
}
