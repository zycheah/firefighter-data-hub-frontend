import { useState } from 'react'
import { DataTable } from '@/features/table/DataTable'

export default function TableViewPage() {
  const [search, setSearch] = useState('')

  return (
    <div>
      <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Table view</h1>
          <p className="mt-1 text-gray-600 dark:text-gray-400">
            Browse paginated exposure records. Use search to filter (debounced).
          </p>
        </div>
        <div className="w-full max-w-xs">
          <label htmlFor="table-search" className="sr-only">
            Search table
          </label>
          <input
            id="table-search"
            type="search"
            placeholder="Search…"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm shadow-sm outline-none focus:ring-2 focus:ring-primary dark:border-gray-600 dark:bg-gray-900 dark:text-white"
          />
        </div>
      </div>
      <DataTable search={search} />
    </div>
  )
}
