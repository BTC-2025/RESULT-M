"use client";

import React, { useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Terminal, 
  Key, 
  Webhook, 
  Activity, 
  Copy, 
  Check, 
  Eye, 
  EyeOff, 
  Plus, 
  Trash2, 
  X, 
  Search, 
  ShieldAlert, 
  ArrowRightLeft, 
  DatabaseZap, 
  Clock, 
  FileCode2,
  Lock
} from 'lucide-react';

const API_KEYS = [
  { id: '1', name: 'Production Backend', keyPrefix: 'rh_prod_', keySuffix: 'x9F2', scopes: ['Full Access'], lastUsed: '2 mins ago', created: '2023-10-15' },
  { id: '2', name: 'Staging Environment', keyPrefix: 'rh_test_', keySuffix: 'p0m1', scopes: ['Read Only'], lastUsed: '3 days ago', created: '2024-01-22' },
];

const WEBHOOKS = [
  { id: 'wh_1', url: 'https://api.myapp.com/webhooks/resulthub', events: ['record.created', 'record.updated'], status: 'Active', lastTriggered: '1 hour ago' },
  { id: 'wh_2', url: 'https://staging.myapp.com/sync', events: ['dataset.published'], status: 'Failing', lastTriggered: '2 days ago' },
];

const LOGS = [
  { id: 'req_1', method: 'POST', endpoint: '/v1/records', status: 201, latency: '142ms', time: '10:42:15 AM', body: '{"dataset":"student_data","fields":{...}}' },
  { id: 'req_2', method: 'GET', endpoint: '/v1/datasets/ds_a1b2', status: 200, latency: '45ms', time: '10:41:03 AM', body: null },
  { id: 'req_3', method: 'PATCH', endpoint: '/v1/records/rec_88x', status: 403, latency: '21ms', time: '10:39:55 AM', body: '{"error":"Insufficient scope"}' },
  { id: 'req_4', method: 'POST', endpoint: '/v1/webhooks/wh_2/test', status: 500, latency: '2050ms', time: '09:15:22 AM', body: '{"error":"Timeout waiting for response"}' },
  { id: 'req_5', method: 'GET', endpoint: '/v1/users/me', status: 200, latency: '33ms', time: '08:05:10 AM', body: null },
];

