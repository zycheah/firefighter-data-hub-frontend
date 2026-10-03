import { axiosInstance } from '@/api/axiosInstance'

export interface AccountRequestPayload {
  fullName: string
  workEmail: string
  company: string
  jobTitle: string
  reason: string
}

export async function submitAccountRequest(
  payload: AccountRequestPayload
): Promise<unknown> {
  const { data } = await axiosInstance.post('/account-requests', payload)
  return data
}
