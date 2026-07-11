import Link from "next/link";

const categories = [
  { name: "Education", slug: "education", icon: "📚", color: "primary", desc: "University results, entrance exams, and academic performance metrics." },
  { name: "Government", slug: "government", icon: "🏛️", color: "secondary", desc: "Civil services, recruitment lists, and official state statistics." },
  { name: "Sports", slug: "sports", icon: "⚽", color: "accent", desc: "Live scorecards, tournament standings, and player analytics." },
  { name: "Politics", slug: "politics", icon: "🗳️", color: "danger", desc: "Election results, voting trends, and public opinion polls." },
  { name: "Finance", slug: "finance", icon: "📈", color: "success", desc: "Market indices, corporate earnings, and economic indicators." },
  { name: "Technology", slug: "technology", icon: "💻", color: "primary", desc: "Benchmarks, tech employment data, and industry reports." },
  { name: "Entertainment", slug: "entertainment", icon: "🎬", color: "accent", desc: "Box office figures, streaming metrics, and award results." },
  { name: "Law", slug: "law", icon: "⚖️", color: "secondary", desc: "Bar exam results, judicial statistics, and legal case outcomes." },
  { name: "Business", slug: "business", icon: "🏢", color: "primary", desc: "Startup funding, corporate diversity, and market research." },
  { name: "Healthcare", slug: "healthcare", icon: "🏥", color: "danger", desc: "Medical licensure, hospital rankings, and public health data." },
  { name: "Hyper Local", slug: "hyper-local", icon: "📍", color: "warning", desc: "Community votes, local school boards, and city metrics." }
];

export default function CategoriesHub() {
  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">

      <section className="py-20 bg-muted/20 border-b border-muted">
        <div className="mx-auto max-w-7xl px-6 text-center">
          <h1 className="text-4xl font-extrabold tracking-tight sm:text-5xl mb-6">Data Categories</h1>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            Browse through 11 comprehensive domains. ResultHub normalizes structured data across all industries so you can query anything seamlessly.
          </p>
        </div>
      </section>

      <section className="py-20 mx-auto max-w-7xl px-6">
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {categories.map((c) => (
            <Link href={`/categories/${c.slug}`} key={c.slug} className="group flex flex-col rounded-3xl border border-muted bg-background p-8 shadow-sm transition-all hover:shadow-lg hover:border-primary/40 relative overflow-hidden">
              <div className={`absolute -right-10 -top-10 h-32 w-32 rounded-full bg-${c.color}/10 blur-2xl group-hover:bg-${c.color}/20 transition-all`}></div>
              <div className={`h-16 w-16 rounded-2xl flex items-center justify-center text-3xl mb-6 bg-${c.color}/10 text-${c.color} border border-${c.color}/20`}>
                {c.icon}
              </div>
              <h2 className="text-2xl font-bold mb-3 group-hover:text-primary transition-colors">{c.name}</h2>
              <p className="text-muted-foreground leading-relaxed mb-8 flex-grow">
                {c.desc}
              </p>
              <div className="flex items-center text-sm font-semibold text-foreground group-hover:text-primary transition-colors">
                Explore Domain <span className="ml-2 transition-transform group-hover:translate-x-1">→</span>
              </div>
            </Link>
          ))}
        </div>
      </section>

      </main>
  );
}
