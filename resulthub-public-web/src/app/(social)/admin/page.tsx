export default function SuperAdminOverviewPage() {
  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">System Overview</h1>
          <p className="text-muted-foreground mt-1">Platform-wide statistics and node health monitoring.</p>
        </div>
      </div>

      {/* Global KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {[
          { label: "Total Organizations", value: "1,245", trend: "+12 this week" },
          { label: "Active Users", value: "85,000", trend: "+1,200 this week" },
          { label: "Total Records", value: "45.2M", trend: "+2M this month" },
          { label: "Global Searches Today", value: "1.2M", trend: "High load" },
        ].map((kpi, i) => (
          <div key={i} className="p-6 rounded-2xl bg-background border border-muted shadow-sm">
            <h3 className="text-sm font-semibold text-muted-foreground mb-2 uppercase tracking-wider">{kpi.label}</h3>
            <div className="text-3xl font-extrabold mb-1">{kpi.value}</div>
            <div className="text-sm text-success font-medium">{kpi.trend}</div>
          </div>
        ))}
      </div>

      <div className="grid lg:grid-cols-2 gap-8">
        {/* Organizations Awaiting Approval */}
        <div className="p-6 rounded-2xl bg-background border border-muted shadow-sm">
          <h2 className="text-xl font-bold mb-6">Pending Organization Approvals</h2>
          <div className="space-y-4">
            {[
              { name: "Apex Sports League", type: "Sports" },
              { name: "Kerala Public Services", type: "Government" },
              { name: "Oxford Int. School", type: "Education" },
            ].map((org, i) => (
              <div key={i} className="flex items-center justify-between p-4 rounded-xl border border-muted bg-muted/10">
                <div>
                  <h3 className="font-bold">{org.name}</h3>
                  <p className="text-xs text-muted-foreground">{org.type}</p>
                </div>
                <div className="flex gap-2">
                  <button className="px-3 py-1 bg-success text-white text-xs font-bold rounded">Approve</button>
                  <button className="px-3 py-1 bg-danger text-white text-xs font-bold rounded">Reject</button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* System Health */}
        <div className="p-6 rounded-2xl bg-background border border-muted shadow-sm">
          <h2 className="text-xl font-bold mb-6">Database Health</h2>
          <div className="space-y-6">
            <div>
              <div className="flex justify-between text-sm mb-2 font-medium">
                <span>PostgreSQL DB Connections</span>
                <span className="text-warning">82%</span>
              </div>
              <div className="h-2 w-full bg-muted rounded-full overflow-hidden">
                <div className="h-full bg-warning w-[82%]"></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between text-sm mb-2 font-medium">
                <span>Redis Cache Memory</span>
                <span className="text-success">45%</span>
              </div>
              <div className="h-2 w-full bg-muted rounded-full overflow-hidden">
                <div className="h-full bg-success w-[45%]"></div>
              </div>
            </div>
            <div>
              <div className="flex justify-between text-sm mb-2 font-medium">
                <span>API Gateway Latency</span>
                <span className="text-success">24ms</span>
              </div>
              <div className="h-2 w-full bg-muted rounded-full overflow-hidden">
                <div className="h-full bg-success w-[10%]"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
