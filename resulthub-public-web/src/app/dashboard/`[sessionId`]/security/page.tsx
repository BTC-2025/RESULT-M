"use client";

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  ShieldCheck, 
  TriangleAlert, 
  ShieldAlert, 
  Laptop2, 
  Smartphone, 
  Key, 
  Fingerprint, 
  Lock, 
  Globe, 
  PowerOff, 
  Activity, 
  AlertCircle, 
  Search, 
  RefreshCw,
  X,
  Clock
} from 'lucide-react';

const ACTIVE_SESSIONS = [
  { id: 1, user: 'Alice Johnson', role: 'Owner', device: 'MacBook Pro (M2)', os: 'macOS Sonoma', browser: 'Chrome 120.0', ip: '192.168.1.45', location: 'New York, USA', time: 'Active now', isCurrent: true, icon: Laptop2 },
  { id: 2, user: 'Bob Smith', role: 'Admin', device: 'iPhone 14 Pro', os: 'iOS 17.1', browser: 'Safari Mobile', ip: '10.0.0.8', location: 'London, UK', time: 'Active 2m ago', isCurrent: false, icon: Smartphone },
  { id: 3, user: 'Charlie Davis', role: 'Dataset Manager', device: 'ThinkPad T14', os: 'Windows 11', browser: 'Edge 119.0', ip: '172.16.254.1', location: 'Toronto, CA', time: 'Active 1h ago', isCurrent: false, icon: Laptop2 },
];

const AUDIT_LOGS = [
  { id: 1, event: 'Successful Login', user: 'Alice Johnson', details: 'Authenticated via Passkey', time: '2 hours ago', status: 'success' },
  { id: 2, event: 'Failed Login Attempt', user: 'Unknown', details: 'Invalid password. IP: 45.33.22.11', time: '5 hours ago', status: 'danger' },
  { id: 3, event: '2FA Bypassed', user: 'Bob Smith', details: 'Used backup recovery code', time: '1 day ago', status: 'warning' },
  { id: 4, event: 'Password Changed', user: 'Charlie Davis', details: 'Password rotated successfully', time: '3 days ago', status: 'success' },
  { id: 5, event: 'Session Revoked', user: 'Alice Johnson', details: 'Revoked session for iPhone 13', time: '1 week ago', status: 'info' },
];

