"use client";

import React, { useState } from 'react';
import { useAuth } from '@/context/AuthContext';
import { ShieldAlert, Mail, Lock, AlertCircle, Eye, EyeOff } from 'lucide-react';

export default function LoginPage() {
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [mfaRequired, setMfaRequired] = useState(false);
  const [mfaToken, setMfaToken] = useState<string | null>(null);
  const [mfaCode, setMfaCode] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      if (mfaRequired && mfaToken) {
        // Step 2: MFA verification
        const res = await fetch('/api/v1/auth/login/mfa', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ mfaToken, code: mfaCode }),
        });

        if (!res.ok) {
          const errText = await res.text();
          throw new Error(errText || "MFA verification failed. Invalid code.");
        }

        const data = await res.json();
        const user = data.user || { id: data.userId, email: data.email, name: data.name, role: data.role };
        const token = data.accessToken || data.token;
        const refreshToken = data.refreshToken;

        if (!token) throw new Error("Invalid server response. Authentication token not found.");
        login(token, refreshToken, user);
      } else {
        // Step 1: Initial login
        const res = await fetch('/api/v1/auth/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password }),
        });

        if (!res.ok) {
          const errText = await res.text();
          throw new Error(errText || "Authentication failed. Please check your credentials.");
        }

        const data = await res.json();
        
        if (data.mfaRequired) {
          setMfaRequired(true);
          setMfaToken(data.mfaToken);
          setLoading(false);
          return;
        }

        const user = data.user || { id: data.userId, email: data.email, name: data.name, role: data.role };
        const token = data.accessToken || data.token;
        const refreshToken = data.refreshToken;

        if (!token) throw new Error("Invalid server response. Authentication token not found.");
        login(token, refreshToken, user);
      }
    } catch (err: any) {
      setError(err.message || "An unexpected error occurred. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen p-4 relative overflow-hidden bg-[#030712]">
      {/* Background Glow effects */}
      <div className="absolute top-1/4 left-1/4 w-[400px] h-[400px] bg-accentPurple/15 rounded-full blur-[100px] pointer-events-none"></div>
      <div className="absolute bottom-1/4 right-1/4 w-[400px] h-[400px] bg-accentRose/10 rounded-full blur-[100px] pointer-events-none"></div>

      <div className="w-full max-w-md glass-panel p-8 rounded-3xl z-10 border border-white/5 shadow-glass">
        {/* Header Logo */}
        <div className="flex flex-col items-center mb-8">
          <div className="bg-gradient-to-tr from-accentIndigo via-accentPurple to-accentRose p-3.5 rounded-2xl text-textPrimary shadow-glow mb-4">
            <ShieldAlert className="w-8 h-8" />
          </div>
          <h2 className="text-2xl font-extrabold text-white tracking-wide">ResultHub Admin</h2>
          <p className="text-xs text-textSecondary mt-1 font-medium uppercase tracking-wider">Platform Administration Portal</p>
        </div>

        {/* Error Alert Box */}
        {error && (
          <div className="bg-accentRose/15 border border-accentRose/30 p-4 rounded-2xl flex items-start gap-3 text-accentRose text-xs font-semibold mb-6 animate-pulse">
            <AlertCircle className="w-4 h-4 shrink-0 mt-0.5" />
            <div>
              <p className="font-extrabold">Portal Entry Blocked</p>
              <p className="font-medium opacity-90 mt-0.5">{error}</p>
            </div>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          {!mfaRequired ? (
            <>
              {/* Email field */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-textSecondary uppercase tracking-wider block">Admin Email</label>
                <div className="relative">
                  <Mail className="absolute left-4 top-3.5 w-5 h-5 text-textSecondary" />
                  <input
                    type="email"
                    required
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="admin@resulthub.com"
                    className="w-full bg-black/40 border border-borderDark pl-12 pr-4 py-3.5 rounded-2xl text-sm text-textPrimary placeholder:text-textSecondary/50 focus:outline-none focus:border-accentPurple focus:ring-1 focus:ring-accentPurple transition-all duration-200"
                  />
                </div>
              </div>

              {/* Password field */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-textSecondary uppercase tracking-wider block">Security Credentials</label>
                <div className="relative">
                  <Lock className="absolute left-4 top-3.5 w-5 h-5 text-textSecondary" />
                  <input
                    type={showPassword ? "text" : "password"}
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••••••"
                    className="w-full bg-black/40 border border-borderDark pl-12 pr-12 py-3.5 rounded-2xl text-sm text-textPrimary placeholder:text-textSecondary/50 focus:outline-none focus:border-accentPurple focus:ring-1 focus:ring-accentPurple transition-all duration-200"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    className="absolute right-4 top-3.5 text-textSecondary hover:text-white"
                  >
                    {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                  </button>
                </div>
              </div>
            </>
          ) : (
            <>
              {/* MFA Code field */}
              <div className="space-y-2">
                <label className="text-xs font-bold text-textSecondary uppercase tracking-wider block">MFA Verification Code</label>
                <div className="relative">
                  <Lock className="absolute left-4 top-3.5 w-5 h-5 text-textSecondary" />
                  <input
                    type="text"
                    required
                    value={mfaCode}
                    onChange={(e) => setMfaCode(e.target.value)}
                    placeholder="123456"
                    className="w-full bg-black/40 border border-borderDark pl-12 pr-4 py-3.5 rounded-2xl text-sm text-textPrimary placeholder:text-textSecondary/50 focus:outline-none focus:border-accentPurple focus:ring-1 focus:ring-accentPurple transition-all duration-200"
                    autoFocus
                  />
                </div>
              </div>
            </>
          )}

          {/* Submit button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full mt-6 bg-gradient-to-r from-accentIndigo to-accentPurple text-white py-3.5 px-4 rounded-2xl font-extrabold text-sm tracking-wider uppercase transition-all duration-300 hover:opacity-90 hover:scale-[0.99] focus:outline-none focus:ring-2 focus:ring-accentPurple focus:ring-offset-2 focus:ring-offset-darkBg flex items-center justify-center gap-3 disabled:opacity-50 disabled:cursor-not-allowed shadow-glow"
          >
            {loading ? (
              <>
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                <span>{mfaRequired ? "Verifying MFA..." : "Verifying credentials..."}</span>
              </>
            ) : (
              <span>{mfaRequired ? "Verify OTP" : "Authenticate Portal"}</span>
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
