import { Component, type ErrorInfo, type ReactNode } from 'react'

interface Props {
  children: ReactNode
}

interface State {
  hasError: boolean
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false }

  static getDerivedStateFromError(): State {
    return { hasError: true }
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('ErrorBoundary:', error, info.componentStack)
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="flex min-h-svh flex-col items-center justify-center gap-4 bg-gray-50 p-6 dark:bg-gray-900">
          <h1 className="text-xl font-semibold text-gray-900 dark:text-white">
            Something went wrong
          </h1>
          <p className="max-w-md text-center text-gray-600 dark:text-gray-300">
            Please refresh the page. If the problem persists, contact support.
          </p>
          <button
            type="button"
            className="rounded-lg bg-primary px-4 py-2 font-medium text-white hover:bg-primary-hover"
            onClick={() => window.location.reload()}
          >
            Refresh
          </button>
        </div>
      )
    }
    return this.props.children
  }
}
