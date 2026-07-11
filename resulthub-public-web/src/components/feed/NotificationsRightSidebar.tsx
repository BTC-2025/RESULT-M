"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { API_BASE_URL } from "@/lib/api";

export default function NotificationsRightSidebar({ className = "" }: { className?: string }) {
  const [liveData, setLiveData] = useState<any>({
    nifty: { value: "24,512.20", change: "+0.00%" },
    sensex: { value: "80,234.10", change: "+0.00%" },
    cricket: { score: "186/4", status: "LIVE" },
    football: { score: "2 - 1", status: "Second Half" }
  });

  useEffect(() => {
    let wsUrl = 'ws://localhost:8080/ws/live';
    try {
      const url = new URL(API_BASE_URL);
      const protocol = url.protocol === 'https:' ? 'wss:' : 'ws:';
      wsUrl = `${protocol}//${url.host}/ws/live`;
    } catch (e) {
      console.error("Failed to construct WS URL, using fallback", e);
    }

    const ws = new WebSocket(wsUrl);
    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        setLiveData((prev: any) => {
          const next = { ...prev };
          if (data.type === 'finance') {
            if (data.id === 'NIFTY 50') next.nifty = data;
            if (data.id === 'SENSEX') next.sensex = data;
          } else if (data.type === 'cricket') {
            next.cricket = data;
          } else if (data.type === 'football') {
            next.football = data;
          }
          return next;
        });
      } catch (e) {}
    };

    return () => {
      ws.close();
    };
  }, []);
  return (
    <aside className={`flex flex-col gap-6 w-full pb-6 pt-5 ${className}`}>
      
      {/* SaaS Unified Dashboard Widget */}
      <div className="bg-background rounded-2xl border border-muted shadow-sm overflow-hidden flex flex-col">
        
        {/* Section 1: Today's Activity (Mini Stat Cards) */}
        <div className="p-4 border-b border-muted">
          <h3 className="text-xs font-black text-muted-foreground uppercase tracking-widest mb-3">Today's Activity</h3>
          <div className="grid grid-cols-2 gap-2">
            <div className="bg-muted/30 p-2.5 rounded-xl border border-muted/50 flex flex-col items-start hover:bg-muted/50 transition-colors cursor-pointer">
              <span className="text-[11px] font-bold text-muted-foreground">Likes</span>
              <span className="text-lg font-black text-foreground">56</span>
            </div>
            <div className="bg-muted/30 p-2.5 rounded-xl border border-muted/50 flex flex-col items-start hover:bg-muted/50 transition-colors cursor-pointer">
              <span className="text-[11px] font-bold text-muted-foreground">Comments</span>
              <span className="text-lg font-black text-foreground">12</span>
            </div>
            <div className="bg-muted/30 p-2.5 rounded-xl border border-muted/50 flex flex-col items-start hover:bg-muted/50 transition-colors cursor-pointer">
              <span className="text-[11px] font-bold text-muted-foreground">Followers</span>
              <span className="text-lg font-black text-foreground">3</span>
            </div>
            <div className="bg-muted/30 p-2.5 rounded-xl border border-muted/50 flex flex-col items-start hover:bg-muted/50 transition-colors cursor-pointer">
              <span className="text-[11px] font-bold text-muted-foreground">Poll Votes</span>
              <span className="text-lg font-black text-foreground">18</span>
            </div>
          </div>
        </div>

        {/* Section 2: Live Market & Sports (WebSocket) */}
        <div className="p-4 border-b border-muted bg-gradient-to-br from-primary/[0.03] to-background">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-xs font-black text-muted-foreground uppercase tracking-widest">Live Updates</h3>
            <span className="flex items-center gap-1.5 text-[10px] font-bold bg-red-500/10 text-red-600 px-2 py-0.5 rounded-full">
               <span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse"></span>
               LIVE
            </span>
          </div>
          <div className="space-y-3">
            {/* Finance Tickers */}
            <div className="grid grid-cols-2 gap-2">
              <div className="bg-background rounded-lg p-2 border border-muted flex flex-col justify-between">
                <span className="text-[10px] font-bold text-muted-foreground">NIFTY 50</span>
                <div className="flex items-end justify-between mt-1">
                  <span className="text-sm font-black">{liveData.nifty.value}</span>
                  <span className={`text-[10px] font-bold ${liveData.nifty.change.startsWith('+') ? 'text-emerald-500' : 'text-red-500'}`}>
                    {liveData.nifty.change}
                  </span>
                </div>
              </div>
              <div className="bg-background rounded-lg p-2 border border-muted flex flex-col justify-between">
                <span className="text-[10px] font-bold text-muted-foreground">SENSEX</span>
                <div className="flex items-end justify-between mt-1">
                  <span className="text-sm font-black">{liveData.sensex.value}</span>
                  <span className={`text-[10px] font-bold ${liveData.sensex.change.startsWith('+') ? 'text-emerald-500' : 'text-red-500'}`}>
                    {liveData.sensex.change}
                  </span>
                </div>
              </div>
            </div>
            
            {/* Sports Tickers */}
            <div className="grid grid-cols-2 gap-2">
              <div className="bg-background rounded-lg p-2 border border-muted flex flex-col">
                <span className="text-[10px] font-bold text-muted-foreground">Cricket</span>
                <span className="text-sm font-black mt-1">{liveData.cricket.score}</span>
                <span className="text-[10px] font-medium text-muted-foreground">{liveData.cricket.status}</span>
              </div>
              <div className="bg-background rounded-lg p-2 border border-muted flex flex-col">
                <span className="text-[10px] font-bold text-muted-foreground">Football</span>
                <span className="text-sm font-black mt-1">{liveData.football.score}</span>
                <span className="text-[10px] font-medium text-muted-foreground">{liveData.football.status}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Section 3: Smart Insights */}
        <div className="p-4 border-b border-muted">
          <h3 className="text-xs font-black text-muted-foreground uppercase tracking-widest mb-3">Insights</h3>
          
          <div className="space-y-4">
            <div>
              <p className="text-[11px] font-bold text-muted-foreground mb-1">Most Active Organization</p>
              <div className="flex items-center gap-2 group cursor-pointer">
                <div className="w-6 h-6 rounded-md bg-emerald-500 flex items-center justify-center text-white text-xs font-bold shadow-sm">G</div>
                <div>
                  <h4 className="text-[13px] font-bold text-foreground group-hover:underline">Government Jobs Board</h4>
                  <p className="text-[11px] text-muted-foreground font-medium">15 Updates This Week</p>
                </div>
              </div>
            </div>
            
            <div>
              <p className="text-[11px] font-bold text-muted-foreground mb-1">Most Engaged Content</p>
              <div className="group cursor-pointer">
                <h4 className="text-[13px] font-bold text-foreground group-hover:underline line-clamp-1">TNPSC Result Analysis</h4>
                <p className="text-[11px] text-primary font-bold">347 Interactions</p>
              </div>
            </div>
          </div>
        </div>

        {/* Section 4: Quick Actions Grid */}
        <div className="p-4 bg-muted/10">
          <h3 className="text-xs font-black text-muted-foreground uppercase tracking-widest mb-3">Quick Actions</h3>
          <div className="grid grid-cols-4 gap-2">
            <button className="flex flex-col items-center justify-center p-2 rounded-xl hover:bg-muted transition-colors text-muted-foreground hover:text-foreground group" title="Create Update">
               <div className="w-8 h-8 rounded-full bg-background border border-muted shadow-sm flex items-center justify-center mb-1.5 group-hover:border-primary/30 group-hover:text-primary transition-colors">
                 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M12 20h9"></path><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"></path></svg>
               </div>
               <span className="text-[9px] font-bold uppercase">Update</span>
            </button>
            <button className="flex flex-col items-center justify-center p-2 rounded-xl hover:bg-muted transition-colors text-muted-foreground hover:text-foreground group" title="Create Poll">
               <div className="w-8 h-8 rounded-full bg-background border border-muted shadow-sm flex items-center justify-center mb-1.5 group-hover:border-primary/30 group-hover:text-primary transition-colors">
                 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M18 20V10"></path><path d="M12 20V4"></path><path d="M6 20v-6"></path></svg>
               </div>
               <span className="text-[9px] font-bold uppercase">Poll</span>
            </button>
            <button className="flex flex-col items-center justify-center p-2 rounded-xl hover:bg-muted transition-colors text-muted-foreground hover:text-foreground group" title="Create Complaint">
               <div className="w-8 h-8 rounded-full bg-background border border-muted shadow-sm flex items-center justify-center mb-1.5 group-hover:border-red-500/30 group-hover:text-red-500 transition-colors">
                 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
               </div>
               <span className="text-[9px] font-bold uppercase">Report</span>
            </button>
            <button className="flex flex-col items-center justify-center p-2 rounded-xl hover:bg-muted transition-colors text-muted-foreground hover:text-foreground group" title="Create Dataset">
               <div className="w-8 h-8 rounded-full bg-background border border-muted shadow-sm flex items-center justify-center mb-1.5 group-hover:border-blue-500/30 group-hover:text-blue-500 transition-colors">
                 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><ellipse cx="12" cy="5" rx="9" ry="3"></ellipse><path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"></path><path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"></path></svg>
               </div>
               <span className="text-[9px] font-bold uppercase">Dataset</span>
            </button>
          </div>
        </div>

      </div>

      {/* Footer Links */}
      <div className="flex flex-wrap gap-x-3 gap-y-1 px-4 text-[11px] font-bold text-muted-foreground/60">
         <Link href="/terms" className="hover:underline hover:text-foreground transition-colors">Terms</Link>
         <Link href="/privacy" className="hover:underline hover:text-foreground transition-colors">Privacy</Link>
         <span>© 2026 ResultHub Corp.</span>
      </div>

    </aside>
  );
}
