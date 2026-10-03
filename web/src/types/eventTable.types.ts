export interface EventTableRow {
  event_id: string
  user_id: string
  event_date: string
  event_address: string
  is_same_ppe: boolean
}

export interface EventTableQueryParams {
  page: number
  pageSize: number
}

