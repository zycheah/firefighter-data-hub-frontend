import { Monitor } from 'lucide-react'

function AppleIcon() {
  return (
    <svg viewBox="0 0 24 24" className="size-10 fill-current" aria-hidden>
      <path d="M16.365 1.43c0 1.14-.493 2.27-1.177 3.08-.744.9-1.99 1.57-2.987 1.57-.12 0-.23-.02-.3-.03-.01-.06-.04-.22-.04-.39 0-1.15.572-2.27 1.206-2.98.804-.94 2.142-1.64 3.248-1.68.03.13.05.28.05.43zm4.565 15.71c-.03.07-.463 1.58-1.518 3.12-.945 1.34-1.94 2.71-3.43 2.71-1.517 0-1.9-.88-3.63-.88-1.698 0-2.302.91-3.67.91-1.377 0-2.43-1.26-3.428-2.67-1.93-2.84-2.52-6.25-2.52-9.26 0-2.66.87-5.31 2.37-7.05C5.99 3.86 7.53 3.32 9.03 3.32c1.45 0 2.35.57 3.5.57 1.13 0 1.9-.57 3.67-.57 1.23 0 2.51.43 3.43 1.25-3.14 1.73-2.63 6.24-2.63 6.24z" />
    </svg>
  )
}

function AndroidIcon() {
  return (
    <svg viewBox="0 0 24 24" className="size-10 fill-current" aria-hidden>
      <path d="M17.6 9.48l1.84-3.18c.16-.31.04-.69-.26-.85-.29-.15-.65-.06-.83.22l-1.88 3.24a11.43 11.43 0 0 0-8.45 0L5.1 5.67c-.19-.28-.54-.37-.83-.22-.3.16-.42.54-.26.85l1.84 3.18C3.8 11.23 2.5 13.32 2.5 15.5h19c0-2.18-1.3-4.27-2.9-6.02zM7 13.5c-.83 0-1.5-.67-1.5-1.5S6.17 10.5 7 10.5 8.5 11.17 8.5 12 7.83 13.5 7 13.5zm10 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5z" />
    </svg>
  )
}

export default function DownloadAppPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 py-16 sm:px-6">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 dark:text-white">Get the App</h1>
        <p className="mx-auto mt-3 max-w-2xl text-gray-600 dark:text-gray-300">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Download for your preferred
          platform.
        </p>
      </div>

      <div className="mt-12 grid gap-6 md:grid-cols-3">
        <div className="flex flex-col items-center rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm dark:border-gray-700 dark:bg-gray-900">
          <AppleIcon />
          <p className="mt-4 font-semibold text-gray-900 dark:text-white">iOS</p>
          <p className="mt-2 text-sm text-gray-600 dark:text-gray-300">Download on the App Store</p>
        </div>
        <div className="flex flex-col items-center rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm dark:border-gray-700 dark:bg-gray-900">
          <AndroidIcon />
          <p className="mt-4 font-semibold text-gray-900 dark:text-white">Android</p>
          <p className="mt-2 text-sm text-gray-600 dark:text-gray-300">Get it on Google Play</p>
        </div>
        <div className="flex flex-col items-center rounded-2xl border border-gray-200 bg-white p-8 text-center shadow-sm dark:border-gray-700 dark:bg-gray-900">
          <Monitor className="size-10 text-primary" aria-hidden />
          <p className="mt-4 font-semibold text-gray-900 dark:text-white">Desktop</p>
          <p className="mt-2 text-sm text-gray-600 dark:text-gray-300">Download for Desktop</p>
        </div>
      </div>

      <div className="mt-16 flex flex-col items-center">
        <div className="size-40 rounded-lg bg-gray-200 dark:bg-gray-800" aria-hidden />
        <p className="mt-4 text-sm font-medium text-gray-700 dark:text-gray-300">Scan to download</p>
      </div>

      <div className="mx-auto mt-16 max-w-2xl rounded-2xl border border-gray-200 bg-gray-50 p-6 dark:border-gray-700 dark:bg-gray-900">
        <h2 className="text-lg font-semibold text-gray-900 dark:text-white">System requirements</h2>
        <ul className="mt-3 list-disc space-y-2 pl-5 text-sm text-gray-700 dark:text-gray-300">
          <li>Windows 10+, macOS 12+, or recent Linux desktop</li>
          <li>8 GB RAM minimum, 16 GB recommended</li>
          <li>Stable broadband internet connection</li>
          <li>Modern Chromium, Firefox, or Safari browser</li>
        </ul>
      </div>
    </div>
  )
}
