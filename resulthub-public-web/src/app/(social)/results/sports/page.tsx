"use client";

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronRight } from 'lucide-react';
import Link from 'next/link';
import Image from 'next/image';

const SPORTS = [
  { name: 'Cricket', emoji: '🏏', subtitle: 'IPL, Test, T20I, ODI', color: 'bg-emerald-500', route: '/sports/cricket' },
  { name: 'Football', emoji: '⚽', subtitle: 'ISL, EPL, La Liga', color: 'bg-green-500', route: '/sports/football' },
  { name: 'Kabaddi', emoji: '🤼', subtitle: 'Pro Kabaddi League', color: 'bg-green-600', route: '/sports/kabaddi' },
  { name: 'Badminton', emoji: '🏸', subtitle: 'BWF World Tour', color: 'bg-green-700', route: '/sports/badminton' },
  { name: 'Athletics', emoji: '🏃', subtitle: 'Olympics, Asian Games', color: 'bg-green-800', route: '/sports/athletics' },
  { name: 'Formula 1', emoji: '🏎️', subtitle: 'FIA Formula One', color: 'bg-emerald-800', route: '/sports/f1' },
  { name: 'Tennis', emoji: '🎾', subtitle: 'ATP, WTA, Grand Slams', color: 'bg-green-400', route: '/sports/tennis' },
  { name: 'Basketball', emoji: '🏀', subtitle: 'NBA, NBL India', color: 'bg-emerald-300', route: '/sports/basketball' },
  { name: 'Esports', emoji: '🎮', subtitle: 'BGMI, Valorant', color: 'bg-emerald-400', route: '/sports/esports' },
  { name: 'Local Sports', emoji: '📍', subtitle: 'Gully cricket, academies', color: 'bg-green-300', route: '/sports/local' },
];

