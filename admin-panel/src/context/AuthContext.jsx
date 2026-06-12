import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { api, getToken, setToken } from "../lib/api.js";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [business, setBusiness] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function bootstrap() {
      if (!getToken()) {
        setLoading(false);
        return;
      }
      try {
        const data = await api.me();
        setUser(data.user);
        setBusiness(data.business);
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
      user,
      business,
      loading,
      async login(phone, password) {
        const data = await api.login(phone, password);
        setToken(data.token);
        setUser(data.user);
        const me = await api.me();
        setBusiness(me.business);
        return data;
      },
      async logout() {
        try {
          await api.logout();
        } catch {
          /* ignore */
        }
        setToken(null);
        setUser(null);
        setBusiness(null);
      }
    }),
    [user, business, loading]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
