import { Link, useSearchParams } from 'react-router-dom'
import { ResetPasswordForm } from '@/features/auth/ResetPasswordForm'
import { ROUTES } from '@/constants/routes'

export default function ResetPasswordPage() {
  const [params] = useSearchParams()
  const token = params.get('token') ?? ''

  if (!token) {
    return (
      <div className="flex min-h-[calc(100svh-4rem)] items-center justify-center px-4 py-12">
        <div className="w-full max-w-md rounded-2xl border border-red-200 bg-red-50 p-8 text-center dark:border-red-900 dark:bg-red-950/40">
          <p className="font-medium text-danger">Missing or invalid reset token.</p>
          <Link
            to={ROUTES.forgotPassword}
            className="mt-4 inline-block font-medium text-primary hover:text-primary-hover"
          >
            Request a new link
          </Link>
        </div>
      </div>
    )
  }

  return (
    <div className="flex min-h-[calc(100svh-4rem)] items-center justify-center px-4 py-12">
      <div className="w-full max-w-md">
        <h1 className="mb-6 text-center text-2xl font-bold text-gray-900 dark:text-white">
          Reset password
        </h1>
        <ResetPasswordForm token={token} />
      </div>
    </div>
  )
}
