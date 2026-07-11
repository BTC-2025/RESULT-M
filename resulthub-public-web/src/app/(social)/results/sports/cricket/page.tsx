"use client";

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronLeft } from 'lucide-react';
import Link from 'next/link';

export default function CricketHubPage() {
  const [activeTab, setActiveTab] = useState<'live' | 'upcoming'>('live');

  return (
    <div className="min-h-screen bg-slate-950 text-white font-sans w-full max-w-4xl mx-auto border-x border-slate-900">
      
      {/* Header */}
      <div className="bg-slate-900 border-b border-slate-800 sticky top-0 z-10 pt-16 md:pt-4">
        <div className="px-6 pb-6">
          <div className="flex items-center gap-4 mb-6">
            <Link href="/results/sports" className="p-2 hover:bg-slate-800 rounded-full transition-colors">
              <ChevronLeft className="w-6 h-6 text-slate-400 hover:text-white" />
            </Link>
            <div>
              <h1 className="text-2xl font-black flex items-center gap-2">
                <span className="text-3xl">🏏</span> Cricket Hub
              </h1>
              <p className="text-slate-400 text-sm font-medium mt-1">Live scores, fixtures, and results</p>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex px-6 gap-6 border-b border-slate-800">
          {[
            { id: 'live', label: 'Live & Recent' },
            { id: 'upcoming', label: 'Upcoming' }
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
                <motion.div layoutId="cric-tab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-emerald-500" />
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
              <CricketMatchList type="currentMatches" />
            </motion.div>
          )}
          {activeTab === 'upcoming' && (
            <motion.div key="upcoming" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <CricketMatchList type="matches" />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}

function CricketMatchList({ type }: { type: 'currentMatches' | 'matches' }) {
  const [matches, setMatches] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
    if (type === 'currentMatches') {
      const interval = setInterval(fetchData, 60000);
      return () => clearInterval(interval);
    }
  }, [type]);

  const fetchData = async () => {
    setLoading(true);
    try {
      const res = await fetch(`/api/sports/cricket?endpoint=${type}`);
      const data = await res.json();
      
      let parsedCricket: any[] = [];
      if (data.status === 'success' && data.data) {
        let rawMatches = data.data;
        if (type === 'matches') {
          // Upcoming matches filter (not started)
          rawMatches = rawMatches.filter((m: any) => !m.matchStarted && !m.matchEnded);
        }
        
        parsedCricket = rawMatches.map((m: any) => {
          const score1 = m.score?.[0];
          const score2 = m.score?.[1];
          return {
            id: m.id,
            name: m.name,
            teamA: m.teams?.[0] || 'TBA',
            teamB: m.teams?.[1] || 'TBA',
            logoA: m.teamInfo?.[0]?.img,
            logoB: m.teamInfo?.[1]?.img,
            scoreA: score1 ? `${score1.r}/${score1.w} (${score1.o})` : '–',
            scoreB: score2 ? `${score2.r}/${score2.w} (${score2.o})` : '–',
            statusLabel: m.status || 'Scheduled',
            matchType: m.matchType ? m.matchType.toUpperCase() : 'LIVE',
            isLive: m.matchStarted && !m.matchEnded,
            date: m.dateTimeGMT ? new Date(m.dateTimeGMT).toLocaleDateString() : '',
            venue: m.venue || 'TBA',
          };
        });
      }
      
      setMatches(parsedCricket);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="text-center py-20 text-emerald-500 font-bold">Loading Matches...</div>;

  if (matches.length === 0) {
    return (
      <div className="text-center py-20">
        <div className="text-4xl mb-4 opacity-50">🏏</div>
        <div className="text-slate-400 font-medium">No matches found.</div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {matches.map(match => (
        <div key={match.id} className="bg-slate-900 border border-slate-800 rounded-2xl p-5 hover:border-emerald-500/50 transition-colors">
          
          <div className="flex items-center gap-2 mb-6">
            <span className="text-[10px] font-black text-slate-400 bg-slate-800 px-2 py-1 rounded-full uppercase">{match.matchType}</span>
            {match.isLive ? (
               <span className="bg-red-500/10 text-red-500 text-[10px] font-black tracking-widest uppercase px-2 py-1 rounded-full flex items-center gap-1">
                 <span className="w-1.5 h-1.5 rounded-full bg-red-500 animate-pulse"></span> LIVE
               </span>
            ) : (
               <span className="bg-slate-800 text-slate-300 text-[10px] font-black tracking-widest uppercase px-2 py-1 rounded-full">{match.date}</span>
            )}
            <span className="text-[11px] font-bold text-slate-500 truncate max-w-[200px] ml-auto border-l border-slate-700 pl-3">📍 {match.venue}</span>
          </div>

          <div className="grid grid-cols-[1fr_auto_1fr] gap-6 mb-4 items-center">
            {/* Team A */}
            <div className="flex flex-col items-end text-right space-y-2">
              <div className="flex items-center gap-3">
                <div className="text-lg font-black text-white truncate max-w-[150px]">{match.teamA}</div>
                {match.logoA ? (
                  <img src={match.logoA} alt={match.teamA} className="w-10 h-10 object-cover bg-white rounded-full border-2 border-slate-800" />
                ) : (
                  <div className="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center text-xs border-2 border-slate-700">T</div>
                )}
              </div>
              {match.scoreA !== '–' && <div className="text-2xl font-black text-emerald-400 bg-emerald-500/10 px-3 py-1 rounded-lg">{match.scoreA}</div>}
            </div>
            
            <div className="text-xs font-black text-slate-600 bg-slate-800 rounded-full w-8 h-8 flex items-center justify-center">VS</div>

            {/* Team B */}
            <div className="flex flex-col items-start text-left space-y-2">
              <div className="flex items-center gap-3">
                {match.logoB ? (
                  <img src={match.logoB} alt={match.teamB} className="w-10 h-10 object-cover bg-white rounded-full border-2 border-slate-800" />
                ) : (
                  <div className="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center text-xs border-2 border-slate-700">T</div>
                )}
                <div className="text-lg font-black text-white truncate max-w-[150px]">{match.teamB}</div>
              </div>
              {match.scoreB !== '–' && <div className="text-2xl font-black text-emerald-400 bg-emerald-500/10 px-3 py-1 rounded-lg">{match.scoreB}</div>}
            </div>
          </div>

          <div className="w-full h-px bg-slate-800/50 my-4" />
          
          <div className="text-sm font-bold text-emerald-500/90 text-center bg-slate-800/30 p-2 rounded-xl">
            {match.statusLabel}
          </div>
        </div>
      ))}
    </div>
  );
}
