import { Link } from 'react-router-dom'
import { ForgotPasswordForm } from '@/features/auth/ForgotPasswordForm'
import { ROUTES } from '@/constants/routes'

export default function ForgotPasswordPage() {
  return (
    <div className="flex min-h-[calc(100svh-4rem)] items-center justify-center px-4 py-12">
      <div className="w-full max-w-md">
        <h1 className="mb-6 text-center text-2xl font-bold text-gray-900 dark:text-white">
          Forgot password
        </h1>
        <ForgotPasswordForm />
        <p className="mt-6 text-center text-sm text-gray-600 dark:text-gray-400">
          <Link to={ROUTES.login} className="font-medium text-primary hover:text-primary-hover">
            Back to login
          </Link>
        </p>
      </div>
    </div>
  )
}
