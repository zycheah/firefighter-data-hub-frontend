import { LoadingSpinner } from '@/components/shared/LoadingSpinner'

export function PageLoader() {
  return (
    <div className="flex min-h-[40vh] w-full items-center justify-center p-8">
      <LoadingSpinner className="size-10" label="Loading page" />
    </div>
  )
}
