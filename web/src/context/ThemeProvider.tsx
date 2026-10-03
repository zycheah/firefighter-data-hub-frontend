import {
  useCallback,
  useLayoutEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'
import { ThemeContext } from '@/context/theme-context'

const STORAGE_KEY = 'analytics-theme'

function readStoredDark(): boolean {
  if (typeof window === 'undefined') return false
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored === 'dark') return true
  if (stored === 'light') return false
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [dark, setDark] = useState(readStoredDark)

  useLayoutEffect(() => {
    if (dark) {
      document.documentElement.classList.add('dark')
      localStorage.setItem(STORAGE_KEY, 'dark')
    } else {
      document.documentElement.classList.remove('dark')
      localStorage.setItem(STORAGE_KEY, 'light')
    }
  }, [dark])

  const toggle = useCallback(() => setDark((d) => !d), [])

  const value = useMemo(() => ({ dark, toggle }), [dark, toggle])

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}
