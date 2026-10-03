import { createColumnHelper } from '@tanstack/react-table'
import type { EventTableRow } from '@/types/eventTable.types'

const columnHelper = createColumnHelper<EventTableRow>()

export const eventColumns = [
  columnHelper.accessor('event_id', { header: 'Event ID', cell: (info) => info.getValue() }),
  columnHelper.accessor('user_id', { header: 'User ID', cell: (info) => info.getValue() }),
  columnHelper.accessor('event_date', { header: 'Event date', cell: (info) => info.getValue() }),
  columnHelper.accessor('event_address', { header: 'Address', cell: (info) => info.getValue() }),
  columnHelper.accessor('is_same_ppe', {
    header: 'Same PPE',
    cell: (info) => (info.getValue() ? 'Yes' : 'No'),
  }),
]

