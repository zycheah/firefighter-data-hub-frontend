import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { useMutation } from '@tanstack/react-query'
import { Link, useNavigate } from 'react-router-dom'
import { Eye, EyeOff } from 'lucide-react'
import { z } from 'zod'
import toast from 'react-hot-toast'
import { register as registerApi } from '@/api/auth.api'
import { ROUTES } from '@/constants/routes'
import { LoadingSpinner } from '@/components/shared/LoadingSpinner'
import { cn } from '@/utils/cn'

const registerSchema = z
  .object({
    firstName: z.string().min(2, 'At least 2 characters'),
    lastName: z.string().min(2, 'At least 2 characters'),
    universityEmail: z.string().min(1, 'Required').email('Valid university email'),
    personalEmail: z.union([z.literal(''), z.string().email('Valid email')]),
    phoneNumber: z
      .string()
      .trim()
      .refine(
        (t) =>
          t.length === 0 ||
          (t.length >= 7 && t.length <= 20 && /^[\d+\s().-]+$/.test(t)),
        { message: 'Enter a valid phone number or leave blank' }
      ),
    password: z
      .string()
      .min(8, 'At least 8 characters')
      .max(15, 'At most 15 characters')
      .regex(/[a-z]/, 'At least one lowercase letter')
      .regex(/[A-Z]/, 'At least one uppercase letter'),
    confirmPassword: z.string().min(1, 'Required'),
    role: z.enum(['RESEARCHER', 'RESEARCH_ADMIN'], { message: 'Select a role' }),
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: 'Passwords must match',
    path: ['confirmPassword'],
  })

export type RegisterFormValues = z.infer<typeof registerSchema>

