import Link from "next/link";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex min-h-screen bg-muted/10 text-foreground">
      {/* Sidebar */}
      <aside className="w-64 bg-background border-r border-muted flex flex-col flex-shrink-0 sticky top-0 h-screen overflow-y-auto">
        <div className="p-6 border-b border-muted">
          <h2 className="text-xl font-bold tracking-tight text-accent">Super Admin</h2>
          <p className="text-xs text-muted-foreground mt-1">Platform Operations</p>
        </div>
        <nav className="flex-1 p-4 space-y-1">
          <Link href="/admin" className="flex items-center px-3 py-2.5 rounded-xl hover:bg-muted text-sm font-medium transition-colors">
            Global Overview
          </Link>
          <Link href="/admin/organizations" className="flex items-center px-3 py-2.5 rounded-xl hover:bg-muted text-sm font-medium transition-colors">
            Organizations
          </Link>
          <Link href="/admin/users" className="flex items-center px-3 py-2.5 rounded-xl hover:bg-muted text-sm font-medium transition-colors">
            Users & Roles
          </Link>
          <Link href="/admin/audit" className="flex items-center px-3 py-2.5 rounded-xl hover:bg-muted text-sm font-medium transition-colors">
            Audit Logs
          </Link>
          <Link href="/admin/health" className="flex items-center px-3 py-2.5 rounded-xl hover:bg-muted text-sm font-medium transition-colors">
            System Health
          </Link>
        </nav>
        <div className="p-4 border-t border-muted">
          <Link href="/" className="flex items-center justify-center w-full py-2 rounded-lg bg-foreground text-background text-sm font-semibold hover:bg-foreground/90 transition-colors">
            Return to Public Site
          </Link>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col">
        <header className="h-16 bg-background border-b border-muted flex items-center justify-between px-8 sticky top-0 z-10">
          <div className="flex items-center gap-4">
             <span className="font-semibold text-accent">ResultHub Central Command</span>
          </div>
          <button className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors">
            Admin Log out
          </button>
        </header>
        <div className="p-8 flex-1">
          {children}
        </div>
      </main>
    </div>
  );
}
