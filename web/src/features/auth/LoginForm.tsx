import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation } from '@tanstack/react-query'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { Eye, EyeOff } from 'lucide-react'
import { z } from 'zod'
import { login as loginApi } from '@/api/auth.api'
import { ROUTES } from '@/constants/routes'
import { useAuth } from '@/hooks/useAuth'
import { LoadingSpinner } from '@/components/shared/LoadingSpinner'
import { cn } from '@/utils/cn'
import type { Location } from 'react-router-dom'

const loginSchema = z.object({
  email: z.string().min(1, 'Email is required').email('Enter a valid email'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
})

export type LoginFormValues = z.infer<typeof loginSchema>

function getRedirectPath(state: unknown): string {
  const from = (state as { from?: Location })?.from?.pathname
  return from && from !== ROUTES.login ? from : ROUTES.dashboard
}

export function LoginForm() {
  const [showPassword, setShowPassword] = useState(false)
  const navigate = useNavigate()
  const location = useLocation()
  const { login } = useAuth()

  const {
    register,
    handleSubmit,
    formState: { errors },
    setError,
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: '', password: '' },
  })

  const mutation = useMutation({
    mutationFn: loginApi,
    onSuccess: (data) => {
      login(data)
      navigate(getRedirectPath(location.state), { replace: true })
    },
    onError: (err: unknown) => {
      const message =
        err && typeof err === 'object' && 'response' in err
          ? String(
              (
                err as {
                  response?: { data?: { message?: string; detail?: string } }
                }
              ).response?.data?.message ??
                (
                  err as {
                    response?: { data?: { message?: string; detail?: string } }
                  }
                ).response?.data?.detail ??
                'Login failed'
            )
          : 'Login failed'
      setError('root', { message })
    },
  })

  return (
    <form
      onSubmit={handleSubmit((values) => mutation.mutate(values))}
      className="flex w-full max-w-md flex-col gap-5"
      noValidate
    >
      {errors.root && (
        <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-danger dark:bg-red-950/40">
          {errors.root.message}
        </p>
      )}

      <div className="flex flex-col gap-2">
        <label htmlFor="login-email" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Email Address
        </label>
        <input
          id="login-email"
          type="email"
          autoComplete="email"
          placeholder="you@university.edu"
          className={cn(
            'rounded-lg border px-3 py-2 text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:bg-gray-900 dark:text-white',
            errors.email ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
          )}
          {...register('email')}
        />
        {errors.email && (
          <p className="text-sm text-danger" role="alert">
            {errors.email.message}
          </p>
        )}
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="login-password" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Password
        </label>
        <div className="relative">
          <input
            id="login-password"
            type={showPassword ? 'text' : 'password'}
            autoComplete="current-password"
            className={cn(
              'w-full rounded-lg border px-3 py-2 pr-10 text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:bg-gray-900 dark:text-white',
              errors.password ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
            )}
            {...register('password')}
          />
          <button
            type="button"
            className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-1 text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800"
            aria-label={showPassword ? 'Hide password' : 'Show password'}
            onClick={() => setShowPassword((s) => !s)}
          >
            {showPassword ? <EyeOff className="size-5" /> : <Eye className="size-5" />}
          </button>
        </div>
        {errors.password && (
          <p className="text-sm text-danger" role="alert">
            {errors.password.message}
          </p>
        )}
        <div className="text-right">
          <Link
            to={ROUTES.forgotPassword}
            className="text-sm font-medium text-primary hover:text-primary-hover"
          >
            Forgot Password?
          </Link>
        </div>
      </div>

      <button
        type="submit"
        disabled={mutation.isPending}
        className="flex items-center justify-center gap-2 rounded-lg bg-primary py-2.5 font-medium text-white hover:bg-primary-hover disabled:opacity-60"
      >
        {mutation.isPending && <LoadingSpinner className="size-4 border-white border-t-transparent" />}
        Sign in
      </button>

      <p className="text-center text-sm text-gray-600 dark:text-gray-400">
        Don&apos;t have an account?{' '}
        <Link to={ROUTES.register} className="font-medium text-primary hover:text-primary-hover">
          Sign Up
        </Link>
      </p>
    </form>
  )
}
