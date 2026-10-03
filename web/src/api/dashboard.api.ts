import { axiosInstance } from '@/api/axiosInstance'
import type { DashboardSummary } from '@/types/dashboard.types'
import { useAuthStore } from '@/store/authStore'

export async function getDashboardSummary(): Promise<DashboardSummary> {
  const { accessToken, tokenType } = useAuthStore.getState()
  const type = tokenType ?? 'Bearer'
  const { data } = await axiosInstance.get<DashboardSummary>('/dashboard/summary', {
    headers: accessToken
      ? {
          Authorization: `${type} ${accessToken}`,
          'X-Token-Type': type,
        }
      : {},
  })
  return data
}
