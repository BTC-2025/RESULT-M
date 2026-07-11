"use client";

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronLeft } from 'lucide-react';
import Link from 'next/link';
import Image from 'next/image';

export default function FootballHubPage() {
  const [activeTab, setActiveTab] = useState<'live' | 'today' | 'upcoming'>('live');

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
                <span className="text-3xl">⚽</span> Football Hub
              </h1>
              <p className="text-slate-400 text-sm font-medium mt-1">Live scores, fixtures, and results</p>
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="flex px-6 gap-6 border-b border-slate-800">
          {[
            { id: 'live', label: 'Live Now' },
            { id: 'today', label: 'Today' },
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
                <motion.div layoutId="fb-tab" className="absolute bottom-0 left-0 right-0 h-0.5 bg-green-500" />
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
              <FootballMatchList type="inprogress" />
            </motion.div>
          )}
          {activeTab === 'today' && (
            <motion.div key="today" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <FootballMatchList type="today" />
            </motion.div>
          )}
          {activeTab === 'upcoming' && (
            <motion.div key="upcoming" initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, y: -10 }}>
              <FootballMatchList type="upcoming" />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}

function FootballMatchList({ type }: { type: 'inprogress' | 'today' | 'upcoming' }) {
  const [matches, setMatches] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
    if (type === 'inprogress') {
      const interval = setInterval(fetchData, 60000);
      return () => clearInterval(interval);
    }
  }, [type]);

  const fetchData = async () => {
    setLoading(true);
    try {
      let url = '/api/sports/football?';
      if (type === 'inprogress') {
        url += 'status=inprogress';
      } else if (type === 'today') {
        const today = new Date().toISOString().split('T')[0];
        url += `date=${today}`;
      } else if (type === 'upcoming') {
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        url += `date=${tomorrow.toISOString().split('T')[0]}`;
      }

      const res = await fetch(url);
      const data = await res.json();
      
      let parsedFootball: any[] = [];
      if (data.success && data.data) {
        data.data.forEach((league: any) => {
          if (league.matches) {
            league.matches.forEach((m: any) => {
              parsedFootball.push({
                id: m.id,
                teamA: m.teams?.home?.name || 'Home',
                teamB: m.teams?.away?.name || 'Away',
                logoA: m.teams?.home?.badge,
                logoB: m.teams?.away?.badge,
                scoreA: m.score?.current?.home,
                scoreB: m.score?.current?.away,
                status: m.status_detail || m.status || 'Scheduled',
                leagueName: league.league?.name || 'International',
                leagueLogo: league.league?.logo,
                round: m.round,
                date: m.date ? new Date(m.date * 1000).toLocaleString() : '',
              });
            });
          }
        });
      }
      
      // Removed mock data for demo purposes
      
      setMatches(parsedFootball);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="text-center py-20 text-green-500 font-bold">Loading Matches...</div>;

  if (matches.length === 0) {
    return (
      <div className="text-center py-20">
        <div className="text-4xl mb-4 opacity-50">⚽</div>
        <div className="text-slate-400 font-medium">No matches found.</div>
      </div>
    );
  }

  // Group by league
  const grouped = matches.reduce((acc, match) => {
    if (!acc[match.leagueName]) acc[match.leagueName] = [];
    acc[match.leagueName].push(match);
    return acc;
  }, {} as Record<string, any[]>);

  return (
    <div className="space-y-8">
      {Object.entries(grouped).map(([leagueName, leagueMatches]: any) => (
        <div key={leagueName}>
          <div className="flex items-center gap-3 mb-4 px-2">
            {leagueMatches[0]?.leagueLogo && (
              <img src={leagueMatches[0].leagueLogo} alt="League" className="w-6 h-6 object-contain bg-white rounded-full p-0.5" />
            )}
            <h2 className="text-sm font-black text-slate-300 uppercase tracking-widest">{leagueName}</h2>
          </div>
          <div className="space-y-3">
            {leagueMatches.map((match: any) => (
              <div key={match.id} className="bg-slate-900 border border-slate-800 rounded-2xl p-5 hover:bg-slate-800 transition-colors flex items-center justify-between">
                
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-4">
                    <span className="text-xs font-bold text-slate-400">{match.status}</span>
                    {type === 'inprogress' && (
                      <span className="bg-red-500/10 text-red-500 text-[9px] font-black tracking-widest uppercase px-1.5 py-0.5 rounded">LIVE</span>
                    )}
                    {match.round && <span className="text-[10px] text-slate-500 font-bold uppercase ml-2 border-l border-slate-700 pl-2">{match.round}</span>}
                    {type !== 'inprogress' && match.date && <span className="text-[10px] text-slate-500 font-bold ml-2 border-l border-slate-700 pl-2">{match.date}</span>}
                  </div>
                  
                  <div className="space-y-2">
                    {/* Team Home */}
                    <div className="flex items-center gap-3">
                      {match.logoA ? (
                        <img src={match.logoA} alt={match.teamA} className="w-8 h-8 object-contain bg-white/5 rounded-full p-1" />
                      ) : (
                        <div className="w-8 h-8 rounded-full bg-slate-800 flex items-center justify-center text-xs">⚽</div>
                      )}
                      <div className="text-lg font-black text-white truncate">{match.teamA}</div>
                    </div>
                    
                    {/* Team Away */}
                    <div className="flex items-center gap-3">
                      {match.logoB ? (
                        <img src={match.logoB} alt={match.teamB} className="w-8 h-8 object-contain bg-white/5 rounded-full p-1" />
                      ) : (
                        <div className="w-8 h-8 rounded-full bg-slate-800 flex items-center justify-center text-xs">⚽</div>
                      )}
                      <div className="text-base font-bold text-slate-400 truncate">{match.teamB}</div>
                    </div>
                  </div>
                </div>

                <div className="flex flex-col items-end gap-3 justify-center h-full pt-6">
                  <div className="text-3xl font-black text-white">{match.scoreA !== undefined ? match.scoreA : '-'}</div>
                  <div className="text-2xl font-bold text-slate-500">{match.scoreB !== undefined ? match.scoreB : '-'}</div>
                </div>

              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
