export interface User {
  id: string
  firstName: string
  lastName: string
  universityEmail: string
  personalEmail?: string
  phoneNumber?: string
  role: 'RESEARCHER' | 'RESEARCH_ADMIN'
  avatar?: string
}

export interface AuthResponse {
  user: User
  accessToken?: string
  access_token?: string
  tokenType?: string
  token_type?: string
}

export interface LoginCredentials {
  email: string
  password: string
}

export interface RegisterPayload {
  first_name: string
  last_name: string
  university_email: string
  personal_email?: string
  phoneNumber?: string
  password: string
  role: 'RESEARCHER' | 'RESEARCH_ADMIN'
}

export interface RefreshTokenResponse {
  accessToken?: string
  access_token?: string
  tokenType?: string
  token_type?: string
}
