"use client";

import React, { useState, useEffect } from 'react';
import { useAuth } from '@/context/AuthContext';
import { Clock, ShieldAlert, Cpu } from 'lucide-react';

export default function Header({ title }: { title: string }) {
  const { user } = useAuth();
  const [time, setTime] = useState('');

  useEffect(() => {
    setTime(new Date().toLocaleTimeString());
    const interval = setInterval(() => {
      setTime(new Date().toLocaleTimeString());
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  return (
    <header className="glass-panel w-[calc(100%-16rem)] ml-64 fixed top-0 right-0 h-20 px-8 flex items-center justify-between border-b border-borderDark z-20">
      <div>
        <h2 className="text-xl font-extrabold text-white tracking-wide">{title}</h2>
      </div>

      <div className="flex items-center gap-6">
        {/* Live Status indicator */}
        <div className="flex items-center gap-2 bg-green/10 border border-green/30 px-3.5 py-1.5 rounded-full text-xs font-semibold text-green shadow-glow">
          <span className="w-2.5 h-2.5 rounded-full bg-green animate-ping inline-block mr-1"></span>
          System Live
        </div>

        {/* Real-time Clock */}
        <div className="flex items-center gap-2 text-textSecondary font-semibold text-sm bg-white/5 border border-borderDark px-4 py-1.5 rounded-xl">
          <Clock className="w-4 h-4 text-accentPurple" />
          <span>{time || 'Loading...'}</span>
        </div>

        {/* User context info */}
        <div className="flex items-center gap-3 bg-white/5 border border-borderDark px-4 py-1.5 rounded-xl text-xs font-bold">
          <ShieldAlert className="w-4 h-4 text-accentPurple" />
          <span className="text-textSecondary uppercase tracking-wider">Session As: </span>
          <span className="text-accentPurple uppercase tracking-wider">{user?.role || 'Guest'}</span>
        </div>
      </div>
    </header>
  );
}
