import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation } from '@tanstack/react-query'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { submitAccountRequest } from '@/api/account.api'
import { LoadingSpinner } from '@/components/shared/LoadingSpinner'
import { cn } from '@/utils/cn'

const schema = z.object({
  fullName: z.string().min(1, 'Required'),
  workEmail: z.string().min(1, 'Required').email('Valid email'),
  company: z.string().min(1, 'Required'),
  jobTitle: z.string().min(1, 'Required'),
  reason: z.string().min(20, 'Please provide at least 20 characters'),
})

type Values = z.infer<typeof schema>

export default function AccountRequestPage() {
  const [done, setDone] = useState(false)
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<Values>({
    resolver: zodResolver(schema),
    defaultValues: {
      fullName: '',
      workEmail: '',
      company: '',
      jobTitle: '',
      reason: '',
    },
  })

  const mutation = useMutation({
    mutationFn: submitAccountRequest,
    onSuccess: () => setDone(true),
    onError: () => toast.error('Request failed. Please try again.'),
  })

  if (done) {
    return (
      <div className="mx-auto max-w-lg px-4 py-16 sm:px-6">
        <div className="rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm dark:border-gray-700 dark:bg-gray-900">
          <p className="text-lg font-semibold text-gray-900 dark:text-white">
            Your request has been submitted. We&apos;ll be in touch within 2 business days.
          </p>
        </div>
      </div>
    )
  }

  const input = (id: keyof Values, type: 'text' | 'email' = 'text') => (
    <input
      id={id}
      type={type}
      className={cn(
        'rounded-lg border px-3 py-2 dark:bg-gray-950 dark:text-white',
        errors[id] ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
      )}
      {...register(id)}
    />
  )

  return (
    <div className="mx-auto max-w-lg px-4 py-16 sm:px-6">
      <h1 className="text-center text-3xl font-bold text-gray-900 dark:text-white">
        Request an account
      </h1>
      <p className="mt-2 text-center text-gray-600 dark:text-gray-400">
        Tell us about your organization and why you need access.
      </p>
      <form
        onSubmit={handleSubmit((v) => mutation.mutate(v))}
        className="mt-8 flex flex-col gap-4 rounded-2xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-900"
        noValidate
      >
        <div className="flex flex-col gap-2">
          <label htmlFor="fullName" className="text-sm font-medium text-gray-700 dark:text-gray-200">
            Full name
          </label>
          {input('fullName')}
          {errors.fullName && <p className="text-sm text-danger">{errors.fullName.message}</p>}
        </div>
        <div className="flex flex-col gap-2">
          <label htmlFor="workEmail" className="text-sm font-medium text-gray-700 dark:text-gray-200">
            Work email
          </label>
          {input('workEmail', 'email')}
          {errors.workEmail && <p className="text-sm text-danger">{errors.workEmail.message}</p>}
        </div>
        <div className="flex flex-col gap-2">
          <label htmlFor="company" className="text-sm font-medium text-gray-700 dark:text-gray-200">
            Company
          </label>
          {input('company')}
          {errors.company && <p className="text-sm text-danger">{errors.company.message}</p>}
        </div>
        <div className="flex flex-col gap-2">
          <label htmlFor="jobTitle" className="text-sm font-medium text-gray-700 dark:text-gray-200">
            Job title
          </label>
          {input('jobTitle')}
          {errors.jobTitle && <p className="text-sm text-danger">{errors.jobTitle.message}</p>}
        </div>
        <div className="flex flex-col gap-2">
          <label htmlFor="reason" className="text-sm font-medium text-gray-700 dark:text-gray-200">
            Reason
          </label>
          <textarea
            id="reason"
            rows={4}
            className={cn(
              'rounded-lg border px-3 py-2 dark:bg-gray-950 dark:text-white',
              errors.reason ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
            )}
            {...register('reason')}
          />
          {errors.reason && <p className="text-sm text-danger">{errors.reason.message}</p>}
        </div>
        <button
          type="submit"
          disabled={mutation.isPending}
          className="mt-2 inline-flex items-center justify-center gap-2 rounded-lg bg-primary py-2.5 font-medium text-white hover:bg-primary-hover disabled:opacity-60"
        >
          {mutation.isPending && <LoadingSpinner className="size-4 border-white border-t-transparent" />}
          Submit request
        </button>
      </form>
    </div>
  )
}
