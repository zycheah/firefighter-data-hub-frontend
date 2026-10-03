import { axiosInstance } from '@/api/axiosInstance'
import type {
  AuthResponse,
  LoginCredentials,
  RegisterPayload,
  User,
} from '@/types/auth.types'

export async function login(credentials: LoginCredentials): Promise<AuthResponse> {
  const { data } = await axiosInstance.post<AuthResponse>('/auth/login', credentials)
  return data
}

export async function register(payload: RegisterPayload): Promise<unknown> {
  const { data } = await axiosInstance.post('/auth/register', payload)
  return data
}

export async function forgotPassword(email: string): Promise<unknown> {
  const { data } = await axiosInstance.post('/auth/forgot-password', { email })
  return data
}

export async function resetPassword(body: {
  token: string
  newPassword: string
}): Promise<unknown> {
  const { data } = await axiosInstance.post('/auth/reset-password', body)
  return data
}

export async function resendVerification(email: string): Promise<unknown> {
  const { data } = await axiosInstance.post('/auth/resend-verification', { email })
  return data
}

export async function getMe(): Promise<User> {
  const { data } = await axiosInstance.get<User>('/auth/me')
  return data
}

export async function updateMe(payload: {
  first_name?: string
  last_name?: string
  personal_email?: string
  phoneNumber?: string
}): Promise<User> {
  const { data } = await axiosInstance.put<User>('/auth/me', payload)
  return data
}

export async function changePassword(payload: {
  password: string
  newPassword: string
}): Promise<{ ok: boolean }> {
  const { data } = await axiosInstance.post<{ ok: boolean }>('/auth/password-reset', payload)
  return data
}
