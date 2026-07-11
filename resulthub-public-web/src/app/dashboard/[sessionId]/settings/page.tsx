"use client";

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Settings2, 
  Building2, 
  Bell, 
  CreditCard, 
  Upload, 
  AlertTriangle, 
  MessageSquare, 
  Mail, 
  Zap, 
  Download, 
  FileText,
  Check
} from 'lucide-react';

const TABS = [
  { id: 'general', label: 'General Profile', icon: Building2 },
  { id: 'notifications', label: 'Notifications', icon: Bell },
  { id: 'billing', label: 'Billing & Plans', icon: CreditCard },
];

const INVOICE_HISTORY = [
  { id: 'INV-2026-06', date: 'Jun 01, 2026', amount: '$499.00', status: 'Paid' },
  { id: 'INV-2026-05', date: 'May 01, 2026', amount: '$499.00', status: 'Paid' },
  { id: 'INV-2026-04', date: 'Apr 01, 2026', amount: '$499.00', status: 'Paid' },
];

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState('general');

  return (
    <div className="min-h-screen bg-transparent text-zinc-900 p-4 md:p-8 font-sans selection:bg-purple-500/30 overflow-hidden">
      <div className="max-w-[1400px] mx-auto space-y-8">
        
        {/* Header */}
        <div className="relative z-10">
          <motion.div 
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-zinc-100 border border-zinc-200 text-zinc-600 text-sm font-medium mb-4"
          >
            <Settings2 className="w-4 h-4" />
            Global Configuration
          </motion.div>
          <motion.h1 
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            className="text-4xl md:text-5xl font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-zinc-900 via-zinc-700 to-zinc-500"
          >
            Organization Settings
          </motion.h1>
          <motion.p 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.1 }}
            className="text-zinc-500 mt-2 text-lg max-w-2xl"
          >
            Manage your brand identity, set notification policies, and review billing details.
          </motion.p>
        </div>

        <div className="flex flex-col md:flex-row gap-8">
          
          {/* Vertical Sidebar */}
          <motion.div 
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
            className="w-full md:w-64 shrink-0 flex flex-col gap-2"
          >
            {TABS.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-3 w-full px-4 py-3 rounded-xl font-bold transition-all relative ${
                  activeTab === tab.id 
                    ? 'bg-zinc-50 text-zinc-900 border border-zinc-200 shadow-sm' 
                    : 'text-zinc-500 hover:text-zinc-800 hover:bg-white/50'
                }`}
              >
                <tab.icon className={`w-5 h-5 ${activeTab === tab.id ? 'text-indigo-400' : 'text-zinc-500'}`} />
                {tab.label}
                {activeTab === tab.id && (
                  <motion.div layoutId="settings-active-tab" className="absolute left-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-indigo-500 rounded-r-full" />
                )}
              </button>
            ))}
          </motion.div>

          {/* Main Content Area */}
          <div className="flex-1 bg-white/50 border border-zinc-200 rounded-3xl p-6 md:p-10 backdrop-blur-xl min-h-[600px]">
            <AnimatePresence mode="wait">
              
              {/* GENERAL TAB */}
              {activeTab === 'general' && (
                <motion.div
                  key="general"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-10 max-w-2xl"
                >
                  <div>
                    <h2 className="text-xl font-bold text-zinc-900 mb-6">General Profile</h2>
                    
                    <div className="space-y-6">
                      <div className="flex items-center gap-6">
                        <div className="w-24 h-24 rounded-2xl bg-white border border-zinc-200 flex flex-col items-center justify-center text-zinc-500 hover:border-indigo-500 hover:text-indigo-400 transition-colors cursor-pointer group">
                          <Upload className="w-6 h-6 mb-2 group-hover:-translate-y-1 transition-transform" />
                          <span className="text-xs font-bold uppercase tracking-wider">Logo</span>
                        </div>
                        <div className="flex-1">
                          <p className="text-sm text-zinc-500 mb-2">Upload your organization logo. Recommended size: 256x256px.</p>
                          <button className="px-4 py-2 bg-zinc-100 hover:bg-zinc-700 rounded-lg text-sm font-bold text-zinc-900 transition-colors">
                            Choose File
                          </button>
                        </div>
                      </div>

                      <div className="space-y-2">
                        <label className="text-sm font-bold text-zinc-600">Organization Name</label>
                        <input 
                          type="text" 
                          defaultValue="Stanford University"
                          className="w-full bg-white border border-zinc-200 rounded-xl px-4 py-3 text-zinc-900 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all"
                        />
                      </div>

                      <div className="space-y-2">
                        <label className="text-sm font-bold text-zinc-600">Public Subdomain</label>
                        <div className="flex relative">
                          <input 
                            type="text" 
                            defaultValue="stanford"
                            className="w-full bg-white border border-zinc-200 rounded-xl pl-4 pr-36 py-3 text-zinc-900 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all font-mono"
                          />
                          <div className="absolute right-0 top-0 bottom-0 px-4 bg-zinc-50 border-l border-zinc-200 rounded-r-xl flex items-center text-zinc-500 font-mono text-sm pointer-events-none">
                            .resulthub.com
                          </div>
                        </div>
                      </div>

                      <div className="space-y-2">
                        <label className="text-sm font-bold text-zinc-600">Support Email</label>
                        <input 
                          type="email" 
                          defaultValue="support@stanford.edu"
                          className="w-full bg-white border border-zinc-200 rounded-xl px-4 py-3 text-zinc-900 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 transition-all"
                        />
                      </div>
                    </div>
                  </div>

                  <div className="pt-8 border-t border-zinc-200">
                    <h3 className="text-lg font-bold text-red-500 mb-4 flex items-center gap-2"><AlertTriangle className="w-5 h-5"/> Danger Zone</h3>
                    <div className="p-6 border border-red-500/30 bg-red-500/5 rounded-2xl space-y-4">
                      <div className="flex items-center justify-between">
                        <div>
                          <h4 className="font-bold text-zinc-900 text-sm">Transfer Ownership</h4>
                          <p className="text-zinc-500 text-xs mt-1">Transfer this organization to another user.</p>
                        </div>
                        <button className="px-4 py-2 border border-zinc-200 text-zinc-600 rounded-lg text-sm font-bold hover:bg-zinc-100 transition-colors">Transfer</button>
                      </div>
                      <div className="h-px w-full bg-red-500/20" />
                      <div className="flex items-center justify-between">
                        <div>
                          <h4 className="font-bold text-zinc-900 text-sm">Delete Organization</h4>
                          <p className="text-red-400/80 text-xs mt-1">Permanently delete all data, datasets, and logs.</p>
                        </div>
                        <button className="px-4 py-2 bg-red-600 hover:bg-red-500 text-zinc-900 rounded-lg text-sm font-bold transition-colors">Delete</button>
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}

              {/* NOTIFICATIONS TAB */}
              {activeTab === 'notifications' && (
                <motion.div
                  key="notifications"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-10 max-w-2xl"
                >
                  <div>
                    <h2 className="text-xl font-bold text-zinc-900 mb-6">Notification Policies</h2>
                    
                    <div className="space-y-4">
                      {[
                        { title: 'Dataset Publications', desc: 'Alert when a new public dataset goes live.', icon: FileText, active: true },
                        { title: 'Critical Complaints', desc: 'Immediate alert for priority civic issues.', icon: AlertTriangle, active: true },
                        { title: 'Billing Alerts', desc: 'Notifications regarding invoices or usage limits.', icon: CreditCard, active: false },
                        { title: 'Weekly Reports', desc: 'Summary of analytics and traffic sent every Monday.', icon: Zap, active: true },
                      ].map((item, i) => (
                        <div key={i} className="flex items-center justify-between p-4 bg-white border border-zinc-200 rounded-xl">
                          <div className="flex gap-4">
                            <div className="mt-0.5"><item.icon className="w-5 h-5 text-zinc-500" /></div>
                            <div>
                              <h4 className="text-sm font-bold text-zinc-900">{item.title}</h4>
                              <p className="text-xs text-zinc-500 mt-1">{item.desc}</p>
                            </div>
                          </div>
                          <Switch checked={item.active} />
                        </div>
                      ))}
                    </div>
                  </div>

                  <div className="pt-8 border-t border-zinc-200">
                    <h3 className="text-lg font-bold text-zinc-900 mb-4">Integrations</h3>
                    <div className="space-y-4">
                      <div className="flex items-center justify-between p-5 bg-white border border-zinc-200 rounded-2xl">
                        <div className="flex items-center gap-4">
                          <div className="w-12 h-12 rounded-xl bg-[#4A154B] flex items-center justify-center">
                            <MessageSquare className="w-6 h-6 text-zinc-900" />
                          </div>
                          <div>
                            <h4 className="font-bold text-zinc-900">Slack Workspace</h4>
                            <p className="text-xs text-zinc-500 mt-1">Send alerts directly to a designated Slack channel.</p>
                          </div>
                        </div>
                        <button className="px-4 py-2 bg-zinc-100 hover:bg-zinc-700 text-zinc-900 rounded-lg text-sm font-bold transition-colors">Connect</button>
                      </div>
                       <div className="flex items-center justify-between p-5 bg-white border border-zinc-200 rounded-2xl">
                        <div className="flex items-center gap-4">
                          <div className="w-12 h-12 rounded-xl bg-blue-600 flex items-center justify-center">
                            <Mail className="w-6 h-6 text-zinc-900" />
                          </div>
                          <div>
                            <h4 className="font-bold text-zinc-900">Email Webhooks</h4>
                            <p className="text-xs text-zinc-500 mt-1">Trigger automated email flows for critical events.</p>
                          </div>
                        </div>
                        <button className="px-4 py-2 border border-zinc-200 text-zinc-600 rounded-lg text-sm font-bold hover:bg-zinc-100 transition-colors">Configure</button>
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}

              {/* BILLING TAB */}
              {activeTab === 'billing' && (
                <motion.div
                  key="billing"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-10"
                >
                  <div className="flex justify-between items-start">
                    <div>
                      <h2 className="text-xl font-bold text-zinc-900 mb-1">Billing & Subscription</h2>
                      <p className="text-zinc-500 text-sm">Manage your plan and review usage.</p>
                    </div>
                    <button className="px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-zinc-900 rounded-lg text-sm font-bold transition-colors shadow-lg shadow-indigo-500/20">
                      Upgrade Plan
                    </button>
                  </div>
                  
                  <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Current Plan */}
                    <div className="bg-gradient-to-br from-indigo-50 to-white border border-indigo-100 rounded-3xl p-6 md:p-8 relative overflow-hidden">
                      <div className="absolute top-0 right-0 w-32 h-32 bg-indigo-500/20 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 pointer-events-none" />
                      <div className="relative z-10">
                        <span className="px-3 py-1 bg-indigo-500 text-zinc-900 text-[10px] font-black uppercase tracking-widest rounded-full mb-4 inline-block">Current Plan</span>
                        <h3 className="text-3xl font-black text-zinc-900 mb-2">Enterprise</h3>
                        <p className="text-indigo-200/80 text-sm mb-6">Billed $4,990 annually.</p>
                        
                        <div className="space-y-3">
                          {['Unlimited Datasets', 'Priority SLA Support', 'Advanced Analytics', 'SSO Enabled'].map((feature, i) => (
                            <div key={i} className="flex items-center gap-2 text-sm text-zinc-600">
                              <Check className="w-4 h-4 text-indigo-400" /> {feature}
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>

                    {/* Usage & Limits */}
                    <div className="bg-white border border-zinc-200 rounded-3xl p-6 md:p-8 flex flex-col justify-center">
                      <h3 className="text-sm font-bold text-zinc-500 uppercase tracking-wider mb-6">Current Usage (This Month)</h3>
                      
                      <div className="space-y-6">
                        <div>
                          <div className="flex justify-between text-sm mb-2">
                            <span className="font-bold text-zinc-900">Bandwidth</span>
                            <span className="text-zinc-500 font-mono">2.4 TB / 5 TB</span>
                          </div>
                          <div className="h-2 w-full bg-zinc-50 rounded-full overflow-hidden border border-zinc-200">
                            <div className="h-full bg-blue-500 w-[48%] rounded-full shadow-[0_0_10px_rgba(59,130,246,0.5)]" />
                          </div>
                        </div>

                        <div>
                          <div className="flex justify-between text-sm mb-2">
                            <span className="font-bold text-zinc-900">Active Datasets</span>
                            <span className="text-zinc-500 font-mono">142 / ∞</span>
                          </div>
                          <div className="h-2 w-full bg-zinc-50 rounded-full overflow-hidden border border-zinc-200">
                            <div className="h-full bg-emerald-500 w-[100%] rounded-full shadow-[0_0_10px_rgba(16,185,129,0.5)]" />
                          </div>
                        </div>

                         <div>
                          <div className="flex justify-between text-sm mb-2">
                            <span className="font-bold text-zinc-900">API Requests</span>
                            <span className="text-zinc-500 font-mono">8.2M / 10M</span>
                          </div>
                          <div className="h-2 w-full bg-zinc-50 rounded-full overflow-hidden border border-zinc-200">
                            <div className="h-full bg-amber-500 w-[82%] rounded-full shadow-[0_0_10px_rgba(245,158,11,0.5)]" />
                          </div>
                          <p className="text-xs text-amber-500 mt-2">Approaching limit. Consider upgrading if trend continues.</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div className="pt-4">
                    <h3 className="text-lg font-bold text-zinc-900 mb-4">Invoice History</h3>
                    <div className="bg-white border border-zinc-200 rounded-2xl overflow-hidden">
                      <table className="w-full text-left">
                        <thead>
                          <tr className="border-b border-zinc-200 text-xs uppercase tracking-wider text-zinc-500 font-semibold bg-white/50">
                            <th className="py-3 px-6">Invoice</th>
                            <th className="py-3 px-6">Date</th>
                            <th className="py-3 px-6">Amount</th>
                            <th className="py-3 px-6">Status</th>
                            <th className="py-3 px-6 text-right">Receipt</th>
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-zinc-800">
                          {INVOICE_HISTORY.map((inv) => (
                            <tr key={inv.id} className="hover:bg-zinc-50/30 transition-colors">
                              <td className="py-4 px-6 text-sm font-bold text-zinc-900">{inv.id}</td>
                              <td className="py-4 px-6 text-sm text-zinc-500">{inv.date}</td>
                              <td className="py-4 px-6 text-sm font-mono text-zinc-600">{inv.amount}</td>
                              <td className="py-4 px-6">
                                <span className="px-2.5 py-1 rounded-md text-[11px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 uppercase tracking-wider">
                                  {inv.status}
                                </span>
                              </td>
                              <td className="py-4 px-6 text-right">
                                <button className="p-2 text-zinc-500 hover:text-zinc-900 bg-zinc-50 border border-zinc-200 rounded-lg transition-colors">
                                  <Download className="w-4 h-4" />
                                </button>
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>

                </motion.div>
              )}

            </AnimatePresence>
          </div>
        </div>
      </div>
    </div>
  );
}

// Simple Switch Component for Notifications
function Switch({ checked = false }) {
  const [isOn, setIsOn] = useState(checked);
  return (
    <button 
      onClick={() => setIsOn(!isOn)}
      className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 focus:ring-offset-zinc-900 ${isOn ? 'bg-indigo-500' : 'bg-zinc-700'}`}
    >
      <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${isOn ? 'translate-x-6' : 'translate-x-1'}`} />
    </button>
  );
}
