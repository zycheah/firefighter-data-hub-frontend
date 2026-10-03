import { useEffect, useMemo, useState } from 'react'
import { useMutation, useQuery } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import toast from 'react-hot-toast'
import { changePassword, getMe, updateMe } from '@/api/auth.api'
import { useAuth } from '@/hooks/useAuth'

const profileSchema = z.object({
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().min(1, 'Last name is required'),
  personalEmail: z
    .string()
    .email('Enter a valid personal email')
    .or(z.literal(''))
    .optional(),
  phoneNumber: z.string().optional(),
})

type ProfileValues = z.infer<typeof profileSchema>

const passwordSchema = z
  .object({
    password: z.string().min(1, 'Current password is required'),
    newPassword: z.string().min(8, 'New password must be at least 8 characters'),
    confirmNewPassword: z.string().min(1, 'Please confirm your new password'),
  })
  .refine((v) => v.newPassword === v.confirmNewPassword, {
    message: 'Passwords do not match',
    path: ['confirmNewPassword'],
  })

type PasswordValues = z.infer<typeof passwordSchema>

export default function ProfilePage() {
  const { user, setUser } = useAuth()
  const [isEditingDetails, setIsEditingDetails] = useState(false)
  const [showResetPassword, setShowResetPassword] = useState(false)
  const [passwordSuccess, setPasswordSuccess] = useState<string | null>(null)

  const meQuery = useQuery({
    queryKey: ['me'],
    queryFn: getMe,
  })

  const profileForm = useForm<ProfileValues>({
    resolver: zodResolver(profileSchema),
    defaultValues: {
      firstName: user?.firstName ?? '',
      lastName: user?.lastName ?? '',
      personalEmail: user?.personalEmail ?? '',
      phoneNumber: user?.phoneNumber ?? '',
    },
  })

  useEffect(() => {
    if (!meQuery.data) return
    setUser(meQuery.data)
    setPasswordSuccess(null)
    profileForm.reset({
      firstName: meQuery.data.firstName ?? '',
      lastName: meQuery.data.lastName ?? '',
      personalEmail: meQuery.data.personalEmail ?? '',
      phoneNumber: meQuery.data.phoneNumber ?? '',
    })
  }, [meQuery.data, setUser, profileForm])

  const me = meQuery.data ?? user

  const defaultProfileValues = useMemo(
    () => ({
      firstName: me?.firstName ?? '',
      lastName: me?.lastName ?? '',
      personalEmail: me?.personalEmail ?? '',
      phoneNumber: me?.phoneNumber ?? '',
    }),
    [me]
  )

  const updateMutation = useMutation({
    mutationFn: (values: ProfileValues) =>
      updateMe({
        first_name: values.firstName,
        last_name: values.lastName,
        personal_email: values.personalEmail?.trim() ? values.personalEmail.trim() : undefined,
        phoneNumber: values.phoneNumber?.trim() ? values.phoneNumber.trim() : undefined,
      }),
    onSuccess: (updated) => {
      setUser(updated)
      toast.success('Profile updated')
      setIsEditingDetails(false)
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
                'Failed to update profile'
            )
          : 'Failed to update profile'
      toast.error(message)
    },
  })

  const passwordForm = useForm<PasswordValues>({
    resolver: zodResolver(passwordSchema),
    defaultValues: { password: '', newPassword: '', confirmNewPassword: '' },
  })

  const passwordMutation = useMutation({
    mutationFn: (values: PasswordValues) =>
      changePassword({ password: values.password, newPassword: values.newPassword }),
    onSuccess: () => {
      toast.success('Password updated')
      passwordForm.reset()
      setPasswordSuccess('Password updated successfully.')
      setShowResetPassword(false)
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
                'Failed to update password'
            )
          : 'Failed to update password'
      toast.error(message)
    },
  })

  return (
    <div className="mx-auto w-full max-w-3xl">
      <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Profile</h1>
      <p className="mt-1 text-gray-600 dark:text-gray-400">
        Update your details. Your university email can’t be changed.
      </p>

      <div className="mt-8 grid gap-6">
        <section className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900 sm:p-6">
          <div className="flex items-start justify-between gap-4">
            <div>
              <h2 className="text-base font-semibold text-gray-900 dark:text-white">
                User details
              </h2>
              <p className="mt-1 text-sm text-gray-600 dark:text-gray-400">
                Keep your name and contact information up to date.
              </p>
            </div>
            <div className="flex items-center gap-3">
              {meQuery.isFetching && (
                <span className="text-xs text-gray-500 dark:text-gray-400">Loading…</span>
              )}
              {!isEditingDetails ? (
                <button
                  type="button"
                  className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-200 dark:hover:bg-gray-800"
                  onClick={() => {
                    setPasswordSuccess(null)
                    setIsEditingDetails(true)
                  }}
                >
                  Edit
                </button>
              ) : (
                <button
                  type="button"
                  className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-200 dark:hover:bg-gray-800"
                  onClick={() => {
                    profileForm.reset(defaultProfileValues)
                    setIsEditingDetails(false)
                  }}
                >
                  Cancel
                </button>
              )}
            </div>
          </div>

          {passwordSuccess && (
            <div className="mt-4 rounded-lg border border-emerald-200 bg-emerald-50 px-3 py-2 text-sm text-emerald-800 dark:border-emerald-900/60 dark:bg-emerald-950/30 dark:text-emerald-200">
              {passwordSuccess}
            </div>
          )}

          <div className="mt-5 grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                University email
              </label>
              <input
                value={me?.universityEmail ?? ''}
                disabled
                className="mt-1 w-full rounded-lg border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-gray-700 dark:border-gray-800 dark:bg-gray-950 dark:text-gray-200"
              />
            </div>
            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                Role
              </label>
              <input
                value={me?.role ?? ''}
                disabled
                className="mt-1 w-full rounded-lg border border-gray-200 bg-gray-50 px-3 py-2 text-sm text-gray-700 dark:border-gray-800 dark:bg-gray-950 dark:text-gray-200"
              />
            </div>
          </div>

          <form
            className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2"
            onSubmit={profileForm.handleSubmit((v) => updateMutation.mutate(v))}
            noValidate
          >
            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                First name
              </label>
              <input
                disabled={!isEditingDetails}
                className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                {...profileForm.register('firstName')}
              />
              {profileForm.formState.errors.firstName && (
                <p className="mt-1 text-sm text-danger" role="alert">
                  {profileForm.formState.errors.firstName.message}
                </p>
              )}
            </div>

            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                Last name
              </label>
              <input
                disabled={!isEditingDetails}
                className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                {...profileForm.register('lastName')}
              />
              {profileForm.formState.errors.lastName && (
                <p className="mt-1 text-sm text-danger" role="alert">
                  {profileForm.formState.errors.lastName.message}
                </p>
              )}
            </div>

            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                Personal email
              </label>
              <input
                type="email"
                placeholder="name@example.com"
                disabled={!isEditingDetails}
                className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                {...profileForm.register('personalEmail')}
              />
              {profileForm.formState.errors.personalEmail && (
                <p className="mt-1 text-sm text-danger" role="alert">
                  {profileForm.formState.errors.personalEmail.message}
                </p>
              )}
            </div>

            <div>
              <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                Phone number
              </label>
              <input
                placeholder="Optional"
                disabled={!isEditingDetails}
                className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                {...profileForm.register('phoneNumber')}
              />
            </div>

            {isEditingDetails && (
              <div className="sm:col-span-2 flex items-center justify-end gap-3 pt-2">
                <button
                  type="button"
                  className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-200 dark:hover:bg-gray-800"
                  onClick={() => profileForm.reset(defaultProfileValues)}
                >
                  Reset
                </button>
                <button
                  type="submit"
                  disabled={updateMutation.isPending}
                  className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-white hover:bg-primary-hover disabled:opacity-60"
                >
                  Save changes
                </button>
              </div>
            )}
          </form>
        </section>

        {!showResetPassword ? (
          <div className="flex justify-end">
            <button
              type="button"
              className="rounded-lg bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700"
              onClick={() => {
                setPasswordSuccess(null)
                setShowResetPassword(true)
              }}
            >
              Reset password
            </button>
          </div>
        ) : (
          <section className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm dark:border-gray-800 dark:bg-gray-900 sm:p-6">
            <div className="flex items-start justify-between gap-4">
              <div>
                <h2 className="text-base font-semibold text-gray-900 dark:text-white">
                  Reset password
                </h2>
                <p className="mt-1 text-sm text-gray-600 dark:text-gray-400">
                  Choose a strong password you don’t use elsewhere.
                </p>
              </div>
              <button
                type="button"
                className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-200 dark:hover:bg-gray-800"
                onClick={() => {
                  passwordForm.reset()
                  setShowResetPassword(false)
                }}
              >
                Cancel
              </button>
            </div>

            <form
              className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2"
              onSubmit={passwordForm.handleSubmit((v) => passwordMutation.mutate(v))}
              noValidate
            >
              <div className="sm:col-span-2">
                <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                  Current password
                </label>
                <input
                  type="password"
                  autoComplete="current-password"
                  className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                  {...passwordForm.register('password')}
                />
                {passwordForm.formState.errors.password && (
                  <p className="mt-1 text-sm text-danger" role="alert">
                    {passwordForm.formState.errors.password.message}
                  </p>
                )}
              </div>

              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                  New password
                </label>
                <input
                  type="password"
                  autoComplete="new-password"
                  className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                  {...passwordForm.register('newPassword')}
                />
                {passwordForm.formState.errors.newPassword && (
                  <p className="mt-1 text-sm text-danger" role="alert">
                    {passwordForm.formState.errors.newPassword.message}
                  </p>
                )}
              </div>

              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-200">
                  Confirm new password
                </label>
                <input
                  type="password"
                  autoComplete="new-password"
                  className="mt-1 w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm text-gray-900 shadow-sm outline-none focus:ring-2 focus:ring-primary dark:border-gray-700 dark:bg-gray-950 dark:text-white"
                  {...passwordForm.register('confirmNewPassword')}
                />
                {passwordForm.formState.errors.confirmNewPassword && (
                  <p className="mt-1 text-sm text-danger" role="alert">
                    {passwordForm.formState.errors.confirmNewPassword.message}
                  </p>
                )}
              </div>

              <div className="sm:col-span-2 flex items-center justify-end gap-3 pt-2">
                <button
                  type="submit"
                  disabled={passwordMutation.isPending}
                  className="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-white hover:bg-primary-hover disabled:opacity-60"
                >
                  Update password
                </button>
              </div>
            </form>
          </section>
        )}
      </div>
    </div>
  )
}

