
export default function CommunityPage() {
  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">

      <section className="bg-muted/20 border-b border-muted py-12">
        <div className="mx-auto max-w-5xl px-6">
          <div className="flex items-center gap-3 mb-4">
            <span className="flex h-3 w-3 rounded-full bg-accent animate-pulse"></span>
            <span className="text-sm font-semibold uppercase tracking-wider text-accent">Community Hub</span>
          </div>
          <h1 className="text-4xl font-extrabold tracking-tight mb-4">Discussions & Complaints</h1>
          <p className="text-lg text-muted-foreground max-w-2xl">
            A public forum to discuss datasets, report hyper-local issues, and participate in verified voting polls.
          </p>
        </div>
      </section>

      <section className="flex-1 mx-auto max-w-5xl px-6 py-12 flex flex-col md:flex-row gap-8 w-full">
        <div className="flex-1 space-y-6">
          {/* Feed Tabs */}
          <div className="flex items-center gap-6 border-b border-muted pb-2">
            <button className="text-sm font-bold text-foreground border-b-2 border-primary pb-2 -mb-[10px]">Trending</button>
            <button className="text-sm font-medium text-muted-foreground hover:text-foreground pb-2 -mb-[10px]">Top</button>
            <button className="text-sm font-medium text-muted-foreground hover:text-foreground pb-2 -mb-[10px]">New</button>
          </div>

          {/* Discussion Cards */}
          {[1, 2, 3, 4].map(i => (
            <div key={i} className="flex gap-4 p-5 rounded-2xl border border-muted bg-background hover:shadow-sm transition-shadow">
               <div className="flex flex-col items-center gap-1 w-10">
                 <button className="text-muted-foreground hover:text-success transition-colors">
                   <svg width="24" height="24" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.14645 2.14645C7.34171 1.95118 7.65829 1.95118 7.85355 2.14645L11.8536 6.14645C12.0488 6.34171 12.0488 6.65829 11.8536 6.85355C11.6583 7.04882 11.3417 7.04882 11.1464 6.85355L8 3.70711L8 12.5C8 12.7761 7.77614 13 7.5 13C7.22386 13 7 12.7761 7 12.5L7 3.70711L3.85355 6.85355C3.65829 7.04882 3.34171 7.04882 3.14645 6.85355C2.95118 6.65829 2.95118 6.34171 3.14645 6.14645L7.14645 2.14645Z" fill="currentColor" fillRule="evenodd" clipRule="evenodd"></path></svg>
                 </button>
                 <span className="font-bold text-sm">{(142 * i) - (i * 12)}</span>
                 <button className="text-muted-foreground hover:text-danger transition-colors">
                   <svg width="24" height="24" viewBox="0 0 15 15" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M7.14645 12.8536C7.34171 13.0488 7.65829 13.0488 7.85355 12.8536L11.8536 8.85355C12.0488 8.65829 12.0488 8.34171 11.8536 8.14645C11.6583 7.95118 11.3417 7.95118 11.1464 8.14645L8 11.2929L8 2.5C8 2.22386 7.77614 2 7.5 2C7.22386 2 7 2.22386 7 2.5L7 11.2929L3.85355 8.14645C3.65829 7.95118 3.34171 7.95118 3.14645 8.14645C2.95118 8.34171 2.95118 8.65829 3.14645 8.85355L7.14645 12.8536Z" fill="currentColor" fillRule="evenodd" clipRule="evenodd"></path></svg>
                 </button>
               </div>
               <div className="flex-1">
                 <div className="flex items-center gap-2 mb-1">
                   <span className="text-xs font-semibold px-2 py-0.5 bg-muted rounded">c/Local_Issues</span>
                   <span className="text-xs text-muted-foreground">• Posted by u/Citizen_X 4h ago</span>
                 </div>
                 <h2 className="text-lg font-bold mb-2">Potholes on Main Street reported for the 5th time</h2>
                 <p className="text-sm text-muted-foreground mb-4">We've been tracking this issue since February and the city council has yet to allocate the budget. Can someone from the transport department verify the dataset?</p>
                 <div className="flex items-center gap-4 text-xs font-semibold text-muted-foreground">
                   <span className="flex items-center gap-1 hover:bg-muted p-1 rounded cursor-pointer transition-colors">💬 {34 * i} Comments</span>
                   <span className="flex items-center gap-1 hover:bg-muted p-1 rounded cursor-pointer transition-colors">🔗 Share</span>
                   <span className="flex items-center gap-1 hover:bg-muted p-1 rounded cursor-pointer transition-colors">🚩 Report</span>
                 </div>
               </div>
            </div>
          ))}
        </div>

        {/* Sidebar */}
        <aside className="w-full md:w-72 space-y-6">
          <div className="p-6 rounded-2xl bg-foreground text-background">
            <h3 className="font-bold text-lg mb-2">Create a Post</h3>
            <p className="text-sm text-muted mb-4">Have an issue or a question regarding a specific dataset? Let the community know.</p>
            <button className="w-full py-2.5 bg-primary hover:bg-primary/90 text-white font-semibold rounded-xl transition-colors">
              New Discussion
            </button>
          </div>
          
          <div className="p-6 rounded-2xl border border-muted bg-background">
            <h3 className="font-bold mb-4">Top Communities</h3>
            <ul className="space-y-4">
              <li className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2 font-medium"><span className="text-primary font-bold text-lg">1</span> c/Education</div>
                <span className="text-muted-foreground">42k members</span>
              </li>
              <li className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2 font-medium"><span className="text-secondary font-bold text-lg">2</span> c/Govt_Exams</div>
                <span className="text-muted-foreground">38k members</span>
              </li>
              <li className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2 font-medium"><span className="text-accent font-bold text-lg">3</span> c/Local_Issues</div>
                <span className="text-muted-foreground">21k members</span>
              </li>
            </ul>
          </div>
        </aside>
      </section>

      </main>
  );
}
