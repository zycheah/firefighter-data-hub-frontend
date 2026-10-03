import { useMutation } from '@tanstack/react-query'
import { Download, Loader2 } from 'lucide-react'
import toast from 'react-hot-toast'
import { downloadCSV } from '@/api/table.api'

export function DownloadCSVButton() {
  const mutation = useMutation({
    mutationFn: downloadCSV,
    onError: () => {
      toast.error('Failed to generate CSV. Please try again.')
    },
  })

  return (
    <div className="mb-4 flex justify-end">
      <button
        type="button"
        disabled={mutation.isPending}
        onClick={() => mutation.mutate()}
        className="inline-flex items-center gap-2 rounded-lg border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-800 shadow-sm hover:bg-gray-50 disabled:cursor-not-allowed disabled:opacity-60 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 dark:hover:bg-gray-800"
      >
        {mutation.isPending ? (
          <Loader2 className="size-4 animate-spin" aria-hidden />
        ) : (
          <Download className="size-4" aria-hidden />
        )}
        {mutation.isPending ? 'Generating...' : 'Download CSV'}
      </button>
    </div>
  )
}
