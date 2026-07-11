
export default function AnalyticsPage() {
  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">

      <section className="bg-foreground text-background py-16">
        <div className="mx-auto max-w-7xl px-6">
          <h1 className="text-4xl font-extrabold tracking-tight mb-4">Global Statistics</h1>
          <p className="text-lg text-muted max-w-2xl">
            Real-time telemetry and platform adoption metrics across all ResultHub publishers and consumers.
          </p>
        </div>
      </section>

      <section className="py-16 mx-auto max-w-7xl px-6 w-full flex-1">
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
          {/* Stat Cards */}
          {[
            { label: "Total Queries (30d)", value: "54.2M", trend: "+12.5%" },
            { label: "Active Publishers", value: "4,512", trend: "+8.2%" },
            { label: "Data Records", value: "1.2B", trend: "+2.1%" },
            { label: "API Requests/sec", value: "3,400", trend: "+18.0%" },
          ].map((stat, i) => (
            <div key={i} className="p-6 rounded-2xl border border-muted bg-background shadow-sm">
              <p className="text-sm font-semibold text-muted-foreground mb-2 uppercase tracking-wider">{stat.label}</p>
              <div className="flex items-end gap-3">
                <span className="text-3xl font-extrabold">{stat.value}</span>
                <span className="text-sm font-bold text-success mb-1">{stat.trend}</span>
              </div>
            </div>
          ))}
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 p-8 rounded-2xl border border-muted bg-background shadow-sm h-96 flex flex-col">
             <h3 className="font-bold text-lg mb-6">Traffic by Region</h3>
             <div className="flex-1 rounded-xl bg-muted/20 border border-muted border-dashed flex items-center justify-center text-muted-foreground">
               [ Interactive Chart Component ]
             </div>
          </div>
          <div className="p-8 rounded-2xl border border-muted bg-background shadow-sm flex flex-col">
             <h3 className="font-bold text-lg mb-6">Top Domains</h3>
             <div className="space-y-6">
               {[
                 { domain: "Education", pct: 45, color: "bg-primary" },
                 { domain: "Government", pct: 25, color: "bg-secondary" },
                 { domain: "Sports", pct: 15, color: "bg-accent" },
                 { domain: "Finance", pct: 10, color: "bg-success" },
                 { domain: "Other", pct: 5, color: "bg-muted" },
               ].map((d, i) => (
                 <div key={i}>
                   <div className="flex justify-between text-sm mb-2 font-medium">
                     <span>{d.domain}</span>
                     <span>{d.pct}%</span>
                   </div>
                   <div className="h-2 w-full bg-muted/50 rounded-full overflow-hidden">
                     <div className={`h-full ${d.color}`} style={{ width: `${d.pct}%` }}></div>
                   </div>
                 </div>
               ))}
             </div>
          </div>
        </div>
      </section>

      </main>
  );
}
