"use client";

import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { 
  FileText, Download, Printer, Mail, Calendar, FileSpreadsheet, 
  Clock, CheckCircle2, MoreVertical
} from 'lucide-react';
import { useWorkspace } from '../../WorkspaceContext';

export default function ReportsAnalyticsPage() {
  const { activeWorkspace } = useWorkspace();
  const [selectedTemplate, setSelectedTemplate] = useState('Monthly');

  const templates = ['Daily Report', 'Weekly', 'Monthly', 'Quarterly', 'Yearly', 'Custom'];
  
  const history = [
    { name: 'July Performance.pdf', type: 'PDF', date: 'Jul 01, 2026', status: 'Completed', size: '2.4 MB' },
    { name: 'Q2 Demographics.xlsx', type: 'Excel', date: 'Jun 30, 2026', status: 'Completed', size: '1.1 MB' },
    { name: 'Weekly Traffic.csv', type: 'CSV', date: 'Jun 28, 2026', status: 'Completed', size: '450 KB' },
    { name: 'Annual Review 2025.pdf', type: 'PDF', date: 'Jan 01, 2026', status: 'Completed', size: '8.2 MB' },
  ];

  const scheduled = [
    { name: 'Weekly Executive Summary', format: 'PDF', frequency: 'Every Monday at 9:00 AM', recipients: 4 },
    { name: 'Monthly Dataset Growth', format: 'Excel', frequency: '1st of month at 8:00 AM', recipients: 2 },
  ];

  return (
    <div className="space-y-6 pb-20">
      
      <div className="mb-8">
        <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight">Reports & Exports</h1>
        <p className="text-zinc-500 font-medium mt-1">Generate, schedule, and download analytical reports.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        
        {/* Actions & Templates */}
        <div className="lg:col-span-2 space-y-6">
          
          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm"
          >
            <h3 className="text-lg font-bold text-zinc-900 mb-4">Export Options</h3>
            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
              <button className="flex flex-col items-center justify-center p-4 bg-zinc-50 border border-zinc-200 rounded-2xl hover:bg-zinc-100 hover:border-zinc-300 transition-all group">
                <FileText className="w-6 h-6 text-red-500 mb-2 group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-zinc-700">PDF</span>
              </button>
              <button className="flex flex-col items-center justify-center p-4 bg-zinc-50 border border-zinc-200 rounded-2xl hover:bg-zinc-100 hover:border-zinc-300 transition-all group">
                <FileSpreadsheet className="w-6 h-6 text-emerald-500 mb-2 group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-zinc-700">Excel</span>
              </button>
              <button className="flex flex-col items-center justify-center p-4 bg-zinc-50 border border-zinc-200 rounded-2xl hover:bg-zinc-100 hover:border-zinc-300 transition-all group">
                <Download className="w-6 h-6 text-blue-500 mb-2 group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-zinc-700">CSV</span>
              </button>
              <button className="flex flex-col items-center justify-center p-4 bg-zinc-50 border border-zinc-200 rounded-2xl hover:bg-zinc-100 hover:border-zinc-300 transition-all group">
                <Printer className="w-6 h-6 text-zinc-600 mb-2 group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-zinc-700">Print</span>
              </button>
              <button className="flex flex-col items-center justify-center p-4 bg-zinc-50 border border-zinc-200 rounded-2xl hover:bg-zinc-100 hover:border-zinc-300 transition-all group">
                <Mail className="w-6 h-6 text-purple-500 mb-2 group-hover:scale-110 transition-transform" />
                <span className="text-xs font-bold text-zinc-700">Email</span>
              </button>
            </div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm"
          >
            <h3 className="text-lg font-bold text-zinc-900 mb-4">Templates</h3>
            <div className="flex flex-wrap gap-3">
              {templates.map(t => (
                <button 
                  key={t}
                  onClick={() => setSelectedTemplate(t)}
                  className={`px-4 py-2.5 rounded-xl text-sm font-bold transition-all ${
                    selectedTemplate === t 
                      ? 'bg-purple-600 text-white shadow-md' 
                      : 'bg-zinc-50 text-zinc-600 border border-zinc-200 hover:bg-zinc-100'
                  }`}
                >
                  {t}
                </button>
              ))}
            </div>
            
            <div className="mt-8 pt-6 border-t border-zinc-200 flex justify-end gap-3">
              <button className="px-5 py-2.5 rounded-xl text-sm font-bold text-zinc-700 bg-zinc-100 hover:bg-zinc-200 transition-colors">
                Preview
              </button>
              <button className="px-5 py-2.5 rounded-xl text-sm font-bold text-white bg-zinc-900 hover:bg-zinc-800 shadow-md transition-colors flex items-center gap-2">
                <Download className="w-4 h-4" /> Generate Report
              </button>
            </div>
          </motion.div>

        </div>

        {/* History & Schedules */}
        <div className="space-y-6">
          
          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm"
          >
            <h3 className="text-lg font-bold text-zinc-900 mb-4 flex items-center gap-2">
              <Clock className="w-5 h-5 text-indigo-500" /> Scheduled Reports
            </h3>
            <div className="space-y-4">
              {scheduled.map((s, i) => (
                <div key={i} className="p-4 rounded-xl border border-zinc-200 bg-zinc-50 hover:border-zinc-300 transition-colors">
                  <div className="flex justify-between items-start mb-2">
                    <h4 className="text-sm font-bold text-zinc-900">{s.name}</h4>
                    <span className="text-[10px] font-bold text-zinc-500 bg-zinc-200 px-2 py-0.5 rounded">{s.format}</span>
                  </div>
                  <p className="text-xs font-medium text-zinc-500 flex items-center gap-1.5"><Calendar className="w-3.5 h-3.5"/> {s.frequency}</p>
                </div>
              ))}
              <button className="w-full py-3 border-2 border-dashed border-zinc-200 rounded-xl text-sm font-bold text-zinc-500 hover:border-purple-300 hover:text-purple-600 hover:bg-purple-50 transition-all">
                + Create Schedule
              </button>
            </div>
          </motion.div>

          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
            className="bg-white border border-zinc-200 rounded-3xl p-6 shadow-sm"
          >
            <h3 className="text-lg font-bold text-zinc-900 mb-4 flex items-center gap-2">
              <Download className="w-5 h-5 text-emerald-500" /> Download History
            </h3>
            <div className="space-y-3">
              {history.map((h, i) => (
                <div key={i} className="flex items-center justify-between p-3 rounded-xl hover:bg-zinc-50 transition-colors group">
                  <div className="flex items-center gap-3">
                    <div className={`p-2 rounded-lg ${
                      h.type === 'PDF' ? 'bg-red-50 text-red-500' :
                      h.type === 'Excel' ? 'bg-emerald-50 text-emerald-500' : 'bg-blue-50 text-blue-500'
                    }`}>
                      {h.type === 'PDF' ? <FileText className="w-4 h-4"/> : 
                       h.type === 'Excel' ? <FileSpreadsheet className="w-4 h-4"/> : 
                       <Download className="w-4 h-4"/>}
                    </div>
                    <div>
                      <h4 className="text-sm font-bold text-zinc-900">{h.name}</h4>
                      <p className="text-[10px] font-medium text-zinc-500">{h.date} • {h.size}</p>
                    </div>
                  </div>
                  <button className="text-zinc-400 hover:text-zinc-900 p-1">
                    <MoreVertical className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          </motion.div>

        </div>
      </div>
    </div>
  );
}
