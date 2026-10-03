import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios'
import toast from 'react-hot-toast'
import { useAuthStore } from '@/store/authStore'
import { ROUTES } from '@/constants/routes'
import type { RefreshTokenResponse } from '@/types/auth.types'

/** Local API: original app default was port 8080 (not uvicorn's 8000). In dev, use Vite proxy same-origin path to avoid CORS. */
const baseURL = //'http://98.90.107.205:8000/api/v1/web_api';
  import.meta.env.VITE_API_BASE_URL?.replace(/\/$/, '') ||
  (import.meta.env.DEV ? '/api/v1/web_api' : 'http://localhost:8080/api/v1/web_api')

export const axiosInstance = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: false,
})

type RetriableRequest = InternalAxiosRequestConfig & { _retry?: boolean }

let refreshPromise: Promise<string | null> | null = null

function redirectAfterAuthFailure() {
  const path = window.location.pathname
  if (path.startsWith(ROUTES.dashboard)) {
    window.location.assign(ROUTES.error401)
    return
  }
  if (!path.startsWith(ROUTES.login)) {
    window.location.assign(ROUTES.login)
  }
}

async function refreshAccessToken(): Promise<string | null> {
  if (!refreshPromise) {
    refreshPromise = axios
      .post<RefreshTokenResponse>(
        `${baseURL}/auth/refresh`,
        {},
        { withCredentials: true }
      )
      .then((res) => {
        const token = res.data.accessToken ?? res.data.access_token ?? null
        const tokenType = res.data.tokenType ?? res.data.token_type ?? 'Bearer'
        const { setAccessToken, setTokenType } = useAuthStore.getState()
        setAccessToken(token)
        setTokenType(tokenType)
        return token
      })
      .catch(() => {
        useAuthStore.getState().logout()
        redirectAfterAuthFailure()
        return null
      })
      .finally(() => {
        refreshPromise = null
      })
  }
  return refreshPromise
}

axiosInstance.interceptors.request.use((config) => {
  const { accessToken: token, tokenType } = useAuthStore.getState()
  if (token) {
    const type = tokenType ?? 'Bearer'
    config.headers.Authorization = `${type} ${token}`
  }
  return config
})

axiosInstance.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const status = error.response?.status
    const original = error.config as RetriableRequest | undefined

    if (status && status >= 500) {
      toast.error('Server error. Please try again.')
    }

    if (status !== 401 || !original) {
      return Promise.reject(error)
    }

    const url = original.url ?? ''
    if (
      url.includes('/auth/refresh') ||
      url.includes('/auth/login') ||
      url.includes('/auth/register')
    ) {
      return Promise.reject(error)
    }

    if (original._retry) {
      useAuthStore.getState().logout()
      redirectAfterAuthFailure()
      return Promise.reject(error)
    }

    original._retry = true
    const newToken = await refreshAccessToken()
    if (!newToken) {
      return Promise.reject(error)
    }

    const type = useAuthStore.getState().tokenType ?? 'Bearer'
    original.headers.Authorization = `${type} ${newToken}`
    return axiosInstance(original)
  }
)
