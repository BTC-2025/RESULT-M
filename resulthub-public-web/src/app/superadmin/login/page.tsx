"use client";

import Link from "next/link";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { api, setAuthToken } from "@/lib/api";
import { Loader2, Eye, EyeOff, Shield } from "lucide-react";

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail]           = useState("");
  const [password, setPassword]     = useState("");
  const [error, setError]           = useState("");
  const [isLoading, setIsLoading]   = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // If already logged in as admin, go straight to dashboard
  useEffect(() => {
    const token = localStorage.getItem("rh_token");
    if (token) {
      try {
        const payload = JSON.parse(atob(token.split(".")[1]));
        const roles: string[] = payload.roles || payload.authorities || [];
        if (roles.some((r: string) => r.includes("ADMIN"))) {
          router.replace("/superadmin");
        }
      } catch {}
    }
  }, [router]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      const response = await api.auth.login({ email, password });

      if (response.accessToken) {
        // Check role before storing token
        const role = response.role;
        if (role !== "ADMIN") {
          setError("Access denied. This portal is for Super Administrators only.");
          setIsLoading(false);
          return;
        }

        setAuthToken(response.accessToken, response.refreshToken);
        if (typeof window !== "undefined") {
          localStorage.setItem("rh_user", JSON.stringify({
            id: response.userId,
            email: response.email,
            role: response.role,
          }));
        }
        router.push("/superadmin");
      } else {
        setError("Invalid response from server.");
      }
    } catch (err: any) {
      setError(err.message || "Authentication failed. Please check your credentials.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <main className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-6 py-12">
      <div className="w-full max-w-md">

        {/* Brand */}
        <div className="text-center mb-8">
          <div className="mx-auto w-14 h-14 rounded-2xl bg-gradient-to-br from-red-500 to-rose-600 flex items-center justify-center shadow-2xl shadow-red-900/40 mb-4">
            <Shield className="w-7 h-7 text-white" />
          </div>
          <h1 className="text-3xl font-black text-white tracking-tight">Admin Portal</h1>
          <p className="text-white/40 text-sm font-medium mt-1">Restricted access — Super Administrators only</p>
        </div>

        {/* Card */}
        <div className="bg-white/[0.03] border border-white/[0.08] rounded-3xl p-8 backdrop-blur-sm">

          {error && (
            <div className="mb-5 px-4 py-3 bg-red-500/10 border border-red-500/20 rounded-xl text-sm text-red-400 font-medium">
              {error}
            </div>
          )}

          <form className="space-y-5" onSubmit={handleLogin}>
            <div>
              <label className="block text-sm font-semibold text-white/60 mb-2" htmlFor="email">
                Admin Email
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                autoComplete="email"
                className="w-full px-4 py-3 rounded-xl bg-white/5 border border-white/10 text-white placeholder:text-white/20 outline-none focus:border-red-500/50 focus:bg-white/[0.07] transition-all text-sm"
                placeholder="admin@resulthub.com"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-white/60 mb-2" htmlFor="password">
                Password
              </label>
              <div className="relative">
                <input
                  id="password"
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  autoComplete="current-password"
                  className="w-full px-4 py-3 pr-11 rounded-xl bg-white/5 border border-white/10 text-white placeholder:text-white/20 outline-none focus:border-red-500/50 focus:bg-white/[0.07] transition-all text-sm"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-white/30 hover:text-white/60 transition-colors"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full mt-2 py-3 rounded-xl bg-gradient-to-r from-red-500 to-rose-600 text-white font-bold shadow-lg shadow-red-900/30 hover:opacity-90 transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {isLoading ? (
                <><Loader2 className="w-5 h-5 animate-spin" /> Authenticating...</>
              ) : (
                "Sign In to Admin Panel"
              )}
            </button>
          </form>

          {/* Portal Switcher */}
          <div className="mt-8 pt-6 border-t border-white/[0.06] space-y-2">
            <p className="text-[10px] text-center text-white/20 font-bold uppercase tracking-widest mb-3">Other Portals</p>
            <Link
              href="/login"
              className="flex items-center justify-between w-full px-4 py-3 rounded-xl border border-white/[0.06] hover:border-white/20 hover:bg-white/[0.03] transition-all group"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-blue-500/20 text-blue-400 flex items-center justify-center">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                </div>
                <div>
                  <p className="text-sm font-semibold text-white/70">User Login</p>
                  <p className="text-xs text-white/30">For public users</p>
                </div>
              </div>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-white/20 group-hover:text-white/50"><polyline points="9 18 15 12 9 6"/></svg>
            </Link>
            <Link
              href="/organization/login"
              className="flex items-center justify-between w-full px-4 py-3 rounded-xl border border-white/[0.06] hover:border-white/20 hover:bg-white/[0.03] transition-all group"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-violet-500/20 text-violet-400 flex items-center justify-center">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/></svg>
                </div>
                <div>
                  <p className="text-sm font-semibold text-white/70">Organization Portal</p>
                  <p className="text-xs text-white/30">For institutions &amp; publishers</p>
                </div>
              </div>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-white/20 group-hover:text-white/50"><polyline points="9 18 15 12 9 6"/></svg>
            </Link>
          </div>
        </div>

        <p className="text-center text-[11px] text-white/20 mt-6">
          © 2026 ResultHub Corp. · Unauthorized access is prohibited.
        </p>
      </div>
    </main>
  );
}
