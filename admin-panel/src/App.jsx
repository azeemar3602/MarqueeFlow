import { Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider, useAuth } from "./context/AuthContext.jsx";
import Layout from "./components/Layout.jsx";
import LoginPage from "./pages/LoginPage.jsx";
import DashboardPage from "./pages/DashboardPage.jsx";
import MarqueesPage from "./pages/MarqueesPage.jsx";
import MarqueeDetailPage from "./pages/MarqueeDetailPage.jsx";
import ApprovalsPage from "./pages/ApprovalsPage.jsx";
import PlansPage from "./pages/PlansPage.jsx";
import SubscriptionsAdminPage from "./pages/SubscriptionsAdminPage.jsx";
import CustomPlansPage from "./pages/CustomPlansPage.jsx";
import BookingsPage from "./pages/BookingsPage.jsx";
import CalendarPage from "./pages/CalendarPage.jsx";
import CustomersPage from "./pages/CustomersPage.jsx";
import PackagesPage from "./pages/PackagesPage.jsx";
import PaymentsPage from "./pages/PaymentsPage.jsx";
import TeamPage from "./pages/TeamPage.jsx";
import NotificationsPage from "./pages/NotificationsPage.jsx";
import ReportsPage from "./pages/ReportsPage.jsx";
import SettingsPage from "./pages/SettingsPage.jsx";
import AdminUsersPage from "./pages/AdminUsersPage.jsx";
import AuditLogsPage from "./pages/AuditLogsPage.jsx";

function ProtectedRoute({ children }) {
  const { admin, loading } = useAuth();
  if (loading) return <div className="login-page"><p>Loading...</p></div>;
  if (!admin) return <Navigate to="/login" replace />;
  return children;
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route
        path="/"
        element={
          <ProtectedRoute>
            <Layout />
          </ProtectedRoute>
        }
      >
        <Route index element={<DashboardPage />} />
        <Route path="marquees" element={<MarqueesPage />} />
        <Route path="marquees/:id" element={<MarqueeDetailPage />} />
        <Route path="approvals" element={<ApprovalsPage />} />
        <Route path="plans" element={<PlansPage />} />
        <Route path="subscriptions" element={<SubscriptionsAdminPage />} />
        <Route path="custom-plans" element={<CustomPlansPage />} />
        <Route path="payments" element={<PaymentsPage />} />
        <Route path="bookings" element={<BookingsPage />} />
        <Route path="calendar" element={<CalendarPage />} />
        <Route path="customers" element={<CustomersPage />} />
        <Route path="packages" element={<PackagesPage />} />
        <Route path="team" element={<TeamPage />} />
        <Route path="notifications" element={<NotificationsPage />} />
        <Route path="reports" element={<ReportsPage />} />
        <Route path="admin-users" element={<AdminUsersPage />} />
        <Route path="settings" element={<SettingsPage />} />
        <Route path="audit-logs" element={<AuditLogsPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <AppRoutes />
    </AuthProvider>
  );
}
