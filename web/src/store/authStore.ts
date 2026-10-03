import { create } from 'zustand'
import { createJSONStorage, persist } from 'zustand/middleware'
import type { AuthResponse, User } from '@/types/auth.types'

export interface AuthStore {
  user: User | null
  accessToken: string | null
  tokenType: string | null
  isAuthenticated: boolean
  login: (data: AuthResponse) => void
  logout: () => void
  setUser: (user: User | null) => void
  setAccessToken: (token: string | null) => void
  setTokenType: (tokenType: string | null) => void
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      user: null,
      accessToken: null,
      tokenType: null,
      isAuthenticated: false,
      login: (data: AuthResponse) =>
        set({
          user: data.user,
          accessToken: data.accessToken ?? data.access_token ?? null,
          tokenType: data.tokenType ?? data.token_type ?? 'Bearer',
          isAuthenticated: true,
        }),
      logout: () =>
        set({
          user: null,
          accessToken: null,
          tokenType: null,
          isAuthenticated: false,
        }),
      setUser: (user) => set({ user, isAuthenticated: !!user }),
      setAccessToken: (accessToken) =>
        set((s) => ({
          accessToken,
          isAuthenticated: !!(accessToken && s.user),
        })),
      setTokenType: (tokenType) => set({ tokenType }),
    }),
    {
      name: 'analytics-auth',
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({
        user: state.user,
        accessToken: state.accessToken,
        tokenType: state.tokenType,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
)
