import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation } from '@tanstack/react-query'
import { z } from 'zod'
import { forgotPassword } from '@/api/auth.api'
import { LoadingSpinner } from '@/components/shared/LoadingSpinner'
import { cn } from '@/utils/cn'

const schema = z.object({
  email: z.string().min(1, 'Required').email('Valid email'),
})

type Values = z.infer<typeof schema>

export function ForgotPasswordForm() {
  const [done, setDone] = useState(false)
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<Values>({
    resolver: zodResolver(schema),
    defaultValues: { email: '' },
  })

  const mutation = useMutation({
    mutationFn: (email: string) => forgotPassword(email),
    onSuccess: () => setDone(true),
  })

  if (done) {
    return (
      <div className="w-full max-w-md rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm dark:border-gray-700 dark:bg-gray-900">
        <p className="text-gray-700 dark:text-gray-200">
          If this email is registered, you will receive a password reset link shortly.
        </p>
      </div>
    )
  }

  return (
    <form
      onSubmit={handleSubmit((v) => mutation.mutate(v.email))}
      className="flex w-full max-w-md flex-col gap-4 rounded-2xl border border-gray-200 bg-white p-8 shadow-sm dark:border-gray-700 dark:bg-gray-900"
      noValidate
    >
      <div className="flex flex-col gap-2">
        <label htmlFor="fp-email" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Email Address
        </label>
        <input
          id="fp-email"
          type="email"
          placeholder="you@university.edu"
          className={cn(
            'rounded-lg border px-3 py-2 dark:bg-gray-950 dark:text-white',
            errors.email ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
          )}
          {...register('email')}
        />
        {errors.email && <p className="text-sm text-danger">{errors.email.message}</p>}
      </div>
      <button
        type="submit"
        disabled={mutation.isPending}
        className="flex items-center justify-center gap-2 rounded-lg bg-primary py-2.5 font-medium text-white hover:bg-primary-hover disabled:opacity-60"
      >
        {mutation.isPending && <LoadingSpinner className="size-4 border-white border-t-transparent" />}
        Send reset link
      </button>
    </form>
  )
}
