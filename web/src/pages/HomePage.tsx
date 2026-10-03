import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { ChevronDown } from 'lucide-react'
import { ROUTES } from '@/constants/routes'
import { cn } from '@/utils/cn'

const faqs = [
  {
    q: 'What is this platform?',
    a: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
  },
  {
    q: 'Who can access the data?',
    a: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
  },
  {
    q: 'How is my data protected?',
    a: 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
  },
  {
    q: 'How do I verify my university email?',
    a: 'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
  },
  {
    q: 'Can I export datasets?',
    a: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
  },
  {
    q: 'Where can I get support?',
    a: 'Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur.',
  },
] as const

export default function HomePage() {
  const [openId, setOpenId] = useState<number | null>(0)

  const scrollToFaq = () => {
    document.getElementById('faq')?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    if (window.location.hash === '#faq') {
      scrollToFaq()
    }
  }, [])

  return (
    <div>
      <section className="flex min-h-[calc(100svh-4rem)] flex-col justify-center bg-gradient-to-b from-blue-50 to-white px-4 py-16 dark:from-gray-900 dark:to-gray-800">
        <div className="mx-auto max-w-4xl text-center">
          <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-5xl dark:text-white">
            Firefighter exposure analytics, simplified
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-lg text-gray-600 dark:text-gray-300">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Explore dashboards, tables, and
            secure research workflows in one hub.
          </p>
          <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
            <Link
              to={ROUTES.register}
              className="rounded-lg bg-primary px-6 py-3 font-semibold text-white hover:bg-primary-hover"
            >
              Get Started
            </Link>
            <button
              type="button"
              onClick={scrollToFaq}
              className="rounded-lg border border-gray-300 bg-white px-6 py-3 font-semibold text-gray-800 hover:bg-gray-50 dark:border-gray-600 dark:bg-gray-900 dark:text-gray-100 dark:hover:bg-gray-800"
            >
              Learn More
            </button>
          </div>
        </div>
      </section>

      <section id="faq" className="mx-auto max-w-3xl px-4 py-16 sm:px-6">
        <h2 className="text-center text-3xl font-bold text-gray-900 dark:text-white">
          Frequently asked questions
        </h2>
        <div className="mt-10 space-y-3">
          {faqs.map((item, index) => {
            const open = openId === index
            return (
              <div
                key={item.q}
                className="overflow-hidden rounded-xl border border-gray-200 bg-white dark:border-gray-700 dark:bg-gray-900"
              >
                <button
                  type="button"
                  className="flex w-full items-center justify-between gap-4 px-4 py-4 text-left text-base font-semibold text-gray-900 dark:text-white"
                  aria-expanded={open}
                  onClick={() => setOpenId(open ? null : index)}
                >
                  {item.q}
                  <ChevronDown
                    className={cn(
                      'size-5 shrink-0 text-gray-500 transition-transform duration-300',
                      open && 'rotate-180'
                    )}
                    aria-hidden
                  />
                </button>
                <div
                  className={cn(
                    'grid transition-all duration-300',
                    open ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'
                  )}
                >
                  <div className="min-h-0 overflow-hidden">
                    <p className="px-4 pb-4 text-sm leading-relaxed text-gray-600 dark:text-gray-300">
                      {item.a}
                    </p>
                  </div>
                </div>
              </div>
            )
          })}
        </div>
      </section>
    </div>
  )
}
