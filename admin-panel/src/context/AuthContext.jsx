import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { api, getToken, setToken } from "../lib/api.js";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [admin, setAdmin] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function bootstrap() {
      if (!getToken()) {
        setLoading(false);
        return;
      }
      try {
        const data = await api.me();
        setAdmin(data.admin);
      } catch {
        setToken(null);
      } finally {
        setLoading(false);
      }
    }
    bootstrap();
  }, []);

  const value = useMemo(
    () => ({
      admin,
      user: admin,
      loading,
      async login(phone, password) {
        const data = await api.login(phone, password);
        setToken(data.token);
        setAdmin(data.admin);
        return data;
      },
      async logout() {
        try {
          await api.logout();
        } catch {
          /* ignore */
        }
        setToken(null);
        setAdmin(null);
      }
    }),
    [admin, loading]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