export function RegisterForm() {
  const navigate = useNavigate()
  const [showPassword, setShowPassword] = useState(false)
  const [showConfirmPassword, setShowConfirmPassword] = useState(false)
  const {
    register,
    handleSubmit,
    formState: { errors },
    setError,
  } = useForm<RegisterFormValues>({
    resolver: zodResolver(registerSchema),
    defaultValues: {
      firstName: '',
      lastName: '',
      universityEmail: '',
      personalEmail: '',
      phoneNumber: '',
      password: '',
      confirmPassword: '',
      role: 'RESEARCHER',
    },
  })

  const mutation = useMutation({
    mutationFn: registerApi,
    onSuccess: () => {
      toast.success(
        'Registration successful! Please check your university email to verify your account.'
      )
      navigate(ROUTES.login, { replace: true })
    },
    onError: () => {
      setError('root', { message: 'Registration failed. Please try again.' })
    },
  })

  return (
    <form
      onSubmit={handleSubmit((values) =>
        mutation.mutate({
          first_name: values.firstName,
          last_name: values.lastName,
          university_email: values.universityEmail,
          personal_email: values.personalEmail?.trim() || undefined,
          phoneNumber: values.phoneNumber?.trim() || undefined,
          password: values.password,
          role: values.role,
        })
      )}
      className="flex w-full max-w-md flex-col gap-4"
      noValidate
    >
      {errors.root && (
        <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-danger dark:bg-red-950/40">
          {errors.root.message}
        </p>
      )}

      <div className="grid gap-4 sm:grid-cols-2">
        <div className="flex flex-col gap-2">
          <label htmlFor="reg-first" className="text-sm font-medium text-gray-700 dark:text-gray-200">
            First Name
          </label>
          <input
            id="reg-first"
            className={cn(
              'rounded-lg border px-3 py-2 dark:bg-gray-900 dark:text-white',
              errors.firstName ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
            )}
            {...register('firstName')}
          />
          {errors.firstName && (
            <p className="text-sm text-danger">{errors.firstName.message}</p>
          )}
        </div>
        <div className="flex flex-col gap-2">
          <label htmlFor="reg-last" className="text-sm font-medium text-gray-700 dark:text-gray-200">
            Last Name
          </label>
          <input
            id="reg-last"
            className={cn(
              'rounded-lg border px-3 py-2 dark:bg-gray-900 dark:text-white',
              errors.lastName ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
            )}
            {...register('lastName')}
          />
          {errors.lastName && (
            <p className="text-sm text-danger">{errors.lastName.message}</p>
          )}
        </div>
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="reg-uni" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          University Email ID
        </label>
        <input
          id="reg-uni"
          type="email"
          placeholder="you@university.edu"
          className={cn(
            'rounded-lg border px-3 py-2 dark:bg-gray-900 dark:text-white',
            errors.universityEmail ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
          )}
          {...register('universityEmail')}
        />
        {errors.universityEmail && (
          <p className="text-sm text-danger">{errors.universityEmail.message}</p>
        )}
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="reg-personal" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Personal Email ID (Optional)
        </label>
        <input
          id="reg-personal"
          type="email"
          className={cn(
            'rounded-lg border px-3 py-2 dark:bg-gray-900 dark:text-white',
            errors.personalEmail ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
          )}
          {...register('personalEmail')}
        />
        {errors.personalEmail && (
          <p className="text-sm text-danger">{errors.personalEmail.message}</p>
        )}
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="reg-phone" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Phone number (Optional)
        </label>
        <input
          id="reg-phone"
          type="tel"
          inputMode="tel"
          autoComplete="tel"
          placeholder="+1 555 123 4567"
          className={cn(
            'rounded-lg border px-3 py-2 dark:bg-gray-900 dark:text-white',
            errors.phoneNumber ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
          )}
          {...register('phoneNumber')}
        />
        {errors.phoneNumber && (
          <p className="text-sm text-danger">{errors.phoneNumber.message}</p>
        )}
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="reg-password" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Password
        </label>
        <div className="relative">
          <input
            id="reg-password"
            type={showPassword ? 'text' : 'password'}
            autoComplete="new-password"
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
        {errors.password && <p className="text-sm text-danger">{errors.password.message}</p>}
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="reg-confirm-password" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Confirm password
        </label>
        <div className="relative">
          <input
            id="reg-confirm-password"
            type={showConfirmPassword ? 'text' : 'password'}
            autoComplete="new-password"
            className={cn(
              'w-full rounded-lg border px-3 py-2 pr-10 text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:bg-gray-900 dark:text-white',
              errors.confirmPassword ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
            )}
            {...register('confirmPassword')}
          />
          <button
            type="button"
            className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-1 text-gray-500 hover:bg-gray-100 dark:hover:bg-gray-800"
            aria-label={showConfirmPassword ? 'Hide confirm password' : 'Show confirm password'}
            onClick={() => setShowConfirmPassword((s) => !s)}
          >
            {showConfirmPassword ? <EyeOff className="size-5" /> : <Eye className="size-5" />}
          </button>
        </div>
        {errors.confirmPassword && (
          <p className="text-sm text-danger">{errors.confirmPassword.message}</p>
        )}
      </div>

      <div className="flex flex-col gap-2">
        <label htmlFor="reg-role" className="text-sm font-medium text-gray-700 dark:text-gray-200">
          Role
        </label>
        <select
          id="reg-role"
          className={cn(
            'rounded-lg border px-3 py-2 dark:bg-gray-900 dark:text-white',
            errors.role ? 'border-danger' : 'border-gray-300 dark:border-gray-600'
          )}
          {...register('role')}
        >
          <option value="RESEARCHER">Researcher</option>
          <option value="RESEARCH_ADMIN">Research Admin</option>
        </select>
        {errors.role && <p className="text-sm text-danger">{errors.role.message}</p>}
      </div>

      <button
        type="submit"
        disabled={mutation.isPending}
        className="mt-2 flex items-center justify-center gap-2 rounded-lg bg-primary py-2.5 font-medium text-white hover:bg-primary-hover disabled:opacity-60"
      >
        {mutation.isPending && <LoadingSpinner className="size-4 border-white border-t-transparent" />}
        Create account
      </button>

      <p className="text-center text-sm text-gray-600 dark:text-gray-400">
        Already have an account?{' '}
        <Link to={ROUTES.login} className="font-medium text-primary hover:text-primary-hover">
          Login
        </Link>
      </p>
    </form>
  )
}
