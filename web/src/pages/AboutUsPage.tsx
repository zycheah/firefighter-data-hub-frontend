const lorem150 =
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem.'

const team = [
  { name: 'Lorem Ipsum', role: 'Product Lead', initials: 'LI' },
  { name: 'Dolor Sit', role: 'Engineering', initials: 'DS' },
  { name: 'Amet Consectetur', role: 'Research', initials: 'AC' },
  { name: 'Adipiscing Elit', role: 'Design', initials: 'AE' },
] as const

export default function AboutUsPage() {
  return (
    <div>
      <section className="bg-gradient-to-r from-primary to-primary-hover px-4 py-16 text-white sm:px-6">
        <div className="mx-auto max-w-4xl text-center">
          <h1 className="text-4xl font-bold">About Us</h1>
          <p className="mx-auto mt-4 max-w-2xl text-blue-100">
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt
            ut labore et dolore magna aliqua.
          </p>
        </div>
      </section>

      <section className="mx-auto grid max-w-6xl gap-10 px-4 py-16 lg:grid-cols-2 lg:items-start lg:px-6">
        <h2 className="text-3xl font-bold text-gray-900 dark:text-white">Our Mission</h2>
        <div className="space-y-6 text-gray-700 dark:text-gray-300">
          <p>{lorem150}</p>
          <p>{lorem150}</p>
          <p>{lorem150}</p>
        </div>
      </section>

      <section className="bg-gray-50 px-4 py-16 dark:bg-gray-900 sm:px-6">
        <h2 className="text-center text-3xl font-bold text-gray-900 dark:text-white">
          Meet the Team
        </h2>
        <div className="mx-auto mt-10 grid max-w-6xl gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {team.map((m) => (
            <div
              key={m.name}
              className="rounded-2xl border border-gray-200 bg-white p-6 text-center shadow-sm dark:border-gray-700 dark:bg-gray-950"
            >
              <div className="mx-auto flex size-16 items-center justify-center rounded-full bg-primary/10 text-lg font-bold text-primary">
                {m.initials}
              </div>
              <p className="mt-4 font-semibold text-gray-900 dark:text-white">{m.name}</p>
              <p className="text-sm text-gray-600 dark:text-gray-400">{m.role}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="mx-auto max-w-6xl px-4 py-16 sm:px-6">
        <div className="grid gap-6 md:grid-cols-3">
          {[
            {
              title: 'Integrity',
              body: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            },
            {
              title: 'Transparency',
              body: 'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat duis aute.',
            },
            {
              title: 'Safety',
              body: 'Irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur excepteur sint occaecat.',
            },
          ].map((v) => (
            <div
              key={v.title}
              className="rounded-2xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-700 dark:bg-gray-900"
            >
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white">{v.title}</h3>
              <p className="mt-3 text-sm leading-relaxed text-gray-600 dark:text-gray-300">
                {v.body}
              </p>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
