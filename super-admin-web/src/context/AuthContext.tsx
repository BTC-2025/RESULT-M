"use client";

import React, { createContext, useContext, useState, useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';

interface UserProfile {
  id: string;
  email: string;
  name: string;
  role: 'USER' | 'ADMIN' | 'ORGANIZATION';
}

interface AuthContextType {
  token: string | null;
  refreshToken: string | null;
  user: UserProfile | null;
  loading: boolean;
  login: (token: string, refreshToken: string, user: UserProfile) => void;
  logout: () => void;
  apiFetch: (url: string, options?: RequestInit) => Promise<Response>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(null);
  const [refreshToken, setRefreshToken] = useState<string | null>(null);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const pathname = usePathname();

  useEffect(() => {
    // Load auth states from localStorage
    const savedToken = localStorage.getItem('admin_token');
    const savedRefreshToken = localStorage.getItem('admin_refresh_token');
    const savedUser = localStorage.getItem('admin_user');

    if (savedToken && savedUser) {
      try {
        const parsedUser = JSON.parse(savedUser) as UserProfile;
        if (parsedUser.role === 'ADMIN') {
          setToken(savedToken);
          setRefreshToken(savedRefreshToken);
          setUser(parsedUser);
        } else {
          // Force logout if not admin
          localStorage.removeItem('admin_token');
          localStorage.removeItem('admin_refresh_token');
          localStorage.removeItem('admin_user');
        }
      } catch (e) {
        localStorage.removeItem('admin_token');
        localStorage.removeItem('admin_refresh_token');
        localStorage.removeItem('admin_user');
      }
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    if (!loading) {
      const isLoginPage = pathname === '/login';
      if (!token && !isLoginPage) {
        router.push('/login');
      } else if (token && isLoginPage) {
        router.push('/');
      }
    }
  }, [token, loading, pathname, router]);

  const login = (newToken: string, newRefreshToken: string, newUser: UserProfile) => {
    if (newUser.role !== 'ADMIN') {
      throw new Error("Access Denied: Only platform administrators are permitted to enter this portal.");
    }
    localStorage.setItem('admin_token', newToken);
    if (newRefreshToken) localStorage.setItem('admin_refresh_token', newRefreshToken);
    localStorage.setItem('admin_user', JSON.stringify(newUser));
    setToken(newToken);
    setRefreshToken(newRefreshToken);
    setUser(newUser);
    router.push('/');
  };

  const logout = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_refresh_token');
    localStorage.removeItem('admin_user');
    setToken(null);
    setRefreshToken(null);
    setUser(null);
    router.push('/login');
  };

  // Wrapped fetch that automatically handles Authorization headers and 401s
  const apiFetch = async (url: string, options: RequestInit = {}): Promise<Response> => {
    const executeFetch = async (currentToken: string | null) => {
      const headers = new Headers(options.headers || {});
      
      if (currentToken) {
        headers.set('Authorization', `Bearer ${currentToken}`);
      }
      
      if (options.body && !(options.body instanceof FormData) && !headers.has('Content-Type')) {
        headers.set('Content-Type', 'application/json');
      }

      return fetch(url, { ...options, headers });
    };

    try {
      let activeToken = token || localStorage.getItem('admin_token');
      let response = await executeFetch(activeToken);

      if (response.status === 401) {
        const currentRefreshToken = refreshToken || localStorage.getItem('admin_refresh_token');
        if (currentRefreshToken) {
          try {
            const refreshRes = await fetch('/api/v1/auth/refresh', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ refreshToken: currentRefreshToken }),
            });

            if (refreshRes.ok) {
              const data = await refreshRes.json();
              const newToken = data.accessToken || data.token;
              const newRefreshToken = data.refreshToken;
              const userObj = data.user || { id: data.userId, email: data.email, name: data.name, role: data.role };

              localStorage.setItem('admin_token', newToken);
              if (newRefreshToken) localStorage.setItem('admin_refresh_token', newRefreshToken);
              setToken(newToken);
              setRefreshToken(newRefreshToken || currentRefreshToken);
              
              // Retry original request with new token
              response = await executeFetch(newToken);
            } else {
              logout();
            }
          } catch (refreshErr) {
            logout();
          }
        } else {
          logout();
        }
      }
      return response;
    } catch (error) {
      console.error("API Call Failed:", error);
      throw error;
    }
  };

  return (
    <AuthContext.Provider value={{ token, user, loading, login, logout, apiFetch }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used inside an AuthProvider');
  }
  return context;
}