export default function SportsHubPage() {
  const [activeTab, setActiveTab] = useState<'live' | 'leagues' | 'mysports'>('live');

  return (
    <div className="min-h-screen bg-slate-950 text-white font-sans w-full max-w-4xl mx-auto border-x border-slate-900">
      
      {/* Header */}
      <div className="bg-slate-900 border-b border-slate-800 sticky top-0 z-10 pt-16 md:pt-4">
        <div className="px-6 pb-6">
          <div className="flex items-center gap-4 mb-8">
            <h1 className="text-2xl font-black">Sports Hub</h1>
          </div>
          
          <div className="flex gap-4">
            <div className="flex-1 bg-white/10 rounded-xl p-3">
              <div className="text-lg font-black">10+</div>
              <div className="text-[10px] text-slate-400 uppercase tracking-wider font-bold mt-1">Sports</div>
            </div>
            <div className="flex-1 bg-white/10 rounded-xl p-3">
              <div className="text-lg font-black text-red-400 flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse"></span>
                LIVE
              </div>
              <div className="text-[10px] text-slate-400 uppercase tracking-wider font-bold mt-1">Matches Today</div>
            </div>
            <div className="flex-1 bg-white/10 rounded-xl p-3">
              <div className="text-lg font-black">50M+</div>
              <div className="text-[10px] text-slate-400 uppercase tracking-wider font-bold mt-1">Fans</div>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex px-6 gap-6 border-b border-slate-800">
          {[
            { id: 'live', label: 'Live' },
            { id: 'leagues', label: 'Leagues' },
            { id: 'mysports', label: 'My Sports' }
          ].map(tab => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`pb-4 font-bold text-sm relative transition-colors ${
                activeTab === tab.id ? 'text-white' : 'text-slate-500 hover:text-slate-300'
              }`}
            >
              {tab.label}
              {activeTab === tab.id && (
                <motion.div layoutId="sports-tab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-orange-500" />
              )}
            </button>
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="p-6">
        <AnimatePresence mode="wait">
          {activeTab === 'live' && (
            <motion.div key="live" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <LiveMatchesTab />
            </motion.div>
          )}
          {activeTab === 'leagues' && (
            <motion.div key="leagues" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <LeaguesTab />
            </motion.div>
          )}
          {activeTab === 'mysports' && (
            <motion.div key="mysports" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <MySportsTab />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}

// ─── Live Matches Tab ────────────────────────────────────────────────────────
function LiveMatchesTab() {
  const [football, setFootball] = useState<any[]>([]);
  const [cricket, setCricket] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 60000);
    return () => clearInterval(interval);
  }, []);

  const fetchData = async () => {
    try {
      // Fetch Football (inprogress)
      const fRes = await fetch('/api/sports/football?status=inprogress');
      const fData = await fRes.json();
      
      // Parse Football structure (similar to flutter logic)
      let parsedFootball: any[] = [];
      if (fData.success && fData.data) {
        fData.data.forEach((league: any) => {
          if (league.matches) {
            league.matches.forEach((m: any) => {
              parsedFootball.push({
                id: m.id,
                teamA: m.teams?.home?.name || 'Home',
                teamB: m.teams?.away?.name || 'Away',
                scoreA: m.score?.current?.home ?? 0,
                scoreB: m.score?.current?.away ?? 0,
                status: m.status_detail || m.status || 'Live',
                logoA: m.teams?.home?.badge,
                logoB: m.teams?.away?.badge
              });
            });
          }
        });
      }
      // Removed mock data for demo purposes
      setFootball(parsedFootball);

      // Fetch Cricket
      const cRes = await fetch('/api/sports/cricket?endpoint=currentMatches');
      const cData = await cRes.json();
      let parsedCricket: any[] = [];
      if (cData.status === 'success' && cData.data) {
        parsedCricket = cData.data.filter((m: any) => m.matchStarted && !m.matchEnded).map((m: any) => {
          const score1 = m.score?.[0];
          const score2 = m.score?.[1];
          return {
            id: m.id,
            teamA: m.teams?.[0] || 'TBA',
            teamB: m.teams?.[1] || 'TBA',
            scoreA: score1 ? `${score1.r}/${score1.w} (${score1.o})` : '–',
            scoreB: score2 ? `${score2.r}/${score2.w} (${score2.o})` : '–',
            status: m.matchType ? m.matchType.toUpperCase() : 'LIVE',
          };
        });
      }
      setCricket(parsedCricket);

    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="text-center py-20 text-emerald-500 font-bold">Loading Live Scores...</div>;

  return (
    <div className="space-y-8">
      <div>
        <div className="flex items-center gap-2 mb-4">
          <span className="text-lg">⚽</span>
          <h2 className="text-sm font-bold text-slate-300 uppercase tracking-widest">Football</h2>
        </div>
        <div className="space-y-4">
          {football.length === 0 ? (
            <div className="text-slate-500 text-sm font-medium">No live matches right now.</div>
          ) : (
            football.map(match => <LiveCard key={match.id} match={match} href="/results/sports/football" />)
          )}
        </div>
      </div>

      <div>
        <div className="flex items-center gap-2 mb-4">
          <span className="text-lg">🏏</span>
          <h2 className="text-sm font-bold text-slate-300 uppercase tracking-widest">Cricket</h2>
        </div>
        <div className="space-y-4">
          {cricket.length === 0 ? (
            <div className="text-slate-500 text-sm font-medium">No live cricket right now.</div>
          ) : (
            cricket.map(match => <LiveCard key={match.id} match={match} href="/results/sports/cricket" />)
          )}
        </div>
      </div>
    </div>
  );
}

function LiveCard({ match, href }: { match: any, href: string }) {
  return (
    <Link href={href} className="bg-slate-900 border border-emerald-500/30 rounded-2xl p-5 hover:bg-slate-800 transition-colors cursor-pointer flex items-center justify-between group block">
      <div className="flex-1">
        <div className="flex items-center gap-2 mb-3">
          <span className="text-xs font-bold text-slate-400">{match.status}</span>
          <span className="bg-red-500/10 text-red-500 text-[9px] font-black tracking-widest uppercase px-1.5 py-0.5 rounded">LIVE</span>
        </div>
        <div className="space-y-1">
          <div className="text-lg font-black text-white truncate">{match.teamA}</div>
          <div className="text-base font-bold text-slate-400 truncate">{match.teamB}</div>
        </div>
      </div>
      <div className="flex flex-col items-end gap-1">
        <div className="text-3xl font-black text-white">{match.scoreA}</div>
        <div className="text-2xl font-bold text-slate-500">{match.scoreB}</div>
      </div>
      <div className="ml-4 pl-4 border-l border-slate-800 opacity-0 group-hover:opacity-100 transition-opacity">
        <ChevronRight className="w-5 h-5 text-emerald-500" />
      </div>
    </Link>
  );
}

// ─── Leagues Tab ─────────────────────────────────────────────────────────────
function LeaguesTab() {
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
      {SPORTS.map((s, i) => (
        <div key={i} className="bg-slate-900 border border-slate-800 rounded-2xl p-4 flex flex-col justify-between aspect-[1.2] hover:border-emerald-500/50 transition-colors cursor-pointer group">
          <div className="text-3xl group-hover:scale-110 transition-transform origin-left">{s.emoji}</div>
          <div>
            <div className="font-black text-base text-white">{s.name}</div>
            <div className="text-[11px] font-medium text-slate-500 truncate mt-0.5">{s.subtitle}</div>
          </div>
        </div>
      ))}
    </div>
  );
}

// ─── My Sports Tab ───────────────────────────────────────────────────────────
function MySportsTab() {
  return (
    <div className="text-center py-24 flex flex-col items-center">
      <div className="w-16 h-16 rounded-full bg-slate-900 border border-slate-800 flex items-center justify-center mb-4 text-slate-600">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polygon points="12 2 15.09 5.09 19.5 5.5 19.91 9.91 23 12 19.91 14.09 19.5 18.5 15.09 18.91 12 22 8.91 18.91 4.5 18.5 4.09 14.09 1 12 4.09 9.91 4.5 5.5 8.91 5.09 12 2"></polygon></svg>
      </div>
      <h3 className="text-xl font-black text-white mb-2">Follow Sports</h3>
      <p className="text-sm text-slate-400 max-w-[200px] mb-6">Follow your favourite leagues to see them first here</p>
      <button className="bg-emerald-500 text-slate-950 font-black px-6 py-2.5 rounded-full hover:bg-emerald-400 transition-colors flex items-center gap-2 text-sm">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
        Browse Sports
      </button>
    </div>
  );
}
