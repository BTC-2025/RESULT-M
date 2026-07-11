"use client";

import Link from "next/link";
import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { api } from "@/lib/api";
import { Loader2, ArrowLeft } from "lucide-react";

type Step = "EMAIL" | "OTP" | "NEW_PASSWORD";

export default function ForgotPasswordPage() {
  const router = useRouter();
  const [step, setStep] = useState<Step>("EMAIL");
  
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  
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

  const handleSendEmail = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    setIsLoading(true);

    try {
      await api.auth.forgotPassword({ email });
      setStep("OTP");
      setSuccess("An OTP has been sent to your email address.");
      setResendTimer(120);
    } catch (err: any) {
      setError(err.message || "Failed to send OTP. Please check the email address.");
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
      await api.auth.forgotPassword({ email });
      setSuccess("A new OTP has been sent to your email address.");
      setResendTimer(120);
    } catch (err: any) {
      setError(err.message || "Failed to resend OTP.");
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
      setStep("NEW_PASSWORD");
      setSuccess("OTP verified! Please enter your new password.");
    } catch (err: any) {
      setError(err.message || "Invalid OTP. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    
    if (newPassword !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }
    
    if (newPassword.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }

    setIsLoading(true);

    try {
      await api.auth.resetPassword({ email, otp, newPassword });
      setSuccess("Password reset successfully! Redirecting to login...");
      setTimeout(() => {
        router.push("/login");
      }, 2000);
    } catch (err: any) {
      setError(err.message || "Failed to reset password. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">
      <div className="flex-1 flex items-center justify-center py-12 px-6 bg-muted/20">
        <div className="w-full max-w-md bg-background rounded-3xl p-8 border border-muted shadow-sm">
          
          <Link href="/login" className="inline-flex items-center text-sm font-medium text-muted-foreground hover:text-foreground transition-colors mb-6">
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to login
          </Link>

          <div className="text-center mb-8">
            <h1 className="text-3xl font-extrabold tracking-tight mb-2">Reset password</h1>
            <p className="text-sm text-muted-foreground">
              {step === "EMAIL" && "Enter your email address and we'll send you an OTP to reset your password."}
              {step === "OTP" && "Enter the 6-digit OTP sent to your email."}
              {step === "NEW_PASSWORD" && "Enter your new password."}
            </p>
          </div>

          {error && (
            <div className="p-3 bg-red-50 text-red-600 text-sm font-medium rounded-xl border border-red-100 mb-4">
              {error}
            </div>
          )}
          
          {success && (
            <div className="p-3 bg-green-50 text-green-600 text-sm font-medium rounded-xl border border-green-100 mb-4">
              {success}
            </div>
          )}

          {step === "EMAIL" && (
            <form className="space-y-4" onSubmit={handleSendEmail}>
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

              <button 
                type="submit" 
                disabled={isLoading}
                className="w-full mt-6 py-3 rounded-xl bg-foreground text-background font-semibold shadow hover:bg-foreground/90 transition-colors disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    Sending OTP...
                  </>
                ) : (
                  'Send OTP'
                )}
              </button>
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
                className="w-full mt-6 py-3 rounded-xl bg-foreground text-background font-semibold shadow hover:bg-foreground/90 transition-colors disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    Verifying...
                  </>
                ) : (
                  'Verify OTP'
                )}
              </button>
              <div className="flex justify-between items-center mt-3 px-1 text-sm">
                <button
                  type="button"
                  onClick={() => setStep("EMAIL")}
                  className="text-muted-foreground hover:text-foreground transition-colors"
                >
                  Change email
                </button>
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

          {step === "NEW_PASSWORD" && (
            <form className="space-y-4" onSubmit={handleResetPassword}>
              <div>
                <label className="block text-sm font-semibold mb-2" htmlFor="newPassword">New Password</label>
                <input 
                  id="newPassword" 
                  type="password"
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  required
                  minLength={8}
                  className="w-full px-4 py-2.5 rounded-xl border border-muted bg-background outline-none focus:border-primary transition-colors text-sm" 
                  placeholder="••••••••" 
                />
              </div>
              
              <div>
                <label className="block text-sm font-semibold mb-2" htmlFor="confirmPassword">Confirm Password</label>
                <input 
                  id="confirmPassword" 
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  required
                  minLength={8}
                  className="w-full px-4 py-2.5 rounded-xl border border-muted bg-background outline-none focus:border-primary transition-colors text-sm" 
                  placeholder="••••••••" 
                />
              </div>

              <button 
                type="submit" 
                disabled={isLoading}
                className="w-full mt-6 py-3 rounded-xl bg-foreground text-background font-semibold shadow hover:bg-foreground/90 transition-colors disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="w-5 h-5 animate-spin" />
                    Resetting...
                  </>
                ) : (
                  'Reset Password'
                )}
              </button>
            </form>
          )}
        </div>
      </div>
    </main>
  );
}
