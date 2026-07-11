"use client";

import { motion } from "framer-motion";
import { Activity, Search, Filter, ShieldCheck, Database, Upload, Users, Key, Monitor, Download } from "lucide-react";

export default function ActivityLogsPage() {
  
  const getIconForAction = (type: string) => {
    switch(type) {
      case 'LOGIN': return <Monitor size={14} className="text-blue-500" />;
      case 'SECURITY': return <ShieldCheck size={14} className="text-red-500" />;
      case 'DATASET': return <Database size={14} className="text-purple-500" />;
      case 'IMPORT': return <Upload size={14} className="text-orange-500" />;
      case 'EXPORT': return <Download size={14} className="text-emerald-500" />;
      case 'TEAM': return <Users size={14} className="text-pink-500" />;
      case 'API': return <Key size={14} className="text-amber-500" />;
      default: return <Activity size={14} className="text-zinc-500" />;
    }
  };

  const activities = [
    { id: 1, type: 'DATASET', action: 'Published Dataset', resource: 'Midterm Results 2026', user: 'Alex Admin', email: 'alex@org.com', time: '2 minutes ago', ip: '192.168.1.1', status: 'SUCCESS' },
    { id: 2, type: 'IMPORT', action: 'Uploaded CSV Batch', resource: 'Student_Roster_v2.csv', user: 'Sarah Staff', email: 'sarah@org.com', time: '1 hour ago', ip: '192.168.1.42', status: 'SUCCESS' },
    { id: 3, type: 'TEAM', action: 'Changed Permissions', resource: 'Role: Editor -> Admin', user: 'Alex Admin', email: 'alex@org.com', time: '3 hours ago', ip: '192.168.1.1', status: 'SUCCESS' },
    { id: 4, type: 'SECURITY', action: 'Failed Login Attempt', resource: 'Invalid Password', user: 'Unknown', email: 'hacker@anon.com', time: '5 hours ago', ip: '45.22.19.102', status: 'FAILED' },
    { id: 5, type: 'API', action: 'Generated API Key', resource: 'Production Read Key', user: 'Dev Team', email: 'dev@org.com', time: '1 day ago', ip: '10.0.0.15', status: 'SUCCESS' },
    { id: 6, type: 'LOGIN', action: 'User Login', resource: 'Mac OS Safari', user: 'Sarah Staff', email: 'sarah@org.com', time: '1 day ago', ip: '192.168.1.42', status: 'SUCCESS' },
    { id: 7, type: 'EXPORT', action: 'Exported Records', resource: 'Complaint_Logs.json', user: 'Alex Admin', email: 'alex@org.com', time: '2 days ago', ip: '192.168.1.1', status: 'SUCCESS' },
  ];

  return (
    <div className="max-w-7xl mx-auto w-full space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-[#635BFF] mb-2">
            <Activity size={20} />
            <h2 className="text-sm font-bold uppercase tracking-widest">Audit Logs</h2>
          </div>
          <h1 className="text-3xl sm:text-4xl font-black text-zinc-950 tracking-tight">
            Activity Logs
          </h1>
          <p className="text-zinc-500 font-medium mt-1">
            Track every action taken across your organization's workspaces.
          </p>
        </div>
        <div className="flex gap-2">
           <button className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 px-4 py-2 rounded-xl font-bold hover:bg-zinc-50 transition-colors shadow-sm text-sm">
             <Filter size={16} /> Filter
           </button>
           <button className="flex items-center gap-2 bg-[#635BFF] text-white px-4 py-2 rounded-xl font-bold hover:bg-[#5249E5] transition-colors shadow-sm shadow-[#635BFF]/20 text-sm">
             <Download size={16} /> Export CSV
           </button>
        </div>
      </div>

      {/* Main Card */}
      <div className="bg-white border border-zinc-200 rounded-3xl shadow-sm overflow-hidden flex flex-col">
        
        {/* Toolbar */}
        <div className="p-4 border-b border-zinc-100 flex items-center justify-between bg-zinc-50/50">
           <div className="relative w-full max-w-md">
             <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" />
             <input type="text" placeholder="Search logs by user, IP, or action..." className="w-full pl-9 pr-4 py-2 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] transition-all" />
           </div>
           
           <div className="hidden sm:flex items-center gap-2 text-sm font-semibold text-zinc-500">
              Showing 1-7 of 1,245 events
           </div>
        </div>

        {/* Log Table */}
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-white border-b border-zinc-100">
                <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider w-16">Status</th>
                <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider">Action</th>
                <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider">Resource / Detail</th>
                <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider">User</th>
                <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider">IP Address</th>
                <th className="px-6 py-4 text-xs font-bold text-zinc-500 uppercase tracking-wider text-right">Time</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-zinc-100">
              {activities.map((log) => (
                <tr key={log.id} className="hover:bg-zinc-50/80 transition-colors group">
                  <td className="px-6 py-4">
                     <div className="flex justify-center">
                        {log.status === 'SUCCESS' ? (
                          <div className="w-2 h-2 rounded-full bg-emerald-500 ring-4 ring-emerald-500/20"></div>
                        ) : (
                          <div className="w-2 h-2 rounded-full bg-red-500 ring-4 ring-red-500/20"></div>
                        )}
                     </div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-lg bg-zinc-100 flex items-center justify-center shrink-0">
                         {getIconForAction(log.type)}
                      </div>
                      <span className="text-sm font-bold text-zinc-900 whitespace-nowrap">{log.action}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                     <div className="text-sm font-semibold text-zinc-600 max-w-[200px] sm:max-w-xs truncate" title={log.resource}>{log.resource}</div>
                  </td>
                  <td className="px-6 py-4">
                     <div>
                       <div className="text-sm font-bold text-zinc-900">{log.user}</div>
                       <div className="text-xs font-semibold text-zinc-500">{log.email}</div>
                     </div>
                  </td>
                  <td className="px-6 py-4">
                    <span className="px-2 py-1 bg-zinc-100 border border-zinc-200 rounded text-xs font-mono font-medium text-zinc-600">
                      {log.ip}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <span className="text-sm font-bold text-zinc-500 whitespace-nowrap">{log.time}</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        
        {/* Pagination Footer */}
        <div className="p-4 border-t border-zinc-100 bg-zinc-50/50 flex items-center justify-center gap-2">
           <button className="px-3 py-1.5 rounded-lg border border-zinc-200 text-sm font-bold text-zinc-400 bg-white cursor-not-allowed">Previous</button>
           <button className="px-3 py-1.5 rounded-lg border border-zinc-200 text-sm font-bold text-zinc-700 bg-white hover:bg-zinc-50">Next</button>
        </div>

      </div>
    </div>
  );
}
