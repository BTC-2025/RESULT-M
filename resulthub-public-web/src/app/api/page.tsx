
export default function ApiPage() {
  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">
      <section className="bg-foreground text-background py-16">
        <div className="mx-auto max-w-7xl px-6">
          <h1 className="text-4xl font-extrabold tracking-tight mb-4">ResultHub API</h1>
          <p className="text-lg text-muted max-w-2xl">
            Integrate directly with our Spring Boot + PostgreSQL backend. Access real-time datasets, polls, and analytics programmatically.
          </p>
        </div>
      </section>
      <div className="flex-1 mx-auto max-w-7xl px-6 py-16 w-full flex flex-col md:flex-row gap-12">
        <aside className="w-full md:w-64 flex-shrink-0 border-r border-muted pr-6">
           <ul className="space-y-4 text-sm font-medium">
             <li className="text-primary cursor-pointer">Authentication</li>
             <li className="text-muted-foreground hover:text-foreground cursor-pointer">Workspaces</li>
             <li className="text-muted-foreground hover:text-foreground cursor-pointer">Datasets & Records</li>
             <li className="text-muted-foreground hover:text-foreground cursor-pointer">Voting Hub</li>
             <li className="text-muted-foreground hover:text-foreground cursor-pointer">Complaints</li>
             <li className="text-muted-foreground hover:text-foreground cursor-pointer">Rate Limits</li>
           </ul>
        </aside>
        <div className="flex-1">
          <h2 className="text-2xl font-bold mb-6">Authentication</h2>
          <p className="text-muted-foreground mb-6">
            ResultHub uses JWT (JSON Web Tokens) for API authentication. You must include your token in the `Authorization` header of all protected requests.
          </p>
          <div className="bg-muted p-4 rounded-lg overflow-x-auto text-sm font-mono text-foreground mb-8">
            <span className="text-accent">Authorization:</span> Bearer {'<'}YOUR_JWT_TOKEN{'>'}
          </div>

          <h3 className="text-xl font-bold mb-4">Workspace Tokens</h3>
          <p className="text-muted-foreground mb-6">
            For PASSWORD_PROTECTED workspaces, an additional workspace token header is required after successful unlocking.
          </p>
          <div className="bg-muted p-4 rounded-lg overflow-x-auto text-sm font-mono text-foreground">
            <span className="text-accent">Workspace:</span> {'<'}YOUR_WORKSPACE_TOKEN{'>'}
          </div>
        </div>
      </div>
      </main>
  );
}
