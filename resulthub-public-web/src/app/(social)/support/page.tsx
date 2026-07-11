
export default function SupportPage() {
  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">
      <div className="flex-1 mx-auto max-w-4xl px-6 py-16 w-full">
        <div className="text-center mb-12">
          <h1 className="text-4xl font-extrabold tracking-tight mb-4">Support Center</h1>
          <p className="text-lg text-muted-foreground">How can we help you today?</p>
        </div>

        <div className="relative max-w-2xl mx-auto mb-16">
          <input type="text" placeholder="Search for help articles..." className="w-full px-6 py-4 rounded-2xl border border-muted bg-background shadow-sm text-lg outline-none focus:border-primary" />
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          <div className="p-6 rounded-2xl border border-muted bg-background hover:border-primary/50 transition-colors cursor-pointer">
            <h3 className="font-bold text-lg mb-2">Publisher Guide</h3>
            <p className="text-sm text-muted-foreground">Learn how to format JSONB datasets, use the CSV importer, and manage workspace visibility.</p>
          </div>
          <div className="p-6 rounded-2xl border border-muted bg-background hover:border-primary/50 transition-colors cursor-pointer">
            <h3 className="font-bold text-lg mb-2">Account Management</h3>
            <p className="text-sm text-muted-foreground">Troubleshoot login issues, reset passwords, and manage your notification preferences.</p>
          </div>
          <div className="p-6 rounded-2xl border border-muted bg-background hover:border-primary/50 transition-colors cursor-pointer">
            <h3 className="font-bold text-lg mb-2">API Integration</h3>
            <p className="text-sm text-muted-foreground">Documentation on connecting to the Spring Boot backend securely with OAuth2.</p>
          </div>
          <div className="p-6 rounded-2xl border border-muted bg-background hover:border-primary/50 transition-colors cursor-pointer">
            <h3 className="font-bold text-lg mb-2">Report an Issue</h3>
            <p className="text-sm text-muted-foreground">Found a bug or incorrect dataset? Let our moderation and engineering team know.</p>
          </div>
        </div>
      </div>
      </main>
  );
}
