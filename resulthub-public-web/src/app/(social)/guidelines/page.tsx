
export default function GuidelinesPage() {
  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">
      <div className="flex-1 mx-auto max-w-3xl px-6 py-16 w-full">
        <h1 className="text-4xl font-extrabold tracking-tight mb-8">Community Guidelines</h1>
        <div className="prose prose-sm sm:prose-base dark:prose-invert text-muted-foreground space-y-6">
          <h2 className="text-xl font-bold text-foreground">Be Respectful</h2>
          <p>Treat all members of the ResultHub community with respect. Harassment, hate speech, and discriminatory language will not be tolerated and will result in immediate account suspension.</p>
          <h2 className="text-xl font-bold text-foreground">Verify Data Sources</h2>
          <p>When participating in discussions or referencing datasets, please ensure you are linking to verified organizational publishers. Misinformation can cause significant harm in academic and government domains.</p>
          <h2 className="text-xl font-bold text-foreground">No Spam or Self-Promotion</h2>
          <p>Do not use the complaint box or voting hub for commercial self-promotion. Automated bot activity is strictly monitored via IP and device fingerprinting.</p>
          <h2 className="text-xl font-bold text-foreground">Reporting Violations</h2>
          <p>If you see content that violates these guidelines, use the "Report" flag mechanism. Our moderation team reviews flagged content within 24 hours.</p>
        </div>
      </div>
      </main>
  );
}