export default function DevelopersPage() {
  const params = useParams();
  const [activeTab, setActiveTab] = useState<'keys' | 'webhooks' | 'logs'>('keys');
  
  // Modals state
  const [isKeyModalOpen, setIsKeyModalOpen] = useState(false);
  const [isWebhookModalOpen, setIsWebhookModalOpen] = useState(false);
  
  // Interaction states
  const [copiedKey, setCopiedKey] = useState<string | null>(null);
  const [revealedKey, setRevealedKey] = useState<string | null>(null);

  const handleCopy = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedKey(id);
    setTimeout(() => setCopiedKey(null), 2000);
  };

  const getStatusColor = (status: number | string) => {
    if (typeof status === 'number') {
      if (status >= 200 && status < 300) return 'text-emerald-400 bg-emerald-400/10 border-emerald-400/20';
      if (status >= 400 && status < 500) return 'text-amber-400 bg-amber-400/10 border-amber-400/20';
      return 'text-red-400 bg-red-400/10 border-red-400/20';
    } else {
      if (status === 'Active') return 'text-emerald-400 bg-emerald-400/10 border-emerald-400/20';
      return 'text-red-400 bg-red-400/10 border-red-400/20';
    }
  };

  const getMethodColor = (method: string) => {
    switch (method) {
      case 'GET': return 'text-blue-400';
      case 'POST': return 'text-emerald-400';
      case 'PATCH': return 'text-amber-400';
      case 'DELETE': return 'text-red-400';
      default: return 'text-zinc-500';
    }
  };

  return (
    <div className="min-h-screen bg-transparent text-zinc-900 p-4 md:p-8 font-sans selection:bg-purple-500/30">
      <div className="max-w-[1600px] mx-auto space-y-8">
        
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 relative z-10">
          <div>
            <div className="flex items-center gap-2 text-zinc-400 text-xs font-semibold select-none mb-2">
              <Link href={`/dashboard/${params.sessionId}/datasets`} className="hover:text-zinc-600 transition-colors">Datasets</Link>
              <span>/</span>
              <span className="text-purple-500 font-medium">API & Webhooks</span>
            </div>
            <motion.div 
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-purple-500/10 border border-purple-500/20 text-purple-400 text-sm font-medium mb-4"
            >
              <Terminal className="w-4 h-4" />
              API v1 Active
            </motion.div>
            <motion.h1 
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="text-4xl md:text-5xl font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-zinc-900 via-zinc-700 to-zinc-500"
            >
              Developers
            </motion.h1>
            <motion.p 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.1 }}
              className="text-zinc-500 mt-2 text-lg max-w-2xl"
            >
              Manage API keys, configure webhooks, and monitor integration traffic in real-time.
            </motion.p>
          </div>

          <motion.div 
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            className="flex gap-3"
          >
            <button className="px-5 py-2.5 font-medium text-zinc-900 bg-zinc-50 border border-zinc-200 rounded-xl hover:bg-zinc-100 transition-colors flex items-center gap-2">
              <FileCode2 className="w-4 h-4" />
              API Docs
            </button>
            <button 
              onClick={() => activeTab === 'webhooks' ? setIsWebhookModalOpen(true) : setIsKeyModalOpen(true)}
              className="group relative inline-flex items-center justify-center gap-2 px-6 py-2.5 font-semibold text-zinc-900 bg-gradient-to-b from-purple-500 to-purple-600 rounded-xl overflow-hidden transition-all hover:scale-105 hover:shadow-[0_0_40px_-10px_rgba(168,85,247,0.5)] active:scale-95"
            >
              <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out" />
              <Plus className="w-5 h-5 relative z-10" />
              <span className="relative z-10">{activeTab === 'webhooks' ? 'Add Webhook' : 'Generate Key'}</span>
            </button>
          </motion.div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 md:gap-6">
          {[
            { label: 'API Requests (30d)', value: '1.2M', icon: ArrowRightLeft, color: 'text-blue-400', bg: 'bg-blue-400/10' },
            { label: 'Avg Latency', value: '45ms', icon: Clock, color: 'text-purple-400', bg: 'bg-purple-400/10' },
            { label: 'Active Webhooks', value: '2', icon: Webhook, color: 'text-emerald-400', bg: 'bg-emerald-400/10' },
            { label: 'Error Rate', value: '0.04%', icon: ShieldAlert, color: 'text-amber-400', bg: 'bg-amber-400/10' },
          ].map((stat, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              className="p-6 rounded-2xl bg-white/50 border border-zinc-200 backdrop-blur-xl flex items-center gap-5 hover:bg-zinc-100/50 transition-colors"
            >
              <div className={`p-4 rounded-xl ${stat.bg} ${stat.color}`}>
                <stat.icon className="w-6 h-6" />
              </div>
              <div>
                <p className="text-zinc-500 text-sm font-medium">{stat.label}</p>
                <p className="text-2xl font-bold text-zinc-900 mt-1">{stat.value}</p>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Main Content */}
        <div className="bg-white/50 border border-zinc-200 rounded-2xl overflow-hidden backdrop-blur-xl">
          
          {/* Tabs */}
          <div className="flex border-b border-zinc-200 px-4 md:px-8 bg-white/50">
            {[
              { id: 'keys', label: 'API Keys', icon: Key },
              { id: 'webhooks', label: 'Webhooks', icon: Webhook },
              { id: 'logs', label: 'Request Logs', icon: Terminal },
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`flex items-center gap-2 px-6 py-5 font-medium text-sm relative transition-colors ${activeTab === tab.id ? 'text-zinc-900' : 'text-zinc-500 hover:text-zinc-800'}`}
              >
                <tab.icon className="w-4 h-4" />
                {tab.label}
                {activeTab === tab.id && (
                  <motion.div layoutId="dev-tab-indicator" className="absolute bottom-0 left-0 right-0 h-0.5 bg-purple-500" />
                )}
              </button>
            ))}
          </div>

          <div className="p-4 md:p-8">
            <AnimatePresence mode="wait">
              
              {/* API KEYS TAB */}
              {activeTab === 'keys' && (
                <motion.div
                  key="keys"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-6"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <h2 className="text-lg font-semibold text-zinc-900">Secret API Keys</h2>
                      <p className="text-zinc-500 text-sm mt-1">Do not share your API keys in publicly accessible areas such as GitHub or client-side code.</p>
                    </div>
                  </div>

                  <div className="grid gap-4">
                    {API_KEYS.map(key => (
                      <div key={key.id} className="flex flex-col md:flex-row md:items-center justify-between p-5 rounded-xl border border-zinc-200 bg-white/50 hover:border-zinc-200 transition-colors gap-4">
                        <div>
                          <div className="flex items-center gap-3">
                            <h3 className="font-medium text-zinc-900">{key.name}</h3>
                            {key.scopes.map(s => (
                              <span key={s} className="px-2 py-0.5 rounded text-[10px] font-medium bg-purple-500/10 text-purple-400 border border-purple-500/20 uppercase tracking-wider">
                                {s}
                              </span>
                            ))}
                          </div>
                          <p className="text-xs text-zinc-500 mt-1">Created on {key.created} • Last used {key.lastUsed}</p>
                        </div>
                        
                        <div className="flex items-center gap-3">
                          <div className="flex items-center gap-2 px-4 py-2 bg-zinc-50 border border-zinc-200 rounded-lg font-mono text-sm text-zinc-600">
                            <span>{key.keyPrefix}</span>
                            <span className="text-zinc-500 select-none">••••••••••••••••</span>
                            <span>{key.keySuffix}</span>
                          </div>
                          <button className="p-2 text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100 rounded-lg transition-colors">
                            <Trash2 className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="pt-8 mt-4 border-t border-zinc-200/60">
                    <h2 className="text-lg font-semibold text-zinc-900 flex items-center gap-2">
                      <Terminal className="w-5 h-5 text-indigo-500" />
                      Quick Start (cURL)
                    </h2>
                    <p className="text-zinc-500 text-sm mt-1 mb-4">Push records directly to your dataset via the REST API.</p>
                    <div className="bg-zinc-950 rounded-xl p-4 overflow-x-auto border border-zinc-800">
                      <pre className="text-zinc-300 text-xs font-mono">
<span className="text-indigo-400">curl</span> -X POST http://localhost:8080/api/v1/datasets/<span className="text-amber-300">[YOUR_DATASET_ID]</span>/records \
  -H <span className="text-emerald-300">"Authorization: Bearer [YOUR_API_KEY]"</span> \
  -H <span className="text-emerald-300">"Content-Type: application/json"</span> \
  -d <span className="text-emerald-300">'{'{'}</span>
    <span className="text-blue-300">"data"</span>: {'{'}
      <span className="text-blue-300">"studentName"</span>: <span className="text-emerald-300">"John Doe"</span>,
      <span className="text-blue-300">"rollNumber"</span>: <span className="text-emerald-300">"CS-001"</span>,
      <span className="text-blue-300">"gpa"</span>: <span className="text-purple-300">3.8</span>
    {'}'}
  <span className="text-emerald-300">{'}'}'</span>
                      </pre>
                    </div>
                  </div>
                </motion.div>
              )}

              {/* WEBHOOKS TAB */}
              {activeTab === 'webhooks' && (
                <motion.div
                  key="webhooks"
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  className="space-y-6"
                >
                  <div className="flex items-center justify-between">
                    <div>
                      <h2 className="text-lg font-semibold text-zinc-900">Endpoints</h2>
                      <p className="text-zinc-500 text-sm mt-1">Receive real-time HTTP POST requests when events occur in your organization.</p>
                    </div>
                  </div>

                  <div className="grid gap-4">
                    {WEBHOOKS.map(wh => (
                      <div key={wh.id} className="p-5 rounded-xl border border-zinc-200 bg-white/50 hover:border-zinc-200 transition-colors">
                        <div className="flex items-start justify-between">
                          <div className="space-y-3">
                            <div className="flex items-center gap-3">
                              <span className={`px-2 py-1 rounded text-xs font-medium border ${getStatusColor(wh.status)}`}>
                                {wh.status}
                              </span>
                              <code className="text-sm text-zinc-600 font-mono">{wh.url}</code>
                            </div>
                            <div className="flex flex-wrap gap-2">
                              {wh.events.map(ev => (
                                <span key={ev} className="px-2 py-1 rounded-md text-xs font-mono bg-zinc-50 border border-zinc-200 text-zinc-500">
                                  {ev}
                                </span>
                              ))}
                            </div>
                          </div>
                          <button className="p-2 text-zinc-500 hover:text-zinc-900 hover:bg-zinc-100 rounded-lg transition-colors">
                            <MoreOptionsIcon />
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                </motion.div>
              )}

              {/* LOGS TAB */}
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
                        placeholder="Filter by endpoint, status, or trace ID..."
                        className="w-full pl-10 pr-4 py-2 bg-white border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 transition-all text-zinc-900 placeholder-zinc-500"
                      />
                    </div>
                    <button className="px-4 py-2 bg-white border border-zinc-200 rounded-xl text-sm text-zinc-600 hover:bg-zinc-100 transition-colors flex items-center gap-2">
                      <Activity className="w-4 h-4" /> Live
                    </button>
                  </div>

                  <div className="rounded-xl overflow-hidden border border-zinc-200 bg-white/80 font-mono text-sm backdrop-blur-xl">
                    <div className="flex items-center px-4 py-3 border-b border-zinc-200 text-xs text-zinc-500 uppercase tracking-wider font-sans font-semibold">
                      <div className="w-24">Status</div>
                      <div className="w-24">Method</div>
                      <div className="flex-1">Endpoint</div>
                      <div className="w-24 text-right">Latency</div>
                      <div className="w-32 text-right">Time</div>
                    </div>
                    
                    <div className="divide-y divide-zinc-800/50">
                      {LOGS.map(log => (
                        <details key={log.id} className="group cursor-pointer">
                          <summary className="flex items-center px-4 py-3 hover:bg-white/50 transition-colors list-none">
                            <div className="w-24">
                              <span className={`px-2 py-0.5 rounded text-xs border ${getStatusColor(log.status)}`}>
                                {log.status}
                              </span>
                            </div>
                            <div className={`w-24 font-bold ${getMethodColor(log.method)}`}>
                              {log.method}
                            </div>
                            <div className="flex-1 text-zinc-600">
                              {log.endpoint}
                            </div>
                            <div className="w-24 text-right text-zinc-500">
                              {log.latency}
                            </div>
                            <div className="w-32 text-right text-zinc-500 text-xs">
                              {log.time}
                            </div>
                          </summary>
                          {log.body && (
                            <div className="px-4 py-4 bg-white border-t border-zinc-200 text-zinc-500 whitespace-pre-wrap text-xs">
                              {log.body}
                            </div>
                          )}
                        </details>
                      ))}
                    </div>
                  </div>
                </motion.div>
              )}

            </AnimatePresence>
          </div>
        </div>
      </div>

      {/* Generate Key Modal */}
      <AnimatePresence>
        {isKeyModalOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
              onClick={() => setIsKeyModalOpen(false)}
            />
            <motion.div 
              initial={{ opacity: 0, scale: 0.95, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 20 }}
              className="fixed left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-md bg-white border border-zinc-200 rounded-2xl z-50 p-6 shadow-2xl"
            >
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-bold text-zinc-900 flex items-center gap-2">
                  <Key className="w-5 h-5 text-purple-400" />
                  Create API Key
                </h2>
                <button onClick={() => setIsKeyModalOpen(false)} className="text-zinc-500 hover:text-zinc-900">
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="space-y-5">
                <div>
                  <label className="block text-sm font-medium text-zinc-600 mb-2">Key Name</label>
                  <input 
                    type="text" 
                    placeholder="e.g. Zapier Integration"
                    className="w-full px-4 py-2.5 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 text-zinc-900 placeholder-zinc-600"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-zinc-600 mb-2">Permissions</label>
                  <div className="space-y-2">
                    <label className="flex items-center justify-between p-3 rounded-xl border border-zinc-200 bg-zinc-50 cursor-pointer">
                      <div>
                        <p className="text-sm text-zinc-900 font-medium">Read Only</p>
                        <p className="text-xs text-zinc-500">Can only view datasets and records.</p>
                      </div>
                      <input type="radio" name="scope" defaultChecked className="text-purple-500 focus:ring-purple-500" />
                    </label>
                    <label className="flex items-center justify-between p-3 rounded-xl border border-zinc-200 bg-zinc-50 cursor-pointer">
                      <div>
                        <p className="text-sm text-zinc-900 font-medium">Full Access</p>
                        <p className="text-xs text-zinc-500">Can create, update, and delete data.</p>
                      </div>
                      <input type="radio" name="scope" className="text-purple-500 focus:ring-purple-500" />
                    </label>
                  </div>
                </div>

                <div className="pt-4 flex gap-3">
                  <button onClick={() => setIsKeyModalOpen(false)} className="flex-1 py-2.5 rounded-xl border border-zinc-200 text-zinc-900 font-medium hover:bg-zinc-50 transition-colors">
                    Cancel
                  </button>
                  <button className="flex-1 py-2.5 rounded-xl bg-purple-600 hover:bg-purple-500 text-zinc-900 font-medium transition-colors shadow-[0_0_20px_-5px_rgba(168,85,247,0.4)]">
                    Generate Key
                  </button>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

      {/* Add Webhook Drawer */}
      <AnimatePresence>
        {isWebhookModalOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40"
              onClick={() => setIsWebhookModalOpen(false)}
            />
            <motion.div 
              initial={{ x: '100%', opacity: 0.5 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: '100%', opacity: 0.5 }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-md bg-white border-l border-zinc-200 z-50 p-6 sm:p-8 flex flex-col shadow-2xl"
            >
              <div className="flex items-center justify-between mb-8">
                <h2 className="text-2xl font-bold text-zinc-900 flex items-center gap-2">
                  <Webhook className="w-6 h-6 text-purple-400" />
                  Add Endpoint
                </h2>
                <button 
                  onClick={() => setIsWebhookModalOpen(false)}
                  className="p-2 text-zinc-500 hover:text-zinc-900 rounded-lg hover:bg-zinc-50 transition-colors"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto space-y-6 pb-8">
                <div className="space-y-2">
                  <label className="text-sm font-medium text-zinc-600">Endpoint URL</label>
                  <input 
                    type="url" 
                    placeholder="https://api.yourdomain.com/webhook"
                    className="w-full px-4 py-3 bg-zinc-50 border border-zinc-200 rounded-xl text-sm focus:outline-none focus:border-purple-500 focus:ring-1 focus:ring-purple-500 transition-all text-zinc-900 placeholder-zinc-600"
                  />
                </div>

                <div className="space-y-3">
                  <label className="text-sm font-medium text-zinc-600">Events to send</label>
                  <div className="space-y-2 bg-zinc-50 border border-zinc-200 rounded-xl p-2">
                    {['record.created', 'record.updated', 'record.deleted', 'dataset.published'].map(ev => (
                      <label key={ev} className="flex items-center gap-3 p-3 rounded-lg hover:bg-zinc-100/50 transition-colors cursor-pointer group">
                        <input type="checkbox" className="w-4 h-4 rounded border-zinc-200 bg-zinc-50 text-purple-500 focus:ring-purple-500 focus:ring-offset-zinc-900" />
                        <span className="text-sm text-zinc-600 font-mono group-hover:text-zinc-900">{ev}</span>
                      </label>
                    ))}
                  </div>
                </div>

                <div className="p-4 rounded-xl bg-purple-500/10 border border-purple-500/20">
                  <div className="flex gap-3">
                    <Lock className="w-5 h-5 text-purple-400 shrink-0 mt-0.5" />
                    <div>
                      <h4 className="text-sm font-semibold text-purple-100">Signing Secret</h4>
                      <p className="text-xs text-purple-300/80 mt-1">A signing secret will be generated when you create this endpoint. Use it to verify that events are sent by ResultHub.</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="pt-6 border-t border-zinc-200 mt-auto">
                <button 
                  onClick={() => setIsWebhookModalOpen(false)}
                  className="w-full py-3 px-4 bg-purple-600 hover:bg-purple-500 text-zinc-900 font-medium rounded-xl transition-all shadow-[0_0_20px_-5px_rgba(168,85,247,0.4)] active:scale-[0.98]"
                >
                  Create Endpoint
                </button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}

function MoreOptionsIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="1"></circle>
      <circle cx="12" cy="5" r="1"></circle>
      <circle cx="12" cy="19" r="1"></circle>
    </svg>
  );
}
