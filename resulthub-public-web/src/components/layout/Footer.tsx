import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="border-t border-muted bg-background py-16">
      <div className="mx-auto max-w-7xl px-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-12">
          <div className="flex flex-col gap-4">
            <Link href="/" className="flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-white font-bold">
                R
              </div>
              <span className="text-xl font-bold tracking-tight">ResultHub</span>
            </Link>
            <p className="text-sm text-muted-foreground leading-relaxed">
              The modern public data ecosystem. Bringing clarity, transparency, and community to results, scores, and analytics worldwide.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-4">Platform</h3>
            <ul className="space-y-3 text-sm text-muted-foreground">
              <li><Link href="/results" className="hover:text-primary transition-colors">Explore Results</Link></li>
              <li><Link href="/search" className="hover:text-primary transition-colors">Search Data</Link></li>
              <li><Link href="/organization" className="hover:text-primary transition-colors">Featured Organizations</Link></li>
              <li><Link href="/analytics" className="hover:text-primary transition-colors">Global Statistics</Link></li>
            </ul>
          </div>
          <div>
            <h3 className="font-semibold mb-4">Community</h3>
            <ul className="space-y-3 text-sm text-muted-foreground">
              <li><Link href="/community" className="hover:text-primary transition-colors">Discussions</Link></li>
              <li><Link href="/guidelines" className="hover:text-primary transition-colors">Guidelines</Link></li>
              <li><Link href="/support" className="hover:text-primary transition-colors">Support Center</Link></li>
              <li><Link href="/api" className="hover:text-primary transition-colors">API Documentation</Link></li>
            </ul>
          </div>
          <div>
            <h3 className="font-semibold mb-4">Categories</h3>
            <ul className="space-y-3 text-sm text-muted-foreground">
              <li><Link href="/categories/education" className="hover:text-primary transition-colors">Education & Academics</Link></li>
              <li><Link href="/categories/government" className="hover:text-primary transition-colors">Government Exams</Link></li>
              <li><Link href="/categories/sports" className="hover:text-primary transition-colors">Sports Analytics</Link></li>
              <li><Link href="/categories" className="hover:text-primary transition-colors text-primary font-medium">View all 11 categories &rarr;</Link></li>
            </ul>
          </div>
        </div>
        <div className="mt-16 pt-8 border-t border-muted flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-muted-foreground">
          <p>&copy; {new Date().getFullYear()} ResultHub. All rights reserved.</p>
          <div className="flex gap-6">
            <Link href="/privacy" className="hover:text-foreground">Privacy Policy</Link>
            <Link href="/terms" className="hover:text-foreground">Terms of Service</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
