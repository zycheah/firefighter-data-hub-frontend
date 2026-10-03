import { useMemo, useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import { Eye, EyeOff } from 'lucide-react'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { resetPassword } from '@/api/auth.api'
import { ROUTES } from '@/constants/routes'
import { LoadingSpinner } from '@/components/shared/LoadingSpinner'
import { cn } from '@/utils/cn'

const schema = z
  .object({
    newPassword: z.string().min(8, 'At least 8 characters'),
    confirmPassword: z.string().min(1, 'Required'),
  })
  .refine((d) => d.newPassword === d.confirmPassword, {
    message: 'Passwords must match',
    path: ['confirmPassword'],
  })

type Values = z.infer<typeof schema>

function passwordStrength(password: string): 'weak' | 'medium' | 'strong' {
  if (password.length < 8) return 'weak'
  const hasNum = /\d/.test(password)
  const hasSpecial = /[^A-Za-z0-9]/.test(password)
  const hasUpper = /[A-Z]/.test(password)
  if (password.length >= 8 && hasNum && hasSpecial && hasUpper) return 'strong'
  if (password.length >= 8 && (hasNum || hasSpecial)) return 'medium'
  return 'weak'
}

interface ResetPasswordFormProps {
  token: string
}

export function ResetPasswordForm({ token }: ResetPasswordFormProps) {
  const navigate = useNavigate()
  const [showNew, setShowNew] = useState(false)
  const [showConfirm, setShowConfirm] = useState(false)

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm<Values>({
    resolver: zodResolver(schema),
    defaultValues: { newPassword: '', confirmPassword: '' },
  })

  const pwd = watch('newPassword')
  const strength = useMemo(() => passwordStrength(pwd || ''), [pwd])

  const mutation = useMutation({
    mutationFn: (newPassword: string) => resetPassword({ token, newPassword }),
    onSuccess: () => {
      toast.success('Password reset successful!')
      window.setTimeout(() => navigate(ROUTES.login, { replace: true }), 2000)
    },
  })

  const barColor =
    strength === 'strong'
      ? 'bg-success'
      : strength === 'medium'
        ? 'bg-warning'
        : 'bg-danger'

  return (
    <form
      onSubmit={handleSubmit((v) => mutation.mutate(v.newPassword))}
      className="flex w-full max-w-md flex-col gap-4 rounded-2xl border border-gray-200 bg-white p-8 shadow-sm dark:border-gray-700 dark:bg-gray-900"
      noValidate
    >
      <div className="flex flex-col gap-2">
        <label htmlFor="np" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          New Password
        </label>
        <div className="relative">
          <input
            id="np"
            type={showNew ? 'text' : 'password'}
            className={cn(
              'w-full rounded-lg border px-3 py-2 pr-10 dark:bg-gray-950 dark:text-white',
              errors.newPassword ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
            )}
            {...register('newPassword')}
          />
          <button
            type="button"
            className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-1 text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800"
            aria-label={showNew ? 'Hide password' : 'Show password'}
            onClick={() => setShowNew((s) => !s)}
          >
            {showNew ? <EyeOff className="size-5" /> : <Eye className="size-5" />}
          </button>
        </div>
        {errors.newPassword && (
          <p className="text-sm text-danger">{errors.newPassword.message}</p>
        )}
        <div className="h-2 w-full overflow-hidden rounded-full bg-gray-200 dark:bg-gray-800">
          <div
            className={cn(
              'h-full transition-all duration-300',
              barColor,
              strength === 'weak' && 'w-1/3',
              strength === 'medium' && 'w-2/3',
              strength === 'strong' && 'w-full'
            )}
          />
        </div>
        <p className="text-xs text-gray-500 capitalize dark:text-gray-400">{strength} password</p>
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="cp" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Confirm New Password
        </label>
        <div className="relative">
          <input
            id="cp"
            type={showConfirm ? 'text' : 'password'}
            className={cn(
              'w-full rounded-lg border px-3 py-2 pr-10 dark:bg-gray-950 dark:text-white',
              errors.confirmPassword ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
            )}
            {...register('confirmPassword')}
          />
          <button
            type="button"
            className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-1 text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800"
            aria-label={showConfirm ? 'Hide password' : 'Show password'}
            onClick={() => setShowConfirm((s) => !s)}
          >
            {showConfirm ? <EyeOff className="size-5" /> : <Eye className="size-5" />}
          </button>
        </div>
        {errors.confirmPassword && (
          <p className="text-sm text-danger">{errors.confirmPassword.message}</p>
        )}
      </div>

      {mutation.isError && (
        <p className="text-sm text-danger" role="alert">
          Reset link may have expired or is invalid.
        </p>
      )}

      <button
        type="submit"
        disabled={mutation.isPending}
        className="flex items-center justify-center gap-2 rounded-lg bg-primary py-2.5 font-medium text-white hover:bg-primary-hover disabled:opacity-60"
      >
        {mutation.isPending && <LoadingSpinner className="size-4 border-white border-t-transparent" />}
        Reset password
      </button>
    </form>
  )
}
