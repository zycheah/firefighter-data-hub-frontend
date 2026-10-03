import { createColumnHelper } from '@tanstack/react-table'
import type { LocationTableRow } from '@/types/table.types'

const columnHelper = createColumnHelper<LocationTableRow>()

export const locationColumns = [
  columnHelper.accessor('id', { header: 'ID', cell: (info) => info.getValue() }),
  columnHelper.accessor('user_id', { header: 'User ID', cell: (info) => info.getValue() }),
  columnHelper.accessor('latitude', {
    header: 'Latitude',
    cell: (info) => info.getValue().toFixed(5),
  }),
  columnHelper.accessor('longitude', {
    header: 'Longitude',
    cell: (info) => info.getValue().toFixed(5),
  }),
  columnHelper.accessor('timestamp', { header: 'Timestamp', cell: (info) => info.getValue() }),
  columnHelper.accessor('locationTimestamp', {
    header: 'Location time',
    cell: (info) => info.getValue(),
  }),
  columnHelper.accessor('altitude', {
    header: 'Altitude',
    cell: (info) => info.getValue(),
  }),
]
