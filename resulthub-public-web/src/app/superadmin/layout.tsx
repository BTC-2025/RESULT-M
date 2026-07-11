"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import {
  LayoutDashboard, Users, Building2, AlertTriangle,
  FileText, Activity, Shield, LogOut, ChevronRight
} from "lucide-react";

const NAV = [
  { href: "/superadmin",               label: "Dashboard",       icon: LayoutDashboard },
  { href: "/superadmin/users",          label: "Users",           icon: Users },
  { href: "/superadmin/organizations",  label: "Organizations",   icon: Building2 },
  { href: "/superadmin/complaints",     label: "Complaints",      icon: AlertTriangle },
  { href: "/superadmin/posts",          label: "Posts",           icon: FileText },
  { href: "/superadmin/system",         label: "System Health",   icon: Activity },
];

export default function SuperAdminLayout({ children }: { children: React.ReactNode }) {
  const pathname  = usePathname();
  const router    = useRouter();
  const [ready, setReady] = useState(false);
  const [adminName, setAdminName] = useState("Admin");

  useEffect(() => {
    const token = localStorage.getItem("rh_token");
    if (!token) { router.replace("/superadmin/login"); return; }

    // Decode JWT to check role
    try {
      const payload = JSON.parse(atob(token.split(".")[1]));
      const roles: string[] = payload.roles || payload.authorities || [];
      const isAdmin = roles.some((r: string) => r.includes("ADMIN"));
      if (!isAdmin) { router.replace("/"); return; }
      setAdminName(payload.sub || "Admin");
    } catch {
      router.replace("/login");
      return;
    }
    setReady(true);
  }, [router]);

  const handleLogout = () => {
    localStorage.removeItem("rh_token");
    router.replace("/login");
  };

  if (!ready) {
    return (
      <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-red-500 to-rose-600 flex items-center justify-center">
            <Shield className="w-6 h-6 text-white" />
          </div>
          <div className="w-6 h-6 border-2 border-red-500 border-t-transparent rounded-full animate-spin" />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0a0a0f] text-white flex">

      {/* ── Sidebar ──────────────────────────────────────────────── */}
      <aside className="w-[240px] shrink-0 h-screen sticky top-0 flex flex-col border-r border-white/5 bg-[#0d0d15]">

        {/* Brand */}
        <div className="flex items-center gap-3 px-5 py-5 border-b border-white/5">
          <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-red-500 to-rose-600 flex items-center justify-center shadow-lg shadow-red-900/30">
            <Shield className="w-5 h-5 text-white" />
          </div>
          <div>
            <p className="text-[13px] font-black text-white tracking-tight">ResultHub</p>
            <p className="text-[10px] font-bold text-red-400 uppercase tracking-widest">Super Admin</p>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 py-4 px-3 space-y-0.5 overflow-y-auto">
          {NAV.map(({ href, label, icon: Icon }) => {
            const isActive = href === "/superadmin"
              ? pathname === "/superadmin"
              : pathname.startsWith(href);
            return (
              <Link
                key={href}
                href={href}
                className={`group flex items-center gap-3 px-3 py-2.5 rounded-xl text-[13px] font-semibold transition-all duration-150 ${
                  isActive
                    ? "bg-red-500/15 text-red-400 border border-red-500/20"
                    : "text-white/50 hover:text-white hover:bg-white/5"
                }`}
              >
                <Icon className={`w-4 h-4 shrink-0 ${isActive ? "text-red-400" : "text-white/30 group-hover:text-white/70"}`} />
                <span className="flex-1">{label}</span>
                {isActive && <ChevronRight className="w-3 h-3 text-red-400/60" />}
              </Link>
            );
          })}
        </nav>

        {/* User / Logout */}
        <div className="border-t border-white/5 p-3">
          <div className="flex items-center gap-3 px-3 py-2.5 rounded-xl mb-1">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-red-500 to-rose-600 flex items-center justify-center text-xs font-black text-white shrink-0">
              {adminName[0]?.toUpperCase()}
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[12px] font-bold text-white truncate">{adminName}</p>
              <p className="text-[10px] text-red-400 font-bold uppercase tracking-wider">Super Admin</p>
            </div>
          </div>
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-3 py-2 rounded-xl text-[13px] font-semibold text-white/40 hover:text-red-400 hover:bg-red-500/10 transition-all"
          >
            <LogOut className="w-4 h-4" />
            Sign Out
          </button>
        </div>
      </aside>

      {/* ── Main Content ─────────────────────────────────────────── */}
      <main className="flex-1 min-w-0 overflow-x-hidden">
        {children}
      </main>
    </div>
  );
}
