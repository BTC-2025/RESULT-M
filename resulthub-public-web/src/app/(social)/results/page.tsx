"use client";

import Link from "next/link";
import { useState, useEffect } from "react";
import { api } from "@/lib/api";
import { motion } from "framer-motion";
import { 
  GraduationCap, Landmark, Trophy, Vote, TrendingUp, Clapperboard, 
  Monitor, Scale, Heart, Briefcase, MapPin, ChevronRight, Play, Activity
} from 'lucide-react';

export default function ExplorePage() {
  const [datasets, setDatasets] = useState<any[]>([]);
  const [footballLive, setFootballLive] = useState<any[]>([]);
  const [cricketLive, setCricketLive] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setIsLoading(true);
    try {
      // Fetch Datasets
      const dsRes = await api.datasets.getPublic().catch(() => ({ content: [] }));
      setDatasets(dsRes.content || []);

      // Fetch Football Live
      const fbRes = await fetch('/api/sports/football?status=inprogress').then(r => r.json()).catch(() => ({}));
      let fb: any[] = [];
      if (fbRes.success && fbRes.data) {
        fbRes.data.forEach((league: any) => {
          if (league.matches) {
            league.matches.forEach((m: any) => {
              fb.push({
                id: m.id,
                teamA: m.teams?.home?.name || 'Home',
                teamB: m.teams?.away?.name || 'Away',
                logoA: m.teams?.home?.badge,
                logoB: m.teams?.away?.badge,
                scoreA: m.score?.current?.home,
                scoreB: m.score?.current?.away,
                status: m.status_detail || m.status || 'LIVE',
                leagueName: league.league?.name || 'Football',
              });
            });
          }
        });
      }
      setFootballLive(fb);

      // Fetch Cricket Live
      const crRes = await fetch('/api/sports/cricket?endpoint=currentMatches').then(r => r.json()).catch(() => ({}));
      let cr: any[] = [];
      if (crRes.status === 'success' && crRes.data) {
        const liveCr = crRes.data.filter((m: any) => m.matchStarted && !m.matchEnded);
        cr = liveCr.map((m: any) => {
          const score1 = m.score?.[0];
          const score2 = m.score?.[1];
          return {
            id: m.id,
            name: m.name,
            teamA: m.teams?.[0] || 'TBA',
            teamB: m.teams?.[1] || 'TBA',
            logoA: m.teamInfo?.[0]?.img,
            logoB: m.teamInfo?.[1]?.img,
            scoreStr: score1 ? `${score1.r}/${score1.w} (${score1.o})` : 'Live',
            status: m.status || 'Live',
          };
        });
      }
      setCricketLive(cr);

    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  };

  const categories = [
    { name: 'Academic', icon: GraduationCap, color: 'text-purple-600', bg: 'bg-purple-100', border: 'border-purple-200/50', path: '/search?category=ACADEMIC' },
    { name: 'Government', icon: Landmark, color: 'text-indigo-600', bg: 'bg-indigo-100', border: 'border-indigo-200/50', path: '/search?category=GOVERNMENT' },
    { name: 'Sports', icon: Trophy, color: 'text-emerald-600', bg: 'bg-emerald-100', border: 'border-emerald-200/50', path: '/results/sports' },
    { name: 'Politics', icon: Vote, color: 'text-blue-600', bg: 'bg-blue-100', border: 'border-blue-200/50', path: '/search?category=POLITICS' },
    { name: 'Finance', icon: TrendingUp, color: 'text-amber-600', bg: 'bg-amber-100', border: 'border-amber-200/50', path: '/search?category=FINANCE' },
    { name: 'Entertainment', icon: Clapperboard, color: 'text-pink-600', bg: 'bg-pink-100', border: 'border-pink-200/50', path: '/search?category=ENTERTAINMENT' },
    { name: 'Technology', icon: Monitor, color: 'text-cyan-600', bg: 'bg-cyan-100', border: 'border-cyan-200/50', path: '/search?category=TECH' },
    { name: 'Law', icon: Scale, color: 'text-slate-600', bg: 'bg-slate-100', border: 'border-slate-200/50', path: '/search?category=LAW' },
    { name: 'Healthcare', icon: Heart, color: 'text-red-600', bg: 'bg-red-100', border: 'border-red-200/50', path: '/search?category=HEALTHCARE' },
    { name: 'Business', icon: Briefcase, color: 'text-orange-600', bg: 'bg-orange-100', border: 'border-orange-200/50', path: '/search?category=BUSINESS' },
    { name: 'Hyper Local', icon: MapPin, color: 'text-lime-600', bg: 'bg-lime-100', border: 'border-lime-200/50', path: '/search?category=HYPERLOCAL' },
  ];

  return (
    <div className="w-full flex flex-col min-h-screen bg-[#FAFAFA] font-sans text-zinc-950">
      
      {/* App Bar / Hero */}
      <div className="pt-8 pb-12 px-6 lg:px-12 bg-white border-b border-zinc-200 shadow-sm">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center gap-4 mb-8">
            <div className="w-12 h-12 bg-orange-500 rounded-xl flex items-center justify-center shadow-lg shadow-orange-500/20">
              <span className="text-2xl font-black text-white">R</span>
            </div>
            <div>
              <h1 className="text-3xl font-black tracking-tight text-zinc-950">ResultHub</h1>
              <p className="text-zinc-500 font-medium text-sm">Explore the Global Catalog</p>
            </div>
          </div>
          
          <div className="relative group max-w-2xl">
            <input 
              type="text" 
              placeholder="Search results, organizations, datasets..." 
              className="w-full bg-zinc-50 border border-zinc-200 rounded-2xl py-4 pl-14 pr-16 text-sm font-semibold text-zinc-950 focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] transition-all placeholder:text-zinc-400 shadow-sm"
            />
            <div className="absolute left-5 top-1/2 -translate-y-1/2 text-zinc-400 group-focus-within:text-[#635BFF] transition-colors">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
            </div>
            <div className="absolute right-3 top-1/2 -translate-y-1/2 px-2 py-1 bg-white rounded text-[10px] font-black text-zinc-400 border border-zinc-200 tracking-wider">
              ⌘ K
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto w-full px-6 lg:px-12 py-10 space-y-16">
        
        {/* Featured Carousel */}
        <section>
          <div className="flex gap-4 overflow-x-auto hide-scrollbar pb-6 snap-x">
            
            {/* Featured Dynamic */}
            <Link href="/results/sports/cricket" className="snap-start shrink-0 w-[300px] sm:w-[340px] h-[180px] rounded-3xl bg-gradient-to-br from-emerald-500 to-emerald-700 border border-emerald-400/30 p-6 flex flex-col justify-between group overflow-hidden relative shadow-lg hover:shadow-xl transition-all hover:-translate-y-1">
              <div className="absolute -right-10 -bottom-10 opacity-20 text-9xl">🏏</div>
              <div>
                <span className="text-[10px] font-black uppercase tracking-widest text-emerald-950 bg-white/30 px-2 py-1 rounded-full backdrop-blur-sm shadow-sm">LIVE CRICKET</span>
                <h3 className="text-xl font-black text-white mt-4 leading-tight group-hover:text-emerald-50 transition-colors">
                  {cricketLive.length > 0 ? cricketLive[0].name : "Global Cricket Scores"}
                </h3>
              </div>
              <div className="flex items-center gap-2 text-emerald-50 font-bold text-sm bg-black/10 w-fit px-3 py-1.5 rounded-full backdrop-blur-sm">
                View Matches <ChevronRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
              </div>
            </Link>

            <Link href="/results/sports/football" className="snap-start shrink-0 w-[300px] sm:w-[340px] h-[180px] rounded-3xl bg-gradient-to-br from-blue-500 to-indigo-700 border border-blue-400/30 p-6 flex flex-col justify-between group overflow-hidden relative shadow-lg hover:shadow-xl transition-all hover:-translate-y-1">
              <div className="absolute -right-10 -bottom-10 opacity-20 text-9xl">⚽</div>
              <div>
                <span className="text-[10px] font-black uppercase tracking-widest text-blue-950 bg-white/30 px-2 py-1 rounded-full backdrop-blur-sm shadow-sm">FOOTBALL ACTION</span>
                <h3 className="text-xl font-black text-white mt-4 leading-tight group-hover:text-blue-50 transition-colors">
                  {footballLive.length > 0 ? `${footballLive[0].leagueName} Live` : "Live Football Leagues"}
                </h3>
              </div>
              <div className="flex items-center gap-2 text-blue-50 font-bold text-sm bg-black/10 w-fit px-3 py-1.5 rounded-full backdrop-blur-sm">
                View Matches <ChevronRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
              </div>
            </Link>
            
            {datasets.slice(0, 2).map((ds: any) => (
              <Link href={`/search?category=${ds.domainType}`} key={ds.id} className="snap-start shrink-0 w-[300px] sm:w-[340px] h-[180px] rounded-3xl bg-gradient-to-br from-purple-500 to-fuchsia-700 border border-purple-400/30 p-6 flex flex-col justify-between group overflow-hidden relative shadow-lg hover:shadow-xl transition-all hover:-translate-y-1">
                <div>
                  <span className="text-[10px] font-black uppercase tracking-widest text-purple-950 bg-white/30 px-2 py-1 rounded-full backdrop-blur-sm shadow-sm">{ds.domainType || 'DATASET'}</span>
                  <h3 className="text-xl font-black text-white mt-4 leading-tight line-clamp-2 group-hover:text-purple-50 transition-colors">
                    {ds.name}
                  </h3>
                </div>
                <div className="flex items-center gap-2 text-purple-50 font-bold text-sm bg-black/10 w-fit px-3 py-1.5 rounded-full backdrop-blur-sm">
                  Explore Dataset <ChevronRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </div>
              </Link>
            ))}
          </div>
        </section>

        {/* Live Now */}
        <section>
          <div className="flex items-center gap-3 mb-6">
            <Activity className="w-6 h-6 text-red-500" />
            <h2 className="text-xl font-black tracking-tight text-zinc-950">Live Now</h2>
            <Link href="/results/sports" className="ml-auto text-sm font-bold text-[#635BFF] hover:text-[#5249E5]">View All Live</Link>
          </div>
          
          <div className="flex gap-4 overflow-x-auto hide-scrollbar pb-4 snap-x">
            {cricketLive.map(match => (
              <Link href={`/results/sports/cricket`} key={match.id} className="snap-start shrink-0 w-[280px] bg-white border border-zinc-200/80 rounded-2xl p-5 hover:border-emerald-500 hover:shadow-md transition-all group">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-[10px] font-black uppercase tracking-widest text-emerald-600 bg-emerald-50 px-2 py-1 rounded border border-emerald-100">CRICKET</span>
                  <span className="text-xs font-bold text-zinc-400 flex items-center gap-1.5"><span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse"></span> Live</span>
                </div>
                <div className="font-bold text-zinc-600 text-sm mb-1 truncate">{match.teamA} vs {match.teamB}</div>
                <div className="text-xl font-black text-zinc-950 mb-2">{match.scoreStr}</div>
                <div className="text-xs font-semibold text-emerald-600 truncate">{match.status}</div>
              </Link>
            ))}

            {footballLive.map(match => (
              <Link href={`/results/sports/football`} key={match.id} className="snap-start shrink-0 w-[280px] bg-white border border-zinc-200/80 rounded-2xl p-5 hover:border-blue-500 hover:shadow-md transition-all group">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-[10px] font-black uppercase tracking-widest text-blue-600 bg-blue-50 px-2 py-1 rounded border border-blue-100">FOOTBALL</span>
                  <span className="text-xs font-bold text-zinc-400 flex items-center gap-1.5"><span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse"></span> Live</span>
                </div>
                <div className="font-bold text-zinc-600 text-sm mb-1 truncate">{match.teamA} vs {match.teamB}</div>
                <div className="text-xl font-black text-zinc-950 mb-2">{match.scoreA} - {match.scoreB}</div>
                <div className="text-xs font-semibold text-blue-600 truncate">{match.status}</div>
              </Link>
            ))}
            
            {cricketLive.length === 0 && footballLive.length === 0 && (
              <div className="snap-start shrink-0 w-[280px] bg-white border border-zinc-200/80 rounded-2xl p-5 group shadow-sm opacity-90">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-[10px] font-black uppercase tracking-widest text-orange-600 bg-orange-50 px-2 py-1 rounded border border-orange-100">MARKET</span>
                  <span className="text-xs font-bold text-zinc-400">Market Open</span>
                </div>
                <div className="font-bold text-zinc-600 text-sm mb-1 truncate">Nifty 50 Index</div>
                <div className="text-xl font-black text-zinc-950 mb-2">24,852.30</div>
                <div className="text-xs font-semibold text-orange-500 truncate">+1.2% ▲</div>
              </div>
            )}
          </div>
        </section>

        {/* 11 Categories */}
        <section>
          <div className="flex items-center gap-3 mb-6">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" className="text-[#635BFF]" strokeWidth="2.5"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
            <h2 className="text-xl font-black tracking-tight text-zinc-950">Browse Categories</h2>
          </div>
          
          <div className="flex gap-4 overflow-x-auto hide-scrollbar pb-4">
            {categories.map((cat) => {
              const Icon = cat.icon;
              return (
                <Link href={cat.path} key={cat.name} className="flex flex-col items-center gap-3 min-w-[80px] group cursor-pointer">
                  <div className={`w-16 h-16 rounded-2xl flex items-center justify-center ${cat.bg} border ${cat.border} group-hover:scale-105 group-hover:shadow-md transition-all`}>
                    <Icon className={`w-7 h-7 ${cat.color}`} />
                  </div>
                  <span className="text-xs font-bold text-zinc-600 text-center">{cat.name}</span>
                </Link>
              );
            })}
          </div>
        </section>

        {/* Grid for Trending & Recent */}
        <div className="grid lg:grid-cols-2 gap-12">
          
          {/* Trending Results */}
          <section>
            <div className="flex items-center gap-3 mb-6">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" className="text-orange-500" strokeWidth="2.5"><path d="M12 2L10.29 4.34C9.56 5.35 9.07 6.49 8.87 7.7L8.74 8.6L7.86 8.79C6.55 9.07 5.41 9.77 4.6 10.8L3 12.8L4.6 14.8C5.41 15.83 6.55 16.53 7.86 16.81L8.74 17L8.87 17.9C9.07 19.11 9.56 20.25 10.29 21.26L12 23.6L13.71 21.26C14.44 20.25 14.93 19.11 15.13 17.9L15.26 17L16.14 16.81C17.45 16.53 18.59 15.83 19.4 14.8L21 12.8L19.4 10.8C18.59 9.77 17.45 9.07 16.14 8.79L15.26 8.6L15.13 7.7C14.93 6.49 14.44 5.35 13.71 4.34L12 2Z"></path></svg>
              <h2 className="text-xl font-black tracking-tight text-zinc-950">Trending Results</h2>
            </div>
            
            <div className="space-y-4">
              {datasets.slice(0, 5).map((ds, i) => (
                <Link href={`/search?category=${ds.domainType}`} key={ds.id} className="flex items-center gap-5 p-4 bg-white border border-zinc-200/80 rounded-2xl hover:border-orange-300 hover:shadow-md transition-all group">
                  <span className="text-2xl font-black text-zinc-300 group-hover:text-orange-400 w-8 text-center transition-colors">{i + 1}</span>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-bold text-zinc-950 text-sm truncate mb-1">{ds.name}</h3>
                    <div className="flex items-center gap-2 text-xs font-semibold text-zinc-400">
                      <span className="text-orange-500">{ds.domainType || 'Dataset'}</span>
                      <span>•</span>
                      <span>Trending</span>
                    </div>
                  </div>
                  <ChevronRight className="w-5 h-5 text-zinc-300 group-hover:text-zinc-600 transition-colors" />
                </Link>
              ))}
              {datasets.length === 0 && <div className="text-zinc-400 text-sm font-semibold p-4">No trending datasets found.</div>}
            </div>
          </section>

          {/* Recent Publications */}
          <section>
            <div className="flex items-center gap-3 mb-6">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" className="text-purple-500" strokeWidth="2.5"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
              <h2 className="text-xl font-black tracking-tight text-zinc-950">Recent Publications</h2>
            </div>
            
            <div className="space-y-6">
              {datasets.slice(0, 4).map((ds, i) => (
                <div key={ds.id} className="flex gap-4">
                  <div className="flex flex-col items-center">
                    <div className="w-3 h-3 rounded-full border-2 border-white bg-purple-500 shadow-sm"></div>
                    {i !== 3 && <div className="w-0.5 h-12 bg-zinc-200 mt-1"></div>}
                  </div>
                  <div className="-mt-1">
                    <div className="flex items-center gap-3 mb-1">
                      <span className="text-[10px] font-black text-zinc-400 uppercase">{ds.domainType || 'GENERAL'}</span>
                      <span className="text-[10px] font-bold text-zinc-400">Recently</span>
                    </div>
                    <h3 className="font-bold text-zinc-950 text-sm line-clamp-1 hover:text-purple-600 cursor-pointer transition-colors">
                      {ds.name}
                    </h3>
                  </div>
                </div>
              ))}
              {datasets.length === 0 && <div className="text-zinc-400 text-sm font-semibold p-4">No recent datasets found.</div>}
            </div>
          </section>
          
        </div>

        {/* Quick Access */}
        <section className="pb-20">
          <div className="flex items-center gap-3 mb-6">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" className="text-amber-500" strokeWidth="2.5"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"></polygon></svg>
            <h2 className="text-xl font-black tracking-tight text-zinc-950">Quick Access</h2>
          </div>
          
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {[
              { title: 'Exam Results', icon: GraduationCap, color: 'text-purple-600', bg: 'bg-purple-50' },
              { title: 'Recruitment', icon: Briefcase, color: 'text-emerald-600', bg: 'bg-emerald-50' },
              { title: 'Sports Scores', icon: Trophy, color: 'text-blue-600', bg: 'bg-blue-50' },
              { title: 'Election Live', icon: Vote, color: 'text-pink-600', bg: 'bg-pink-50' },
              { title: 'Court Orders', icon: Scale, color: 'text-zinc-600', bg: 'bg-zinc-100' },
              { title: 'Market Reports', icon: TrendingUp, color: 'text-amber-600', bg: 'bg-amber-50' }
            ].map(link => {
              const Icon = link.icon;
              return (
                <Link href="/explore" key={link.title} className="bg-white border border-zinc-200/80 rounded-xl p-4 flex items-center gap-3 hover:shadow-md hover:border-zinc-300 transition-all group">
                  <div className={`p-2 rounded-lg ${link.bg}`}>
                    <Icon className={`w-5 h-5 ${link.color}`} />
                  </div>
                  <span className="text-sm font-bold text-zinc-800">{link.title}</span>
                </Link>
              );
            })}
          </div>
        </section>

      </div>
    </div>
  );
}
