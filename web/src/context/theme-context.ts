import { createContext } from 'react'

export interface ThemeContextValue {
  dark: boolean
  toggle: () => void
}

export const ThemeContext = createContext<ThemeContextValue | null>(null)
