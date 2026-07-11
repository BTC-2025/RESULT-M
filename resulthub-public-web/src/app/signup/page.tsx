"use client";

import Link from "next/link";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { Loader2, ArrowLeft } from "lucide-react";

type Step = "DETAILS" | "OTP";

export default function SignupPage() {
  const router = useRouter();
  const [step, setStep] = useState<Step>("DETAILS");

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [otp, setOtp] = useState("");
  
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [resendTimer, setResendTimer] = useState(0);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (resendTimer > 0) {
      interval = setInterval(() => {
        setResendTimer((prev) => prev - 1);
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [resendTimer]);

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    setIsLoading(true);

    try {
      await api.auth.register({ name, email, password });
      setStep("OTP");
      setSuccess("Account pre-registered! An OTP has been sent to your email.");
      setResendTimer(120);
    } catch (err: any) {
      setError(err.message || "Failed to create account. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    setIsLoading(true);

    try {
      await api.auth.verifyOtp({ email, otp });
      setSuccess("Account fully verified! Redirecting to login...");
      setTimeout(() => router.push('/login'), 2000);
    } catch (err: any) {
      setError(err.message || "Invalid OTP. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleResendOtp = async () => {
    if (resendTimer > 0) return;
    setError("");
    setSuccess("");
    setIsLoading(true);

    try {
      await api.auth.register({ name, email, password }); // Resend logic
      setSuccess("A new OTP has been sent to your email address.");
      setResendTimer(120);
    } catch (err: any) {
      setError(err.message || "Failed to resend OTP.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">
      <div className="flex-1 flex items-center justify-center py-12 px-6 bg-muted/20">
        <div className="w-full max-w-md bg-background rounded-3xl p-8 border border-muted shadow-sm">
          
          {step === "OTP" && (
            <button 
              onClick={() => setStep("DETAILS")}
              className="inline-flex items-center text-sm font-medium text-muted-foreground hover:text-foreground transition-colors mb-6"
            >
              <ArrowLeft className="w-4 h-4 mr-2" />
              Back
            </button>
          )}

          <div className="text-center mb-8">
            <h1 className="text-3xl font-extrabold tracking-tight mb-2">Create an account</h1>
            <p className="text-sm text-muted-foreground">
              {step === "DETAILS" ? "Join the public data ecosystem today." : "Enter the 6-digit verification code sent to your email."}
            </p>
          </div>

          {error && (
            <div className="p-3 bg-red-50 text-red-600 text-sm font-medium rounded-xl border border-red-100 mb-4">
              {error}
            </div>
          )}
          
          {success && (
            <div className="p-3 bg-emerald-50 text-emerald-600 text-sm font-medium rounded-xl border border-emerald-100 mb-4">
              {success}
            </div>
          )}

          {step === "DETAILS" && (
            <form className="space-y-4" onSubmit={handleSignup}>
              <div>
                <label className="block text-sm font-semibold mb-2" htmlFor="name">Full Name</label>
                <input 
                  id="name" 
                  type="text" 
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                  className="w-full px-4 py-2.5 rounded-xl border border-muted bg-background outline-none focus:border-primary transition-colors text-sm" 
                />
              </div>
              
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
              <div>
                <label className="block text-sm font-semibold mb-2" htmlFor="password">Password</label>
                <input 
                  id="password" 
                  type="password" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  minLength={8}
                  className="w-full px-4 py-2.5 rounded-xl border border-muted bg-background outline-none focus:border-primary transition-colors text-sm" 
                  placeholder="••••••••" 
                />
              </div>

              <button 
                type="submit" 
                disabled={isLoading}
                className="w-full mt-6 py-3 rounded-xl bg-primary text-white font-semibold shadow hover:bg-primary/90 transition-colors disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    Sending OTP...
                  </>
                ) : (
                  'Create Account'
                )}
              </button>

              <p className="mt-6 text-center text-xs text-muted-foreground px-4">
                By clicking continue, you agree to our{' '}
                <Link href="/terms" className="underline hover:text-foreground">Terms of Service</Link> and{' '}
                <Link href="/privacy" className="underline hover:text-foreground">Privacy Policy</Link>.
              </p>

              <div className="mt-8 pt-6 border-t border-muted text-center">
                 <p className="text-sm text-muted-foreground">
                   Already have an account?{' '}
                   <Link href="/login" className="font-semibold text-foreground hover:text-primary">
                     Sign in
                   </Link>
                 </p>
              </div>
            </form>
          )}

          {step === "OTP" && (
            <form className="space-y-4" onSubmit={handleVerifyOtp}>
              <div>
                <label className="block text-sm font-semibold mb-2" htmlFor="otp">One-Time Password (OTP)</label>
                <input 
                  id="otp" 
                  type="text" 
                  value={otp}
                  onChange={(e) => setOtp(e.target.value)}
                  required
                  className="w-full px-4 py-2.5 rounded-xl border border-muted bg-background outline-none focus:border-primary transition-colors text-sm tracking-widest text-center text-lg" 
                  placeholder="------" 
                  maxLength={6}
                />
              </div>

              <button 
                type="submit" 
                disabled={isLoading}
                className="w-full mt-6 py-3 rounded-xl bg-primary text-white font-semibold shadow hover:bg-primary/90 transition-colors disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    Verifying...
                  </>
                ) : (
                  'Verify Registration'
                )}
              </button>

              <div className="flex justify-between items-center mt-3 px-1 text-sm">
                <button
                  type="button"
                  onClick={handleResendOtp}
                  disabled={resendTimer > 0 || isLoading}
                  className="font-medium text-primary hover:underline transition-colors disabled:opacity-50 disabled:no-underline disabled:cursor-not-allowed"
                >
                  {resendTimer > 0 ? `Resend OTP in ${resendTimer}s` : 'Resend OTP'}
                </button>
              </div>
            </form>
          )}

        </div>
      </div>
    </main>
  );
}
