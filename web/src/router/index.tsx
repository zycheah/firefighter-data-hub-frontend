/* eslint-disable react-refresh/only-export-components -- router config + lazy page chunks */
import { Suspense, lazy, type ReactNode } from 'react'
import { Navigate, createBrowserRouter } from 'react-router-dom'
import { AppLayout } from '@/components/layout/AppLayout'
import { PublicLayout } from '@/components/layout/PublicLayout'
import { PageLoader } from '@/components/shared/PageLoader'
import { ProtectedRoute } from '@/components/shared/ProtectedRoute'
import { PublicRoute } from '@/components/shared/PublicRoute'
import { ROUTES } from '@/constants/routes'

const HomePage = lazy(() => import('@/pages/HomePage'))
const LoginPage = lazy(() => import('@/pages/LoginPage'))
const RegisterPage = lazy(() => import('@/pages/RegisterPage'))
const ForgotPasswordPage = lazy(() => import('@/pages/ForgotPasswordPage'))
const ResetPasswordPage = lazy(() => import('@/pages/ResetPasswordPage'))
const AboutUsPage = lazy(() => import('@/pages/AboutUsPage'))
const ContactPage = lazy(() => import('@/pages/ContactPage'))
const EmailVerifiedPage = lazy(() => import('@/pages/EmailVerifiedPage'))
const EmailVerificationFailedPage = lazy(() => import('@/pages/EmailVerificationFailedPage'))
const AccountRequestPage = lazy(() => import('@/pages/AccountRequestPage'))
const DownloadAppPage = lazy(() => import('@/pages/DownloadAppPage'))
const Error401Page = lazy(() => import('@/pages/error401'))
const DashboardPage = lazy(() => import('@/pages/DashboardPage'))
const TableViewPage = lazy(() => import('@/pages/TableViewPage'))
const EventTablePage = lazy(() => import('@/pages/EventTablePage'))
const ProfilePage = lazy(() => import('../pages/ProfilePage'))
const NotFoundPage = lazy(() => import('@/pages/NotFoundPage'))

function SuspensePage({ children }: { children: ReactNode }) {
  return <Suspense fallback={<PageLoader />}>{children}</Suspense>
}

export const router = createBrowserRouter([
  {
    path: '/',
    element: <PublicLayout />,
    children: [
      {
        index: true,
        element: (
          <SuspensePage>
            <HomePage />
          </SuspensePage>
        ),
      },
      {
        path: 'login',
        element: <PublicRoute />,
        children: [
          {
            index: true,
            element: (
              <SuspensePage>
                <LoginPage />
              </SuspensePage>
            ),
          },
        ],
      },
      {
        path: 'register',
        element: <PublicRoute />,
        children: [
          {
            index: true,
            element: (
              <SuspensePage>
                <RegisterPage />
              </SuspensePage>
            ),
          },
        ],
      },
      {
        path: 'forgot-password',
        element: (
          <SuspensePage>
            <ForgotPasswordPage />
          </SuspensePage>
        ),
      },
      {
        path: 'reset-password',
        element: (
          <SuspensePage>
            <ResetPasswordPage />
          </SuspensePage>
        ),
      },
      {
        path: 'about',
        element: (
          <SuspensePage>
            <AboutUsPage />
          </SuspensePage>
        ),
      },
      {
        path: 'contact',
        element: (
          <SuspensePage>
            <ContactPage />
          </SuspensePage>
        ),
      },
      {
        path: 'verify-email/success',
        element: (
          <SuspensePage>
            <EmailVerifiedPage />
          </SuspensePage>
        ),
      },
      {
        path: 'verify-email/failed',
        element: (
          <SuspensePage>
            <EmailVerificationFailedPage />
          </SuspensePage>
        ),
      },
      {
        path: 'account-request',
        element: (
          <SuspensePage>
            <AccountRequestPage />
          </SuspensePage>
        ),
      },
      {
        path: 'download',
        element: (
          <SuspensePage>
            <DownloadAppPage />
          </SuspensePage>
        ),
      },
      {
        path: '401',
        element: (
          <SuspensePage>
            <Error401Page />
          </SuspensePage>
        ),
      },
      {
        path: 'verify',
        element: <Navigate to={ROUTES.verifyEmailSuccess} replace />,
      },
      {
        path: 'failedVerification',
        element: <Navigate to={ROUTES.verifyEmailFailed} replace />,
      },
      {
        path: 'tablePage',
        element: <Navigate to={ROUTES.table} replace />,
      },
    ],
  },
  {
    element: <ProtectedRoute />,
    children: [
      {
        path: 'dashboard',
        element: <AppLayout />,
        children: [
          {
            index: true,
            element: (
              <SuspensePage>
                <DashboardPage />
              </SuspensePage>
            ),
          },
        ],
      },
      {
        path: 'table',
        element: <AppLayout />,
        children: [
          {
            index: true,
            element: (
              <SuspensePage>
                <TableViewPage />
              </SuspensePage>
            ),
          },
        ],
      },
      {
        path: 'event-table',
        element: <AppLayout />,
        children: [
          {
            index: true,
            element: (
              <SuspensePage>
                <EventTablePage />
              </SuspensePage>
            ),
          },
        ],
      },
      {
        path: 'profile',
        element: <AppLayout />,
        children: [
          {
            index: true,
            element: (
              <SuspensePage>
                <ProfilePage />
              </SuspensePage>
            ),
          },
        ],
      },
    ],
  },
  {
    path: '*',
    element: (
      <SuspensePage>
        <NotFoundPage />
      </SuspensePage>
    ),
  },
])
