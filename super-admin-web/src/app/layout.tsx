"use client";

import React from 'react';
import { AuthProvider, useAuth } from '@/context/AuthContext';
import Sidebar from '@/components/Sidebar';
import { usePathname } from 'next/navigation';
import '@/app/globals.css';

function AppContent({ children }: { children: React.ReactNode }) {
  const { token, loading } = useAuth();
  const pathname = usePathname();
  const isLoginPage = pathname === '/login';

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-darkBg">
        <div className="relative flex items-center justify-center">
          <div className="w-16 h-16 border-4 border-accentPurple border-t-transparent rounded-full animate-spin"></div>
          <div className="absolute w-8 h-8 bg-accentIndigo rounded-full opacity-60 animate-ping"></div>
        </div>
      </div>
    );
  }

  if (isLoginPage) {
    return <main className="bg-darkBg min-h-screen">{children}</main>;
  }

  return (
    <div className="flex min-h-screen bg-darkBg text-textPrimary">
      <Sidebar />
      <div className="flex-1 min-h-screen bg-darkBg">
        {children}
      </div>
    </div>
  );
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <title>ResultHub - Super Admin Control Portal</title>
        <meta name="description" content="Super Admin platform dashboard for ResultHub" />
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
      </head>
      <body className="antialiased">
        <AuthProvider>
          <AppContent>{children}</AppContent>
        </AuthProvider>
      </body>
    </html>
  );
}
