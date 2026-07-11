"use client";

import Link from "next/link";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { api, setAuthToken } from "@/lib/api";
import { Loader2, Eye, EyeOff } from "lucide-react";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<React.ReactNode>("");
  const [isLoading, setIsLoading] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  useEffect(() => {
    const savedEmail = localStorage.getItem('rh_remembered_email');
    if (savedEmail) {
      setEmail(savedEmail);
      setRememberMe(true);
    }
  }, []);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setIsLoading(true);

    try {
      const response = await api.auth.login({ email, password });

      if (rememberMe) {
        localStorage.setItem('rh_remembered_email', email);
      } else {
        localStorage.removeItem('rh_remembered_email');
      }

      if (response.accessToken) {
        setAuthToken(response.accessToken, response.refreshToken);

        if (typeof window !== 'undefined') {
          localStorage.setItem('rh_user', JSON.stringify({
            id: response.user?.id,
            email: response.user?.email,
            name: response.user?.name,
            role: response.user?.role,
            requiresMfa: response.requiresMfa
          }));
        }

        if (response.requiresMfa) {
          router.push('/login/mfa');
          return;
        }

        // Role-based routing — redirect to the correct portal
        const role = response.user?.role;
        if (role === 'ADMIN') {
          router.push('/superadmin');
        } else if (role === 'ORGANIZATION') {
          // Org accounts — send them to the org dashboard
          const sessionId = crypto.randomUUID();
          localStorage.setItem('rh_session_id', sessionId);
          router.push(`/dashboard/${sessionId}`);
        } else {
          // Standard USER
          router.push('/');
        }
      } else {
        setError("Invalid response from server. Missing token.");
      }
    } catch (err: any) {
      setError(err.message || "Failed to authenticate. Please check your credentials.");
    } finally {
      setIsLoading(false);
    }
  };


  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">
      <div className="flex-1 flex items-center justify-center py-12 px-6 bg-muted/20">
        <div className="w-full max-w-md bg-background rounded-3xl p-8 border border-muted shadow-sm">
          <div className="text-center mb-8">
            <h1 className="text-3xl font-extrabold tracking-tight mb-2">Welcome back</h1>
            <p className="text-sm text-muted-foreground">Sign in to your ResultHub account to continue.</p>
          </div>

          <form className="space-y-4" onSubmit={handleLogin}>
            
            {error && (
              <div className="p-3 bg-red-50 text-red-600 text-sm font-medium rounded-xl border border-red-100 mb-4">
                {error}
              </div>
            )}

            <div>
              <label className="block text-sm font-semibold mb-2" htmlFor="email">Email address</label>
              <input 
                id="email" 
                type="email" 
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full px-4 py-2.5 rounded-xl border border-muted bg-background outline-none focus:border-primary transition-colors text-sm" 
                placeholder="name@organization.edu" 
              />
            </div>
            <div className="relative">
              <label className="block text-sm font-semibold mb-2" htmlFor="password">Password</label>
              <div className="relative">
                <input 
                  id="password" 
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="w-full px-4 py-2.5 rounded-xl border border-muted bg-background outline-none focus:border-primary transition-colors text-sm pr-10" 
                  placeholder="••••••••" 
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground transition-colors"
                >
                  {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
            </div>
            
            <div className="flex items-center justify-between mt-2">
              <label className="flex items-center gap-2 text-sm text-muted-foreground cursor-pointer select-none">
                <input 
                  type="checkbox" 
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="rounded border-muted w-4 h-4 text-primary focus:ring-primary cursor-pointer" 
                />
                Remember me
              </label>
              <Link href="/forgot-password" className="text-sm font-medium text-primary hover:underline">
                Forgot password?
              </Link>
            </div>

            <button 
              type="submit" 
              disabled={isLoading}
              className="w-full mt-6 py-3 rounded-xl bg-foreground text-background font-semibold shadow hover:bg-foreground/90 transition-colors disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {isLoading ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin" />
                  Authenticating...
                </>
              ) : (
                'Sign In'
              )}
            </button>
          </form>

          <div className="mt-6 flex items-center gap-4 text-xs text-muted-foreground before:h-px before:flex-1 before:bg-muted after:h-px after:flex-1 after:bg-muted">
            OR CONTINUE WITH
          </div>

          <div className="mt-6 grid grid-cols-2 gap-4">
            <button className="flex items-center justify-center gap-2 py-2.5 border border-muted rounded-xl hover:bg-muted/50 transition-colors text-sm font-medium">
              Google
            </button>
            <button className="flex items-center justify-center gap-2 py-2.5 border border-muted rounded-xl hover:bg-muted/50 transition-colors text-sm font-medium">
              GitHub
            </button>
          </div>

          <p className="mt-6 text-center text-sm text-muted-foreground">
            Don&apos;t have an account?{' '}
            <Link href="/signup" className="font-semibold text-primary hover:underline">
              Sign up
            </Link>
          </p>

          {/* Portal Switcher */}
          <div className="mt-6 pt-5 border-t border-muted space-y-2">
            <p className="text-xs text-center text-muted-foreground font-medium uppercase tracking-wider mb-3">Other Portals</p>
            <Link
              href="/organization/login"
              className="flex items-center justify-between w-full px-4 py-3 rounded-xl border border-muted hover:border-primary/30 hover:bg-primary/5 transition-all group"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-violet-100 text-violet-600 flex items-center justify-center">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/></svg>
                </div>
                <div>
                  <p className="text-sm font-semibold text-foreground">Organization Portal</p>
                  <p className="text-xs text-muted-foreground">For institutions &amp; publishers</p>
                </div>
              </div>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-muted-foreground group-hover:text-primary transition-colors"><polyline points="9 18 15 12 9 6"/></svg>
            </Link>
            <Link
              href="/superadmin"
              className="flex items-center justify-between w-full px-4 py-3 rounded-xl border border-muted hover:border-red-300 hover:bg-red-50/50 transition-all group"
            >
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-red-100 text-red-600 flex items-center justify-center">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                </div>
                <div>
                  <p className="text-sm font-semibold text-foreground">Admin Panel</p>
                  <p className="text-xs text-muted-foreground">Super administrators only</p>
                </div>
              </div>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-muted-foreground group-hover:text-red-500 transition-colors"><polyline points="9 18 15 12 9 6"/></svg>
            </Link>
          </div>
        </div>
      </div>
    </main>
  );
}
