import { notFound } from "next/navigation";
import Link from "next/link";

const categoryData: Record<string, { name: string; color: string; desc: string }> = {
  "education": { name: "Education", color: "primary", desc: "University results, entrance exams, and academic metrics." },
  "government": { name: "Government", color: "secondary", desc: "Civil services, recruitment lists, and state statistics." },
  "sports": { name: "Sports", color: "accent", desc: "Live scorecards, standings, and player analytics." },
  "politics": { name: "Politics", color: "danger", desc: "Election results and public opinion polls." },
  "finance": { name: "Finance", color: "success", desc: "Market indices and economic indicators." },
  "technology": { name: "Technology", color: "primary", desc: "Benchmarks and tech employment data." },
  "entertainment": { name: "Entertainment", color: "accent", desc: "Box office figures and award results." },
  "law": { name: "Law", color: "secondary", desc: "Bar exam results and legal case outcomes." },
  "business": { name: "Business", color: "primary", desc: "Startup funding and market research." },
  "healthcare": { name: "Healthcare", color: "danger", desc: "Medical licensure and public health data." },
  "hyper-local": { name: "Hyper Local", color: "warning", desc: "Community votes and city metrics." }
};

export default async function CategoryPage(props: { params: Promise<{ slug: string }> }) {
  const params = await props.params;
  const data = categoryData[params.slug];
  
  if (!data) {
    notFound();
  }

  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">

      {/* Hero Banner */}
      <section className="relative py-24 border-b border-muted overflow-hidden">
        <div className={`absolute inset-0 bg-gradient-to-br from-${data.color}/10 to-background z-0`}></div>
        <div className="mx-auto max-w-7xl px-6 relative z-10">
          <div className="mb-4 inline-flex px-3 py-1 rounded-full border border-muted bg-background/50 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
            Category
          </div>
          <h1 className="text-5xl font-extrabold tracking-tight mb-6">{data.name}</h1>
          <p className="text-xl text-muted-foreground max-w-2xl">{data.desc}</p>
          <div className="mt-8 flex gap-4">
             <button className={`rounded-xl bg-${data.color || 'primary'} px-6 py-3 text-sm font-semibold text-white shadow-sm hover:opacity-90 transition-opacity`}>
               Publish {data.name} Data
             </button>
          </div>
        </div>
      </section>

      <div className="mx-auto max-w-7xl px-6 py-16 grid lg:grid-cols-3 gap-12">
        <div className="lg:col-span-2 space-y-16">
          
          {/* Latest Datasets */}
          <section>
            <div className="flex items-center justify-between mb-8">
              <h2 className="text-2xl font-bold">Latest Datasets</h2>
              <button className="text-sm font-medium text-primary hover:underline">View All</button>
            </div>
            <div className="space-y-4">
              {[1, 2, 3, 4].map(i => (
                <div key={i} className="p-5 rounded-2xl border border-muted bg-background hover:shadow-sm transition-shadow cursor-pointer">
                  <div className="flex justify-between items-start mb-2">
                    <h3 className="font-semibold text-lg">{data.name} Example Dataset #{i}</h3>
                    <span className="text-xs bg-muted text-muted-foreground px-2 py-1 rounded-md">JSONB</span>
                  </div>
                  <p className="text-sm text-muted-foreground mb-4">A comprehensive collection of 2026 standardized data points relevant to the {data.name.toLowerCase()} sector.</p>
                  <div className="flex items-center gap-4 text-xs font-medium text-muted-foreground">
                    <span className="flex items-center gap-1">👁️ 12.5k views</span>
                    <span className="flex items-center gap-1">📅 Updated 2h ago</span>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* Discussions */}
          <section>
             <h2 className="text-2xl font-bold mb-8">Community Discussions</h2>
             <div className="grid sm:grid-cols-2 gap-6">
               {[1, 2].map(i => (
                 <div key={i} className="p-6 rounded-2xl bg-muted/20 border border-muted">
                   <div className="flex gap-2 text-xs text-muted-foreground mb-3">
                     <span className="text-success font-medium">↑ 89</span>
                     <span>↓ 4</span>
                     <span className="ml-auto">12 Comments</span>
                   </div>
                   <h3 className="font-semibold mb-2">How should we interpret the latest {data.name.toLowerCase()} figures?</h3>
                   <p className="text-sm text-muted-foreground mb-4 line-clamp-3">There has been a lot of debate recently about the validity of these metrics. I pulled the raw JSONB from ResultHub and found some interesting anomalies...</p>
                   <Link href="/community" className="text-sm font-medium text-primary">Read Discussion</Link>
                 </div>
               ))}
             </div>
          </section>

        </div>

        <div className="space-y-12">
          
          {/* Featured Organizations */}
          <section>
            <h2 className="text-xl font-bold mb-6">Featured Organizations</h2>
            <div className="space-y-4">
              {[1, 2, 3].map(i => (
                <div key={i} className="flex items-center gap-4 p-4 rounded-xl border border-muted hover:bg-muted/30 transition-colors cursor-pointer">
                   <div className={`h-12 w-12 rounded-lg bg-${data.color || 'primary'}/10 flex items-center justify-center font-bold text-${data.color || 'primary'}`}>
                     ORG
                   </div>
                   <div>
                     <h4 className="font-semibold">{data.name} Dept {i}</h4>
                     <p className="text-xs text-muted-foreground">8 Datasets • Official</p>
                   </div>
                </div>
              ))}
            </div>
          </section>

          {/* Live Updates */}
          <section className="p-6 rounded-2xl bg-background border border-muted shadow-sm relative overflow-hidden">
             <div className="absolute top-0 left-0 w-1 h-full bg-warning"></div>
             <div className="flex items-center gap-2 mb-6">
                <div className="h-2 w-2 rounded-full bg-warning animate-pulse"></div>
                <h2 className="text-xl font-bold">Live Updates</h2>
             </div>
             <div className="space-y-6 relative before:absolute before:inset-0 before:ml-2 before:-translate-x-px md:before:mx-auto md:before:translate-x-0 before:h-full before:w-0.5 before:bg-gradient-to-b before:from-transparent before:via-muted before:to-transparent">
               {[1, 2].map(i => (
                 <div key={i} className="relative flex items-center justify-between md:justify-normal md:odd:flex-row-reverse group is-active">
                   <div className="flex items-center justify-center w-5 h-5 rounded-full border-2 border-background bg-warning shadow shrink-0 md:order-1 md:group-odd:-translate-x-1/2 md:group-even:translate-x-1/2 z-10"></div>
                   <div className="w-[calc(100%-2.5rem)] md:w-[calc(50%-1.25rem)] p-3 rounded-lg border border-muted bg-background">
                     <time className="text-xs font-medium text-muted-foreground block mb-1">10 mins ago</time>
                     <p className="text-sm">New result published by Dept {i}.</p>
                   </div>
                 </div>
               ))}
             </div>
          </section>

        </div>
      </div>

      </main>
  );
}
