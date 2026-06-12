import { Navigate, Route, Routes } from "react-router-dom";
import { AuthProvider, useAuth } from "./context/AuthContext.jsx";
import Layout from "./components/Layout.jsx";
import LoginPage from "./pages/LoginPage.jsx";
import DashboardPage from "./pages/DashboardPage.jsx";
import BusinessesPage from "./pages/BusinessesPage.jsx";
import PlansPage from "./pages/PlansPage.jsx";
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

function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) return <div className="login-page"><p>Loading...</p></div>;
  if (!user) return <Navigate to="/login" replace />;
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
        <Route path="businesses" element={<BusinessesPage />} />
        <Route path="plans" element={<PlansPage />} />
        <Route path="custom-plans" element={<CustomPlansPage />} />
        <Route path="bookings" element={<BookingsPage />} />
        <Route path="calendar" element={<CalendarPage />} />
        <Route path="customers" element={<CustomersPage />} />
        <Route path="packages" element={<PackagesPage />} />
        <Route path="payments" element={<PaymentsPage />} />
        <Route path="team" element={<TeamPage />} />
        <Route path="notifications" element={<NotificationsPage />} />
        <Route path="reports" element={<ReportsPage />} />
        <Route path="settings" element={<SettingsPage />} />
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
