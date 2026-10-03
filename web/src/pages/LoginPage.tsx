import { LoginForm } from '@/features/auth/LoginForm'

const appName = import.meta.env.VITE_APP_NAME ?? 'AnalyticsApp'

export default function LoginPage() {
  return (
    <div className="grid min-h-[calc(100svh-4rem)] md:grid-cols-2">
      <div className="hidden flex-col justify-center bg-primary px-10 py-12 text-white md:flex">
        <p className="text-sm font-semibold uppercase tracking-wide text-blue-100">Welcome back</p>
        <h1 className="mt-2 text-3xl font-bold">{appName}</h1>
        <p className="mt-4 max-w-md text-blue-100">
          Sign in to access dashboards, exports, and collaborative research tools.
        </p>
      </div>
      <div className="flex items-center justify-center px-4 py-12">
        <div className="w-full max-w-lg rounded-2xl border border-gray-200 bg-white p-8 shadow-sm dark:border-gray-700 dark:bg-gray-900">
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Sign in</h1>
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-400">
            Use your university credentials.
          </p>
          <div className="mt-8">
            <LoginForm />
          </div>
        </div>
      </div>
    </div>
  )
}
