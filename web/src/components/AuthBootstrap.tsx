import { useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { getMe } from '@/api/auth.api'
import { queryKeys } from '@/constants/queryKeys'
import { useAuthStore } from '@/store/authStore'

export function AuthBootstrap({ children }: { children: React.ReactNode }) {
  const accessToken = useAuthStore((s) => s.accessToken)
  const logout = useAuthStore((s) => s.logout)
  const setUser = useAuthStore((s) => s.setUser)

  const meQuery = useQuery({
    queryKey: queryKeys.authMe,
    queryFn: getMe,
    enabled: !!accessToken,
    retry: false,
    staleTime: 60_000,
  })

  useEffect(() => {
    if (meQuery.isError) {
      logout()
    }
  }, [meQuery.isError, logout])

  useEffect(() => {
    if (meQuery.data) {
      setUser(meQuery.data)
    }
  }, [meQuery.data, setUser])

  return children
}
