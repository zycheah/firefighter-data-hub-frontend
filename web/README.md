# Web Dashboard

Researcher-facing web application for the Firefighter Safety Data Hub. Researchers sign in, view summary statistics and browse or export the data collected by the mobile app.

---

## 1. Tech stack

| Area | Library |
|---|---|
| Framework | React 19, TypeScript |
| Build tool | Vite |
| Styling | Tailwind CSS 4 |
| Routing | React Router 7 |
| Server state | TanStack Query |
| Tables | TanStack Table |
| Client state | Zustand (auth token, persisted in `localStorage`) |
| Forms and validation | React Hook Form, Zod |
| Charts | Recharts |
| HTTP | Axios |
| Notifications | react-hot-toast |
| Icons | lucide-react |

---

## 2. Getting started

### Step 1: Install the prerequisites

- Node.js 20.19 or newer (`node --version`)
- A running API (see the `firefighter-data-hub-backend` repository)

### Step 2: Install dependencies

```bash
cd web
npm install
```

### Step 3: Configure the environment

```bash
cp .env.example .env
```

For a **local API**, keep `VITE_API_BASE_URL` empty and set the proxy target. Vite forwards `/api` requests to it, which avoids CORS issues:

```env
API_PROXY_TARGET=http://127.0.0.1:8000
VITE_APP_NAME=Firefighter Safety Data Hub
```

For a **deployed API**, set the full web API address:

```env
VITE_API_BASE_URL=https://<API_HOST>/api/v1/web_api
VITE_APP_NAME=Firefighter Safety Data Hub
```

### Step 4: Start the development server

```bash
npm run dev
```

Open <http://localhost:5173>, register a researcher account and sign in.

> **Known issue.** On a new local database, registration and sign-in fail until the `users_researcher` table exists.

---

## 3. Scripts

| Command | Description |
|---|---|
| `npm run dev` | Development server with hot reload |
| `npm run build` | Type-check and build the production bundle into `dist/` |
| `npm run preview` | Serve the production build locally |
| `npm run lint` | Run ESLint. Currently reports two existing errors (item D7 in the roadmap) |

---

## 4. Environment variables

| Variable | Used at | Description |
|---|---|---|
| `VITE_API_BASE_URL` | Build time | Full web API base URL, no trailing slash. When empty in development, requests go to `/api/v1/web_api` on the same origin and are proxied. |
| `API_PROXY_TARGET` | Dev / preview server | Address the Vite proxy forwards `/api` to. Defaults to `http://127.0.0.1:8080`, so set it to the port your API uses. |
| `VITE_APP_NAME` | Build time | Application name shown in the UI |

`VITE_*` variables are embedded in the JavaScript bundle and are visible to anyone. Never put secrets in them.

---

## 5. Pages

| Route | Page | Access | API calls (`/api/v1/web_api`) |
|---|---|---|---|
| `/` | Home | Public | – |
| `/about`, `/download` | About, app download | Public | – |
| `/contact` | Contact form | Public | `POST /contact` (not yet implemented in the API) |
| `/account-request` | Account request form | Public | `POST /account-requests` (not yet implemented in the API) |
| `/login` | Sign in | Signed-out only | `POST /auth/login` |
| `/register` | Researcher registration | Signed-out only | `POST /auth/register` |
| `/forgot-password`, `/reset-password` | Password recovery | Public | Not yet implemented in the API |
| `/verify-email/success`, `/verify-email/failed` | Email verification result | Public | – |
| `/dashboard` | KPI cards and charts | Signed in | `GET /dashboard/summary` |
| `/table` | GPS location table and CSV export | Signed in | `GET /data/tabledata`, `GET /table/export-csv` |
| `/event-table` | Fire event table and CSV export | Signed in | `GET /table/eventdata`, `GET /table/export-event-data` |
| `/profile` | Profile and password change | Signed in | `GET`/`PUT /auth/me`, `POST /auth/password-reset` |
| `/401`, `*` | Unauthorised, not found | Public | – |

Routes are defined in `src/router/index.tsx`. Signed-in routes are wrapped in `ProtectedRoute`. Pages are lazy-loaded.

---

## 6. Project structure

```
web/
├── index.html
├── vite.config.ts            # Plugins, "@" alias for src/, /api proxy
├── .env.example
└── src/
    ├── main.tsx              # Entry point
    ├── App.tsx               # Providers: React Query, theme, toasts, error boundary
    ├── router/index.tsx      # Route table
    ├── api/
    │   ├── axiosInstance.ts  # Base URL, bearer token, 401 handling
    │   └── *.api.ts          # One module per API area
    ├── store/authStore.ts    # Access token and user (Zustand, persisted)
    ├── pages/                # One component per route
    ├── features/             # Feature components: auth forms, dashboard, tables
    ├── components/
    │   ├── layout/           # Navbar, sidebar, footer, layouts
    │   └── shared/           # Route guards, loaders, error boundary
    ├── hooks/                # useAuth, useTheme, useDebounce
    ├── context/              # Theme context (light/dark)
    ├── constants/            # Route paths, React Query keys
    ├── types/                # TypeScript types for API data
    └── utils/                # Helpers (class names, token utilities)
```

### How a request works

1. A page or feature calls a function in `src/api/*.api.ts`, usually through a React Query hook.
2. `axiosInstance` adds `Authorization: Bearer <token>` from the auth store.
3. On a `401`, the interceptor tries to refresh the token once. If that fails, the user is signed out and redirected to `/login` (or `/401` from the dashboard).
4. Server errors (`5xx`) show a toast.

---

## 7. Adding a feature

1. Add the API call in `src/api/` and its types in `src/types/`.
2. Add a query key in `src/constants/queryKeys.ts` if the data is fetched with React Query.
3. Build the UI in `src/features/<feature>/` and a page in `src/pages/`.
4. Register the route in `src/router/index.tsx` and its path in `src/constants/routes.ts`. Wrap it in `ProtectedRoute` if it requires sign-in.
5. Run `npm run lint` and `npm run build`.

---

## 8. Deployment

`npm run build` produces static files in `dist/`. Host them on any static host (for example Amazon S3 with CloudFront, Netlify, Vercel or Nginx).

1. Set `VITE_API_BASE_URL` to the production API before building.
2. Configure the host to serve `index.html` for unknown paths, so that client-side routes work on refresh.
3. Add the dashboard's URL to the API's `CORS_ORIGINS`.
