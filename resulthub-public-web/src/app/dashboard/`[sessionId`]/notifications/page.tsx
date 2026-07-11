"use client";

import { motion } from "framer-motion";
import { BellRing, ShieldAlert, Key, Users, CheckSquare, Settings2, CheckCircle2, MoreHorizontal } from "lucide-react";

export default function NotificationsCenterPage() {
  const notifications = [
    { 
      id: 1, 
      category: 'SECURITY', 
      title: 'Suspicious Login Attempt Blocked', 
      message: 'Multiple failed login attempts detected from IP 45.22.19.102 targeting the admin account.', 
      time: '10 minutes ago', 
      read: false, 
      action: 'Review Logs',
      icon: ShieldAlert,
      color: 'text-red-500',
      bg: 'bg-red-50'
    },
    { 
      id: 2, 
      category: 'TEAM', 
      title: 'New Member Invitation Accepted', 
      message: 'Sarah Jenkins has accepted your invitation and joined the "Admissions" workspace as an Editor.', 
      time: '2 hours ago', 
      read: false, 
      action: 'Manage Team',
      icon: Users,
      color: 'text-blue-500',
      bg: 'bg-blue-50'
    },
    { 
      id: 3, 
      category: 'API', 
      title: 'API Rate Limit Warning', 
      message: 'Your production API key has consumed 80% of its hourly rate limit. Consider upgrading your plan if traffic continues.', 
      time: '5 hours ago', 
      read: true, 
      action: 'View Usage',
      icon: Key,
      color: 'text-orange-500',
      bg: 'bg-orange-50'
    },
    { 
      id: 4, 
      category: 'POLL', 
      title: 'Poll Completed: Student Council Elections', 
      message: 'The scheduled poll has officially closed. 4,205 total votes were recorded. Results are now ready for review.', 
      time: '1 day ago', 
      read: true, 
      action: 'View Results',
      icon: CheckSquare,
      color: 'text-purple-500',
      bg: 'bg-purple-50'
    },
  ];

  return (
    <div className="max-w-4xl mx-auto w-full space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-[#635BFF] mb-2">
            <BellRing size={20} />
            <h2 className="text-sm font-bold uppercase tracking-widest">Inbox</h2>
          </div>
          <h1 className="text-3xl sm:text-4xl font-black text-zinc-950 tracking-tight">
            Notifications Center
          </h1>
          <p className="text-zinc-500 font-medium mt-1">
            Stay updated on security alerts, team activity, and system events.
          </p>
        </div>
        <div className="flex gap-2">
           <button className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 px-4 py-2 rounded-xl font-bold hover:bg-zinc-50 transition-colors shadow-sm text-sm">
             <CheckCircle2 size={16} /> Mark all read
           </button>
           <button className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 p-2 rounded-xl hover:bg-zinc-50 transition-colors shadow-sm">
             <Settings2 size={20} />
           </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-4 border-b border-zinc-200">
        <button className="pb-3 border-b-2 border-[#635BFF] text-[#635BFF] font-bold text-sm">All Alerts</button>
        <button className="pb-3 border-b-2 border-transparent text-zinc-500 hover:text-zinc-900 font-bold text-sm transition-colors">Security</button>
        <button className="pb-3 border-b-2 border-transparent text-zinc-500 hover:text-zinc-900 font-bold text-sm transition-colors">Team</button>
        <button className="pb-3 border-b-2 border-transparent text-zinc-500 hover:text-zinc-900 font-bold text-sm transition-colors">System</button>
      </div>

      {/* Notifications List */}
      <div className="space-y-4">
        {notifications.map((notification, i) => (
          <motion.div 
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            key={notification.id} 
            className={`group flex items-start gap-4 p-5 rounded-2xl border transition-all ${
              !notification.read ? 'bg-white border-[#635BFF]/30 shadow-md shadow-[#635BFF]/5' : 'bg-white border-zinc-200 shadow-sm opacity-80 hover:opacity-100'
            }`}
          >
            <div className={`p-3 rounded-xl shrink-0 ${notification.bg}`}>
               <notification.icon size={24} className={notification.color} />
            </div>
            
            <div className="flex-1 min-w-0">
               <div className="flex items-start justify-between gap-4">
                  <div>
                    <h3 className={`text-base font-bold truncate ${!notification.read ? 'text-zinc-950' : 'text-zinc-700'}`}>
                      {notification.title}
                    </h3>
                    <p className="text-sm font-medium text-zinc-500 mt-1 pr-4">
                      {notification.message}
                    </p>
                  </div>
                  <span className="text-xs font-bold text-zinc-400 whitespace-nowrap shrink-0">{notification.time}</span>
               </div>
               
               <div className="flex items-center gap-4 mt-4">
                 <button className="text-sm font-bold text-[#635BFF] hover:underline">
                   {notification.action}
                 </button>
                 {!notification.read && (
                   <button className="text-sm font-bold text-zinc-500 hover:text-zinc-900">
                     Mark as read
                   </button>
                 )}
               </div>
            </div>

            <div className="shrink-0 opacity-0 group-hover:opacity-100 transition-opacity">
              <button className="p-2 text-zinc-400 hover:text-zinc-900 bg-zinc-50 rounded-lg">
                <MoreHorizontal size={16} />
              </button>
            </div>
          </motion.div>
        ))}
      </div>

      {/* Load More */}
      <div className="flex justify-center pt-4">
        <button className="px-6 py-2.5 bg-zinc-100 text-zinc-600 font-bold text-sm rounded-xl hover:bg-zinc-200 transition-colors">
          Load older notifications
        </button>
      </div>

    </div>
  );
}
