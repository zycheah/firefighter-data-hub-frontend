import { axiosInstance } from '@/api/axiosInstance'

export interface ContactPayload {
  name: string
  email: string
  subject: string
  message: string
}

export async function submitContact(payload: ContactPayload): Promise<unknown> {
  const { data } = await axiosInstance.post('/contact', payload)
  return data
}
