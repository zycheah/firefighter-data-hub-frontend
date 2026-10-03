import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useMutation } from '@tanstack/react-query'
import { XCircle } from 'lucide-react'
import toast from 'react-hot-toast'
import { resendVerification } from '@/api/auth.api'
import { ROUTES } from '@/constants/routes'
import { LoadingSpinner } from '@/components/shared/LoadingSpinner'

export default function EmailVerificationFailedPage() {
  const [email, setEmail] = useState('')
  const mutation = useMutation({
    mutationFn: () => resendVerification(email.trim()),
    onSuccess: () => toast.success('If eligible, a new verification email will be sent.'),
    onError: () => toast.error('Could not resend verification. Check your email and try again.'),
  })

  return (
    <div className="flex min-h-[calc(100svh-4rem)] items-center justify-center px-4 py-16">
      <div className="w-full max-w-md rounded-2xl border border-gray-200 bg-white p-10 text-center shadow-sm dark:border-gray-700 dark:bg-gray-900">
        <XCircle className="mx-auto size-20 text-red-500" aria-hidden />
        <h1 className="mt-6 text-2xl font-bold text-gray-900 dark:text-white">Verification Failed</h1>
        <p className="mt-3 text-gray-600 dark:text-gray-300">
          Your verification link may have expired or is invalid.
        </p>
        <div className="mt-6 text-left">
          <label htmlFor="resend-email" className="text-sm font-medium text-gray-700 dark:text-gray-200">
            University email
          </label>
          <input
            id="resend-email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@university.edu"
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 dark:border-gray-600 dark:bg-gray-950 dark:text-white"
          />
        </div>
        <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:justify-center">
          <button
            type="button"
            disabled={mutation.isPending || !email.trim()}
            onClick={() => mutation.mutate()}
            className="inline-flex items-center justify-center gap-2 rounded-lg border border-gray-300 px-4 py-2.5 font-medium hover:bg-gray-50 disabled:opacity-50 dark:border-gray-600 dark:hover:bg-gray-800"
          >
            {mutation.isPending && <LoadingSpinner className="size-4" />}
            Resend Verification Email
          </button>
          <Link
            to={ROUTES.login}
            className="inline-flex items-center justify-center rounded-lg bg-primary px-4 py-2.5 font-medium text-white hover:bg-primary-hover"
          >
            Go to Login
          </Link>
        </div>
      </div>
    </div>
  )
}
