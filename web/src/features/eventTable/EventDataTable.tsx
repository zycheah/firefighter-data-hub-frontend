import { useMemo, useState } from 'react'
import {
  flexRender,
  getCoreRowModel,
  useReactTable,
  type PaginationState,
} from '@tanstack/react-table'
import { useQuery } from '@tanstack/react-query'
import { ChevronLeft, ChevronRight } from 'lucide-react'
import { getEventTableData } from '@/api/eventTable.api'
import { queryKeys } from '@/constants/queryKeys'
import { eventColumns } from '@/features/eventTable/columns'
import { DownloadEventCSVButton } from '@/features/eventTable/DownloadEventCSVButton'

const PAGE_SIZE = 10

export function EventDataTable() {
  const [pagination, setPagination] = useState<PaginationState>({
    pageIndex: 0,
    pageSize: PAGE_SIZE,
  })

  const query = useQuery({
    queryKey: queryKeys.eventTableData({
      page: pagination.pageIndex + 1,
      pageSize: pagination.pageSize,
    }),
    queryFn: () =>
      getEventTableData({
        page: pagination.pageIndex + 1,
        pageSize: pagination.pageSize,
      }),
    placeholderData: (prev) => prev,
  })

  const tableData = query.data?.data ?? []
  const total = query.data?.total ?? 0
  const pageCount = Math.max(1, query.data?.totalPages ?? 1)

  const columns = useMemo(() => eventColumns, [])

  const table = useReactTable({
    data: tableData,
    columns,
    state: { pagination },
    onPaginationChange: setPagination,
    manualPagination: true,
    pageCount,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <div>
      <DownloadEventCSVButton />
      <div className="overflow-x-auto rounded-xl border border-gray-200 shadow-md dark:border-gray-700">
        <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead className="bg-gray-50 dark:bg-gray-800">
            {table.getHeaderGroups().map((hg) => (
              <tr key={hg.id}>
                {hg.headers.map((header) => (
                  <th
                    key={header.id}
                    scope="col"
                    className="px-6 py-3 text-left text-xs font-semibold uppercase tracking-wider text-gray-500 dark:text-gray-300"
                  >
                    {header.isPlaceholder
                      ? null
                      : flexRender(header.column.columnDef.header, header.getContext())}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody className="divide-y divide-gray-100 bg-white dark:divide-gray-800 dark:bg-gray-900">
            {query.isPending && (
              <tr>
                <td colSpan={columns.length} className="px-6 py-12 text-center text-sm text-gray-500">
                  Loading…
                </td>
              </tr>
            )}
            {query.isError && (
              <tr>
                <td colSpan={columns.length} className="px-6 py-12 text-center text-sm text-danger">
                  Failed to load data.{' '}
                  <button
                    type="button"
                    className="font-medium text-primary underline"
                    onClick={() => query.refetch()}
                  >
                    Retry
                  </button>
                </td>
              </tr>
            )}
            {!query.isPending && !query.isError && table.getRowModel().rows.length === 0 && (
              <tr>
                <td colSpan={columns.length} className="px-6 py-12 text-center text-sm text-gray-500">
                  No rows to display.
                </td>
              </tr>
            )}
            {!query.isPending &&
              !query.isError &&
              table.getRowModel().rows.map((row) => (
                <tr
                  key={row.id}
                  className="transition-colors even:bg-gray-50 hover:bg-blue-50 dark:even:bg-gray-800/50 dark:hover:bg-blue-900/20"
                >
                  {row.getVisibleCells().map((cell) => (
                    <td
                      key={cell.id}
                      className="whitespace-nowrap px-6 py-4 text-sm text-gray-700 dark:text-gray-200"
                    >
                      {flexRender(cell.column.columnDef.cell, cell.getContext())}
                    </td>
                  ))}
                </tr>
              ))}
          </tbody>
        </table>
      </div>

      <div className="mt-4 flex flex-col gap-3 border-t border-gray-200 pt-4 text-sm text-gray-600 dark:border-gray-700 dark:text-gray-300 sm:flex-row sm:items-center sm:justify-between">
        <p>
          Page {pagination.pageIndex + 1} of {pageCount} — {total.toLocaleString()} total
        </p>
        <div className="flex items-center gap-2">
          <button
            type="button"
            className="inline-flex items-center gap-1 rounded-lg border border-gray-300 px-3 py-1.5 hover:bg-gray-50 disabled:opacity-40 dark:border-gray-600 dark:hover:bg-gray-800"
            disabled={pagination.pageIndex <= 0 || query.isFetching}
            onClick={() => setPagination((p) => ({ ...p, pageIndex: Math.max(0, p.pageIndex - 1) }))}
            aria-label="Previous page"
          >
            <ChevronLeft className="size-4" />
            Previous
          </button>
          <button
            type="button"
            className="inline-flex items-center gap-1 rounded-lg border border-gray-300 px-3 py-1.5 hover:bg-gray-50 disabled:opacity-40 dark:border-gray-600 dark:hover:bg-gray-800"
            disabled={pagination.pageIndex + 1 >= pageCount || query.isFetching}
            onClick={() =>
              setPagination((p) => ({ ...p, pageIndex: Math.min(pageCount - 1, p.pageIndex + 1) }))
            }
            aria-label="Next page"
          >
            Next
            <ChevronRight className="size-4" />
          </button>
        </div>
      </div>
    </div>
  )
}

