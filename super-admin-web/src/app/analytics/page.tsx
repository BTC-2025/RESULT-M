"use client";

import React, { useState, useEffect } from 'react';
import { useAuth } from '@/context/AuthContext';
import Header from '@/components/Header';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  Tooltip, 
  ResponsiveContainer,
  PieChart, 
  Pie, 
  Cell,
  Legend
} from 'recharts';
import { Users, Building, ShieldCheck, Globe2, Sparkles, AlertCircle } from 'lucide-react';

interface UserDistribution {
  name: string;
  value: number;
  color: string;
  icon: any;
}

interface CityData {
  city: string;
  count: number;
}

export default function AnalyticsPage() {
  const { apiFetch } = useAuth();
  const [usersDistribution, setUsersDistribution] = useState<UserDistribution[]>([]);
  const [cityData, setCityData] = useState<CityData[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchAnalyticsData = async () => {
      try {
        // Fetch all users to aggregate statistics dynamically (since we want real backend data!)
        // In a large system, this would be an aggregation endpoint, but here we can aggregate the response of GET /api/v1/admin/users
        const res = await apiFetch('/api/v1/admin/users?page=0&size=1000');
        if (!res.ok) {
          throw new Error("Unable to load user distribution statistics.");
        }
        const responseData = await res.json();
        const usersList = responseData.content || [];

        // Aggregate User Roles
        let admins = 0;
        let members = 0;
        let organizations = 0;
        
        // Aggregate Cities
        const cityCounts: { [key: string]: number } = {};

        usersList.forEach((u: any) => {
          if (u.role === 'ADMIN') admins++;
          else if (u.role === 'ORGANIZATION') organizations++;
          else members++;

          if (u.city) {
            const cityName = u.city.trim();
            cityCounts[cityName] = (cityCounts[cityName] || 0) + 1;
          }
        });

        // Set distribution data
        setUsersDistribution([
          { name: 'End Users', value: members, color: '#8B5CF6', icon: Users },
          { name: 'Organizations', value: organizations, color: '#F43F5E', icon: Building },
          { name: 'Platform Admins', value: admins, color: '#10B981', icon: ShieldCheck }
        ]);

        // Convert cityCounts to Array sorted by count
        const citiesList = Object.keys(cityCounts).map(city => ({
          city: city || 'Unspecified',
          count: cityCounts[city]
        })).sort((a, b) => b.count - a.count).slice(0, 10);

        setCityData(citiesList.length > 0 ? citiesList : [{ city: 'No City Mapped', count: 0 }]);

      } catch (err: any) {
        setError(err.message || "An unexpected error occurred while loading analytics.");
      } finally {
        setLoading(false);
      }
    };

    fetchAnalyticsData();
  }, []);

  if (loading) {
    return (
      <div className="flex flex-col min-h-screen">
        <Header title="Platform Analytics" />
        <div className="flex-1 flex items-center justify-center p-8">
          <div className="w-12 h-12 border-4 border-accentPurple border-t-transparent rounded-full animate-spin"></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col min-h-screen">
        <Header title="Platform Analytics" />
        <div className="flex-1 p-8">
          <div className="glass-panel border border-accentRose/20 p-8 rounded-3xl flex flex-col items-center justify-center max-w-xl mx-auto mt-20 text-center">
            <AlertCircle className="w-16 h-16 text-accentRose mb-4 animate-bounce" />
            <h3 className="text-xl font-extrabold text-white mb-2">Analytics Error</h3>
            <p className="text-textSecondary text-sm mb-6">{error}</p>
            <button 
              onClick={() => window.location.reload()}
              className="bg-accentPurple px-6 py-2.5 rounded-xl text-white font-bold text-xs uppercase tracking-wider hover:opacity-90 transition-all shadow-glow"
            >
              Reload View
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col min-h-screen">
      <Header title="Platform Analytics" />

      <main className="flex-1 p-8 space-y-8 mt-20 ml-64">
        {/* Intro */}
        <div className="glass-panel p-6 rounded-3xl flex items-center justify-between border border-white/5 relative overflow-hidden">
          <div className="absolute top-0 right-0 w-[250px] h-[250px] bg-accentRose/5 rounded-full blur-[80px] pointer-events-none"></div>
          <div className="flex items-center gap-4">
            <div className="bg-accentRose/10 p-3 rounded-2xl border border-accentRose/30 text-accentRose">
              <Globe2 className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-lg font-bold text-white">Platform Demographics</h3>
              <p className="text-xs text-textSecondary mt-0.5 font-medium">Platform-wide account distributions and geographical registration statistics.</p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Pie Chart: Role Distributions */}
          <div className="glass-panel p-6 rounded-3xl lg:col-span-1 flex flex-col justify-between">
            <div>
              <h3 className="text-base font-extrabold text-white">Account Types</h3>
              <p className="text-xs text-textSecondary mt-0.5 mb-4">Distribution of user accounts on the platform.</p>
            </div>

            <div className="h-[250px] w-full relative">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={usersDistribution}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={80}
                    paddingAngle={4}
                    dataKey="value"
                  >
                    {usersDistribution.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <Tooltip 
                    contentStyle={{ 
                      background: 'rgba(17, 24, 39, 0.95)', 
                      borderColor: 'rgba(255,255,255,0.05)', 
                      borderRadius: '16px',
                      color: '#F3F4F6'
                    }} 
                  />
                </PieChart>
              </ResponsiveContainer>
              <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                <span className="text-2xl font-extrabold text-white">
                  {usersDistribution.reduce((acc, curr) => acc + curr.value, 0)}
                </span>
                <span className="text-[10px] text-textSecondary font-bold uppercase tracking-wider">Total Accounts</span>
              </div>
            </div>

            {/* Legends */}
            <div className="space-y-2.5 mt-4">
              {usersDistribution.map((dist, idx) => {
                const Icon = dist.icon;
                return (
                  <div key={idx} className="flex items-center justify-between text-xs px-3 py-2 bg-white/5 rounded-xl border border-white/5">
                    <div className="flex items-center gap-2 font-semibold text-textSecondary">
                      <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: dist.color }} />
                      <Icon className="w-3.5 h-3.5" />
                      <span>{dist.name}</span>
                    </div>
                    <span className="font-extrabold text-white">{dist.value}</span>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Bar Chart: Geographic registrations */}
          <div className="glass-panel p-6 rounded-3xl lg:col-span-2 flex flex-col space-y-6">
            <div>
              <h3 className="text-base font-extrabold text-white">Geographical Registration (Top Cities)</h3>
              <p className="text-xs text-textSecondary mt-0.5">Distribution of user accounts according to their registered city details.</p>
            </div>

            <div className="h-[320px] w-full">
              {cityData.length > 0 && cityData[0].count > 0 ? (
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={cityData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                    <XAxis 
                      dataKey="city" 
                      stroke="#9CA3AF" 
                      fontSize={11} 
                      tickLine={false} 
                      axisLine={false} 
                      dy={10}
                    />
                    <YAxis 
                      stroke="#9CA3AF" 
                      fontSize={11} 
                      tickLine={false} 
                      axisLine={false} 
                      dx={-5}
                    />
                    <Tooltip 
                      contentStyle={{ 
                        background: 'rgba(17, 24, 39, 0.95)', 
                        borderColor: 'rgba(139, 92, 246, 0.4)', 
                        borderRadius: '16px',
                        color: '#F3F4F6'
                      }} 
                    />
                    <Bar dataKey="count" fill="#8B5CF6" radius={[8, 8, 0, 0]}>
                      {cityData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={index % 2 === 0 ? '#8B5CF6' : '#F43F5E'} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="h-full flex flex-col items-center justify-center text-textSecondary gap-2">
                  <Globe2 className="w-12 h-12 opacity-35" />
                  <p className="text-sm font-semibold">No city demographic details logged on the platform yet.</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