export default function SecurityCenterPage() {
  const [activeTab, setActiveTab] = useState<'overview' | 'sessions' | 'logs'>('overview');
  
  // Settings States
  const [require2FA, setRequire2FA] = useState(true);
  const [enablePasskeys, setEnablePasskeys] = useState(true);
  const [strictIP, setStrictIP] = useState(false);
  const [passwordRotation, setPasswordRotation] = useState('90');

  // Lockdown State
  const [isLockdownOpen, setIsLockdownOpen] = useState(false);
  const [lockdownConfirm, setLockdownConfirm] = useState('');

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'success': return 'text-emerald-400 bg-emerald-400/10 border-emerald-400/20';
      case 'danger': return 'text-red-400 bg-red-400/10 border-red-400/20';
      case 'warning': return 'text-amber-400 bg-amber-400/10 border-amber-400/20';
      case 'info': return 'text-blue-400 bg-blue-400/10 border-blue-400/20';
      default: return 'text-zinc-500 bg-zinc-400/10 border-zinc-400/20';
    }
  };

  return (
    <div className="min-h-screen bg-transparent text-zinc-900 p-4 md:p-8 font-sans selection:bg-purple-500/30 relative">
      <div className="max-w-[1600px] mx-auto space-y-8">
        
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 relative z-10">
          <div>
            <motion.div 
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-sm font-medium mb-4"
            >
              <ShieldCheck className="w-4 h-4" />
              Security Posture: Strong
            </motion.div>
            <motion.h1 
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="text-4xl md:text-5xl font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-zinc-900 via-zinc-700 to-zinc-500"
            >
              Security Center
            </motion.h1>
            <motion.p 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.1 }}
              className="text-zinc-500 mt-2 text-lg max-w-2xl"
            >
              Monitor threats, enforce authentication policies, and manage active organization sessions.
            </motion.p>
          </div>

          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="flex gap-3"
          >
            <button 
              onClick={() => setIsLockdownOpen(true)}
              className="group relative inline-flex items-center justify-center gap-2 px-6 py-3 font-bold text-red-50 bg-red-600 rounded-xl overflow-hidden transition-all hover:scale-105 shadow-[0_0_40px_-10px_rgba(220,38,38,0.5)] active:scale-95"
            >
              <TriangleAlert className="w-5 h-5 relative z-10" />
              <span className="relative z-10 tracking-wide">Emergency Lockdown</span>
            </button>
          </motion.div>
        </div>

        {/* Security Score Widget & Mini Stats */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <motion.div 
             initial={{ opacity: 0, y: 20 }}
             animate={{ opacity: 1, y: 0 }}
             className="col-span-1 lg:col-span-2 bg-gradient-to-br from-zinc-50 to-white border border-zinc-200 rounded-3xl p-8 flex flex-col md:flex-row items-center gap-10 shadow-lg relative overflow-hidden"
          >
            {/* Glow effect */}
            <div className="absolute top-0 right-0 w-64 h-64 bg-emerald-500/10 rounded-full blur-3xl -translate-y-1/2 translate-x-1/3 pointer-events-none"></div>

            <div className="relative shrink-0 flex items-center justify-center w-40 h-40">
              <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
                {/* Background circle */}
                <circle cx="50" cy="50" r="44" fill="transparent" stroke="#27272a" strokeWidth="8" />
                {/* Progress circle */}
                <circle 
                  cx="50" cy="50" r="44" 
                  fill="transparent" 
                  stroke="#34d399" 
                  strokeWidth="8" 
                  strokeDasharray="276" 
                  strokeDashoffset="22" 
                  strokeLinecap="round" 
                  className="drop-shadow-[0_0_12px_rgba(52,211,153,0.4)]"
                />
              </svg>
              <div className="absolute flex flex-col items-center justify-center">
                <span className="text-4xl font-black text-zinc-900">92</span>
                <span className="text-[10px] font-bold text-emerald-400 uppercase tracking-widest mt-1">Score</span>
              </div>
            </div>

            <div className="flex-1 space-y-4 text-center md:text-left">
              <div>
                <h3 className="text-2xl font-bold text-zinc-900 mb-2">Excellent Posture</h3>
                <p className="text-zinc-500 text-sm leading-relaxed">
                  Your organization has robust authentication policies in place. Enabling strict IP restrictions could raise your score to 98.
                </p>
              </div>
              <div className="flex flex-wrap items-center justify-center md:justify-start gap-3">
                <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-xs font-semibold">
                  <Check className="w-3.5 h-3.5" /> 2FA Enforced
                </span>
                <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-xs font-semibold">
                  <Check className="w-3.5 h-3.5" /> Passkeys Active
                </span>
                <span className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-amber-500/10 text-amber-400 border border-amber-500/20 text-xs font-semibold">
                  <AlertCircle className="w-3.5 h-3.5" /> No IP Blocks
                </span>
              </div>
            </div>
          </motion.div>

          <div className="col-span-1 grid grid-rows-2 gap-6">
            <motion.div 
               initial={{ opacity: 0, x: 20 }}
               animate={{ opacity: 1, x: 0 }}
               className="bg-white/50 border border-zinc-200 rounded-3xl p-6 flex flex-col justify-between backdrop-blur-xl hover:bg-white/80 transition-colors"
            >
              <div className="flex justify-between items-start">
                <div className="w-10 h-10 rounded-xl bg-purple-500/10 text-purple-400 flex items-center justify-center">
                  <Activity className="w-5 h-5" />
                </div>
                <span className="px-2 py-1 rounded text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">Normal</span>
              </div>
              <div>
                <h4 className="text-sm font-semibold text-zinc-500">Threat Detection</h4>
                <p className="text-2xl font-bold text-zinc-900 mt-1">0 <span className="text-sm font-medium text-zinc-500">Active Threats</span></p>
              </div>
            </motion.div>
            
            <motion.div 
               initial={{ opacity: 0, x: 20 }}
               animate={{ opacity: 1, x: 0 }}
               transition={{ delay: 0.1 }}
               className="bg-white/50 border border-zinc-200 rounded-3xl p-6 flex flex-col justify-between backdrop-blur-xl hover:bg-white/80 transition-colors"
            >
              <div className="flex justify-between items-start">
                <div className="w-10 h-10 rounded-xl bg-blue-500/10 text-blue-400 flex items-center justify-center">
                  <Laptop2 className="w-5 h-5" />
                </div>
                <button className="text-xs text-blue-400 font-semibold hover:underline">View All</button>
              </div>
              <div>
                <h4 className="text-sm font-semibold text-zinc-500">Active Sessions</h4>
                <p className="text-2xl font-bold text-zinc-900 mt-1">12 <span className="text-sm font-medium text-zinc-500">Across 3 Regions</span></p>
              </div>
            </motion.div>
          </div>
        </div>

        {/* Main Content Area */}
        <div className="bg-white/50 border border-zinc-200 rounded-3xl overflow-hidden backdrop-blur-xl">
          
          {/* Tabs */}
          <div className="flex border-b border-zinc-200 px-4 md:px-8 bg-white/50">
            {[
              { id: 'overview', label: 'Access Policies', icon: Lock },
              { id: 'sessions', label: 'Active Sessions', icon: Globe },
              { id: 'logs', label: 'Audit Logs', icon: Activity },
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`flex items-center gap-2 px-6 py-5 font-medium text-sm relative transition-colors ${activeTab === tab.id ? 'text-zinc-900' : 'text-zinc-500 hover:text-zinc-800'}`}
              >
                <tab.icon className="w-4 h-4" />
                {tab.label}
                {activeTab === tab.id && (
                  <motion.div layoutId="sec-tab-indicator" className="absolute bottom-0 left-0 right-0 h-0.5 bg-emerald-500" />
                )}
              </button>
            ))}
          </div>

          <div className="p-4 md:p-8 min-h-[500px]">
            <AnimatePresence mode="wait">
              
              {/* ACCESS POLICIES TAB */}
              {activeTab === 'overview' && (
                <motion.div
                  key="overview"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="max-w-4xl space-y-8"
                >
                  
                  {/* Authentication Methods */}
                  <section>
                    <h2 className="text-lg font-bold text-zinc-900 mb-4">Authentication Methods</h2>
                    <div className="bg-white/50 border border-zinc-200 rounded-2xl divide-y divide-zinc-800">
                      
                      <div className="p-5 flex items-center justify-between">
                        <div className="flex gap-4">
                          <div className="w-10 h-10 rounded-xl bg-zinc-50 border border-zinc-200 flex items-center justify-center shrink-0">
                            <Key className="w-5 h-5 text-zinc-600" />
                          </div>
                          <div>
                            <h4 className="text-zinc-900 font-medium text-sm">Two-Factor Authentication (2FA)</h4>
                            <p className="text-zinc-500 text-xs mt-1 max-w-sm">Require all organization members to configure 2FA using an authenticator app (TOTP) or SMS.</p>
                          </div>
                        </div>
                        <Switch checked={require2FA} onChange={() => setRequire2FA(!require2FA)} />
                      </div>

                      <div className="p-5 flex items-center justify-between">
                        <div className="flex gap-4">
                          <div className="w-10 h-10 rounded-xl bg-zinc-50 border border-zinc-200 flex items-center justify-center shrink-0">
                            <Fingerprint className="w-5 h-5 text-zinc-600" />
                          </div>
                          <div>
                            <h4 className="text-zinc-900 font-medium text-sm">Passkeys (WebAuthn)</h4>
                            <p className="text-zinc-500 text-xs mt-1 max-w-sm">Allow users to authenticate securely without a password using TouchID, FaceID, or security keys.</p>
                          </div>
                        </div>
                        <Switch checked={enablePasskeys} onChange={() => setEnablePasskeys(!enablePasskeys)} />
                      </div>

                    </div>
                  </section>

                  {/* Network Restrictions */}
                  <section>
                    <h2 className="text-lg font-bold text-zinc-900 mb-4">Network & Password Policies</h2>
                    <div className="bg-white/50 border border-zinc-200 rounded-2xl divide-y divide-zinc-800">
                      
                      <div className="p-5">
                        <div className="flex items-center justify-between mb-4">
                          <div>
                            <h4 className="text-zinc-900 font-medium text-sm">Strict IP Allowance</h4>
                            <p className="text-zinc-500 text-xs mt-1">Restrict access to the portal to specific IP addresses or CIDR ranges.</p>
                          </div>
                          <Switch checked={strictIP} onChange={() => setStrictIP(!strictIP)} />
                        </div>
                        {strictIP && (
                          <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} className="mt-4">
                            <textarea 
                              placeholder="e.g. 192.168.1.0/24&#10;10.0.0.1" 
                              className="w-full bg-zinc-50 border border-zinc-200 rounded-xl p-3 text-sm text-zinc-900 focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500 focus:outline-none resize-none h-24 font-mono"
                            />
                            <p className="text-xs text-amber-500 mt-2 flex items-center gap-1.5"><TriangleAlert className="w-3.5 h-3.5"/> Warning: You may lock yourself out if you enter incorrect ranges.</p>
                          </motion.div>
                        )}
                      </div>

                      <div className="p-5 flex items-center justify-between">
                        <div>
                          <h4 className="text-zinc-900 font-medium text-sm">Password Rotation</h4>
                          <p className="text-zinc-500 text-xs mt-1">Force members to update their passwords periodically.</p>
                        </div>
                        <select 
                          value={passwordRotation} 
                          onChange={(e) => setPasswordRotation(e.target.value)}
                          className="bg-zinc-50 border border-zinc-200 text-zinc-900 text-sm rounded-lg px-4 py-2 focus:ring-1 focus:ring-emerald-500 focus:border-emerald-500 focus:outline-none cursor-pointer"
                        >
                          <option value="never">Never (Not recommended)</option>
                          <option value="30">Every 30 Days</option>
                          <option value="90">Every 90 Days</option>
                          <option value="180">Every 180 Days</option>
                        </select>
                      </div>

                    </div>
                  </section>

                </motion.div>
              )}

              {/* ACTIVE SESSIONS TAB */}
              {activeTab === 'sessions' && (
                <motion.div
                  key="sessions"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-6"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <h2 className="text-lg font-bold text-zinc-900">Active Sessions</h2>
                      <p className="text-zinc-500 text-sm mt-1">View and manage all active logins across your organization.</p>
                    </div>
                    <button className="flex items-center gap-2 px-4 py-2 bg-white border border-zinc-200 rounded-xl text-sm font-medium text-red-400 hover:bg-zinc-50 hover:text-red-300 transition-colors">
                      <PowerOff className="w-4 h-4" /> Revoke All Other Sessions
                    </button>
                  </div>

                  <div className="grid gap-4">
                    {ACTIVE_SESSIONS.map((session) => (
                      <div key={session.id} className="flex flex-col md:flex-row md:items-center justify-between p-5 rounded-2xl border border-zinc-200 bg-white/50 hover:border-zinc-200 transition-colors gap-4">
                        <div className="flex gap-4 items-start">
                          <div className="w-12 h-12 rounded-xl bg-zinc-50 border border-zinc-200 flex items-center justify-center shrink-0">
                            <session.icon className="w-6 h-6 text-zinc-500" />
                          </div>
                          <div>
                            <div className="flex items-center gap-3 mb-1">
                              <h3 className="font-bold text-zinc-900">{session.device}</h3>
                              {session.isCurrent && (
                                <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-500/20 text-emerald-400 uppercase tracking-wider">Current Session</span>
                              )}
                            </div>
                            <p className="text-sm text-zinc-500 font-medium">{session.user} <span className="text-zinc-600 mx-1">•</span> {session.role}</p>
                            <div className="flex flex-wrap items-center gap-x-4 gap-y-2 mt-3 text-xs font-medium text-zinc-500">
                              <span className="flex items-center gap-1.5"><Globe className="w-3.5 h-3.5 text-zinc-500" /> {session.location}</span>
                              <span className="flex items-center gap-1.5"><Activity className="w-3.5 h-3.5 text-zinc-500" /> {session.ip}</span>
                              <span className="flex items-center gap-1.5"><Clock className="w-3.5 h-3.5 text-zinc-500" /> {session.time}</span>
                            </div>
                          </div>
                        </div>
                        
                        {!session.isCurrent && (
                          <button className="flex items-center justify-center w-full md:w-auto px-4 py-2 border border-zinc-200 text-zinc-600 rounded-lg text-sm font-medium hover:bg-red-500/10 hover:text-red-400 hover:border-red-500/30 transition-colors">
                            Revoke
                          </button>
                        )}
                      </div>
                    ))}
                  </div>
                </motion.div>
              )}

              {/* AUDIT LOGS TAB */}
              {activeTab === 'logs' && (
                <motion.div
                  key="logs"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-4"
                >
                  <div className="flex items-center gap-4 mb-6">
                    <div className="relative flex-1">
                      <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-500" />
                      <input 
                        type="text" 
                        placeholder="Search logs by user, IP, or event..."
                        className="w-full pl-10 pr-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 transition-all text-zinc-900 placeholder-zinc-500"
                      />
                    </div>
                    <button className="px-4 py-2.5 bg-white border border-zinc-200 rounded-xl text-sm text-zinc-600 hover:bg-zinc-100 transition-colors flex items-center gap-2 font-medium">
                      <RefreshCw className="w-4 h-4" /> Refresh
                    </button>
                  </div>

                  <div className="rounded-2xl overflow-hidden border border-zinc-200 bg-white/80 backdrop-blur-xl">
                    <div className="flex items-center px-6 py-4 border-b border-zinc-200 text-xs text-zinc-500 uppercase tracking-wider font-bold">
                      <div className="w-1/4">Event</div>
                      <div className="w-1/4">User</div>
                      <div className="flex-1">Details</div>
                      <div className="w-32 text-right">Time</div>
                    </div>
                    
                    <div className="divide-y divide-zinc-800/50">
                      {AUDIT_LOGS.map(log => (
                        <div key={log.id} className="flex items-center px-6 py-4 hover:bg-white/50 transition-colors">
                          <div className="w-1/4">
                            <span className={`px-2.5 py-1 rounded-md text-[11px] font-bold border ${getStatusColor(log.status)}`}>
                              {log.event}
                            </span>
                          </div>
                          <div className="w-1/4 font-semibold text-sm text-zinc-600">
                            {log.user}
                          </div>
                          <div className="flex-1 text-zinc-500 text-sm">
                            {log.details}
                          </div>
                          <div className="w-32 text-right text-zinc-500 text-xs font-mono">
                            {log.time}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </motion.div>
              )}

            </AnimatePresence>
          </div>
        </div>
      </div>

      {/* Emergency Lockdown Modal */}
      <AnimatePresence>
        {isLockdownOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-red-950/40 backdrop-blur-md z-40"
              onClick={() => setIsLockdownOpen(false)}
            />
            <motion.div 
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md bg-white border border-red-500/30 rounded-2xl z-50 p-6 sm:p-8 shadow-2xl shadow-red-900/20"
            >
              <div className="flex flex-col items-center text-center space-y-4 mb-6">
                <div className="w-16 h-16 rounded-full bg-red-500/10 flex items-center justify-center border border-red-500/20 mb-2">
                  <ShieldAlert className="w-8 h-8 text-red-500" />
                </div>
                <h2 className="text-2xl font-bold text-zinc-900">Emergency Lockdown</h2>
                <p className="text-zinc-500 text-sm">
                  This action will instantly revoke all active sessions (including yours), disable API keys, and force password resets for all users upon next login.
                </p>
              </div>

              <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-4 mb-6 text-sm text-red-200">
                To confirm, type <strong className="text-zinc-900 font-mono bg-red-500/20 px-1 py-0.5 rounded">LOCKDOWN</strong> below.
              </div>

              <input 
                type="text"
                placeholder="LOCKDOWN"
                value={lockdownConfirm}
                onChange={(e) => setLockdownConfirm(e.target.value)}
                className="w-full px-4 py-3 bg-zinc-50 border border-red-500/30 rounded-xl text-center font-mono font-bold text-zinc-900 focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500 mb-6"
              />

              <div className="flex gap-3">
                <button 
                  onClick={() => { setIsLockdownOpen(false); setLockdownConfirm(''); }}
                  className="flex-1 py-3 rounded-xl border border-zinc-200 text-zinc-600 font-bold hover:bg-zinc-100 transition-colors"
                >
                  Cancel
                </button>
                <button 
                  disabled={lockdownConfirm !== 'LOCKDOWN'}
                  className="flex-1 py-3 rounded-xl bg-red-600 text-white font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed hover:bg-red-500 hover:shadow-[0_0_20px_-5px_rgba(220,38,38,0.5)]"
                >
                  Initiate Lockdown
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}

// Simple Switch Component Helper
function Switch({ checked, onChange }: { checked: boolean, onChange: () => void }) {
  return (
    <button 
      onClick={onChange}
      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-2 focus:ring-offset-zinc-900 ${checked ? 'bg-emerald-500' : 'bg-zinc-700'}`}
    >
      <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${checked ? 'translate-x-6' : 'translate-x-1'}`} />
    </button>
  );
}

// Check Icon Helper
function Check(props: any) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" {...props}>
      <polyline points="20 6 9 17 4 12" />
    </svg>
  );
}
