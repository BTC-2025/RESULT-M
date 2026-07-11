"use client";

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/context/AuthContext';
import { 
  LayoutDashboard, 
  BarChart3, 
  Users2, 
  Activity, 
  LogOut, 
  ShieldAlert 
} from 'lucide-react';

export default function Sidebar() {
  const pathname = usePathname();
  const { logout, user } = useAuth();

  const menuItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Analytics', path: '/analytics', icon: BarChart3 },
    { name: 'User & Org Management', path: '/users', icon: Users2 },
    { name: 'System Health', path: '/health', icon: Activity },
  ];

  return (
    <aside className="w-64 glass-panel h-screen fixed left-0 top-0 flex flex-col justify-between border-r border-borderDark z-30">
      <div>
        {/* Logo Section */}
        <div className="p-6 flex items-center gap-3 border-b border-borderDark">
          <div className="bg-gradient-to-tr from-accentIndigo via-accentPurple to-accentRose p-2 rounded-xl text-textPrimary shadow-glow">
            <ShieldAlert className="w-6 h-6" />
          </div>
          <div>
            <h1 className="font-extrabold text-lg bg-gradient-to-r from-textPrimary via-white to-accentPurple bg-clip-text text-transparent tracking-wide">
              ResultHub
            </h1>
            <span className="text-[10px] font-bold text-accentPurple tracking-widest uppercase">
              Super Admin
            </span>
          </div>
        </div>

        {/* Navigation Section */}
        <nav className="mt-8 px-4 space-y-2">
          {menuItems.map((item) => {
            const isActive = pathname === item.path;
            const Icon = item.icon;
            
            return (
              <Link
                key={item.path}
                href={item.path}
                className={`flex items-center gap-4 px-4 py-3 rounded-xl font-medium text-sm transition-all duration-200 group ${
                  isActive
                    ? 'bg-accentPurple/25 text-white shadow-glow border-l-4 border-accentPurple'
                    : 'text-textSecondary hover:bg-white/5 hover:text-white'
                }`}
              >
                <Icon className={`w-5 h-5 transition-transform group-hover:scale-110 ${
                  isActive ? 'text-accentPurple' : 'text-textSecondary group-hover:text-white'
                }`} />
                <span>{item.name}</span>
              </Link>
            );
          })}
        </nav>
      </div>

      {/* Footer / User Profile Section */}
      <div className="p-4 border-t border-borderDark bg-black/20">
        <div className="flex items-center gap-3 mb-4 px-2">
          <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-accentIndigo to-accentPurple flex items-center justify-center font-extrabold text-sm border border-accentPurple/50 shadow-glow">
            {user?.name?.slice(0, 2).toUpperCase() || 'AD'}
          </div>
          <div className="flex-1 overflow-hidden">
            <h4 className="text-sm font-semibold text-textPrimary truncate">{user?.name || 'Administrator'}</h4>
            <p className="text-[10px] text-textSecondary truncate">{user?.email || 'admin@resulthub.com'}</p>
          </div>
        </div>

        <button
          onClick={logout}
          className="w-full flex items-center justify-center gap-3 py-2.5 px-4 rounded-xl border border-accentRose/30 text-accentRose hover:bg-accentRose/10 transition-all duration-200 font-bold text-xs tracking-wider uppercase"
        >
          <LogOut className="w-4 h-4" />
          <span>Exit Portal</span>
        </button>
      </div>
    </aside>
  );
}
