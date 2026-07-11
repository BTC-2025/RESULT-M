"use client";

import { useState, useEffect } from "react";
import NotificationsRightSidebar from "@/components/feed/NotificationsRightSidebar";
import { api } from "@/lib/api";

export default function NotificationsPage() {
  const [activeTab, setActiveTab] = useState("All");
  const [notifications, setNotifications] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchNotifications();
  }, []);

  const fetchNotifications = async () => {
    try {
      setIsLoading(true);
      const res = await api.notifications.get();
      setNotifications(res.content || []);
    } catch (error) {
      console.error("Failed to fetch notifications:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const tabs = [
    { name: "Activity", count: null, mobileOnly: true },
    { name: "All", count: 126 },
    { name: "Mentions", count: 8 },
    { name: "Alerts", count: 24 },
    { name: "Likes", count: 56 },
    { name: "Follows", count: 17 }
  ];

  // Function to group notifications by date
  const groupNotifications = (notifs: any[]) => {
    if (!notifs || notifs.length === 0) return {};
    
    return notifs.reduce((groups: any, notif: any) => {
      let dateKey = "Earlier";
      if (notif.createdAt) {
        const date = new Date(notif.createdAt);
        const now = new Date();
        const diffDays = Math.floor((now.getTime() - date.getTime()) / (1000 * 3600 * 24));
        if (diffDays === 0) dateKey = "Today";
        else if (diffDays === 1) dateKey = "Yesterday";
        else if (diffDays < 7) dateKey = "This Week";
      }

      if (!groups[dateKey]) groups[dateKey] = [];
      groups[dateKey].push({
        id: notif.id,
        type: notif.type || "ALERT",
        user: notif.title || notif.message?.split(' ')[0] || "System",
        text: notif.message?.substring(notif.message.indexOf(' ') + 1) || notif.message,
        timeAgo: notif.createdAt ? new Date(notif.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : "Recently",
        read: notif.read || false,
        importance: notif.type === "SECURITY" ? "Critical" : "Normal",
        category: notif.type || "SYSTEM",
        categoryColor: "bg-blue-500",
        preview: null,
        avatar: (notif.title || "S")[0],
        color: "bg-primary",
        icon: null
      });
      return groups;
    }, {});
  };

  const groupedNotifications = groupNotifications(notifications);


  const getImportanceColor = (level: string) => {
    if (level === "Critical") return "bg-red-500";
    if (level === "Important") return "bg-purple-500";
    return "bg-transparent";
  };

  return (
    <div className="flex w-full">
      
      {/* Main Notification Feed (100% on mobile, 65% on desktop) */}
      <div className="w-full xl:w-[65%] shrink-0 min-w-0 border-x-0 sm:border-x border-muted min-h-screen bg-background pb-12">
        {/* Header (Responsive Layout) */}
        <div className="bg-background border-b border-muted pt-5 px-4 sm:px-6 pb-4">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-4">
            
            <div className="flex items-center gap-3">
              <h1 className="text-xl font-bold tracking-tight text-foreground">Notifications</h1>
              <span className="text-xs font-bold text-primary bg-primary/10 px-2.5 py-1 rounded-full border border-primary/20 whitespace-nowrap">
                126 unread
              </span>
            </div>
            
            <div className="flex items-center gap-2 w-full sm:w-auto">
              <div className="relative flex-1 sm:flex-none">
                <div className="absolute inset-y-0 left-2.5 flex items-center pointer-events-none">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-muted-foreground"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </div>
                <input 
                  type="text" 
                  placeholder="Search..." 
                  className="bg-muted/30 border border-muted focus:border-primary focus:bg-background rounded-lg py-1.5 pl-8 pr-3 text-[13px] font-medium outline-none transition-all w-full sm:w-[180px] h-8"
                />
              </div>
              <button className="text-[13px] font-semibold text-muted-foreground hover:text-foreground hover:bg-muted px-3 py-1.5 rounded-lg transition-colors h-8 flex items-center whitespace-nowrap hidden sm:flex">
                Mark all read
              </button>
              <button className="w-8 h-8 shrink-0 flex items-center justify-center rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors sm:hidden" title="Mark all read">
                 <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
              </button>
              <button className="w-8 h-8 shrink-0 flex items-center justify-center rounded-lg text-muted-foreground hover:text-foreground hover:bg-muted transition-colors">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
              </button>
            </div>
          </div>
          
          {/* AI Smart Summary (Responsive) */}
          <div className="bg-gradient-to-r from-primary/[0.08] via-background to-background rounded-[14px] border border-primary/20 p-3 mb-5 shadow-sm flex flex-col sm:flex-row sm:items-center justify-between gap-3 overflow-hidden relative">
            <div className="flex flex-col sm:flex-row sm:items-center gap-3 sm:gap-4 relative z-10 w-full sm:w-auto">
               <span className="bg-primary/10 text-primary border border-primary/20 text-[10px] font-bold uppercase px-2 py-0.5 rounded-md tracking-wider w-fit">Today's Highlights</span>
               <div className="flex flex-wrap items-center gap-x-4 gap-y-2 text-[13px] font-semibold text-foreground/80">
                  <span className="flex items-center gap-1.5">
                    <span className="text-pink-500 flex items-center justify-center w-4 h-4">
                       <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="none"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path></svg>
                    </span> 
                    5 likes
                  </span>
                  <span className="flex items-center gap-1.5">
                    <span className="text-emerald-500 flex items-center justify-center w-4 h-4">
                       <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M23 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>
                    </span> 
                    2 followers
                  </span>
                  <span className="flex items-center gap-1.5">
                    <span className="text-blue-500 flex items-center justify-center w-4 h-4">
                       <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M3 3v18h18"></path><path d="M18 17V9"></path><path d="M13 17V5"></path><path d="M8 17v-3"></path></svg>
                    </span> 
                    1 poll (34 votes)
                  </span>
               </div>
            </div>
            <button className="text-[11px] sm:text-xs font-bold text-primary hover:underline relative z-10 self-start sm:self-auto shrink-0 hidden sm:block">View details</button>
          </div>

          {/* Segmented Control Tabs */}
          <div className="flex gap-1 bg-muted/40 p-1 rounded-[10px] overflow-x-auto hide-scrollbar w-full sm:w-fit border border-muted/50">
             {tabs.map(tab => (
               <button 
                 key={tab.name}
                 onClick={() => setActiveTab(tab.name)}
                 className={`px-4 py-1.5 flex items-center gap-1.5 font-semibold text-[13px] transition-all rounded-md whitespace-nowrap ${tab.mobileOnly ? 'xl:hidden' : ''} ${
                   activeTab === tab.name 
                     ? "bg-primary text-white shadow-sm" 
                     : "text-muted-foreground hover:text-foreground hover:bg-muted"
                 }`}
               >
                 {tab.name}
                 {tab.count !== null && (
                   <span className={`text-[10px] px-1.5 py-0.5 rounded-full ${activeTab === tab.name ? 'bg-white/20 text-white' : 'bg-muted-foreground/10 text-muted-foreground'}`}>
                     {tab.count}
                   </span>
                 )}
               </button>
             ))}
          </div>
        </div>

        {/* Tab Content Rendering */}
        {activeTab === 'Activity' ? (
          <div className="px-4 sm:px-6 xl:hidden animate-in fade-in slide-in-from-bottom-2 duration-300">
            <NotificationsRightSidebar />
          </div>
        ) : (
          <div className="flex flex-col">
            {isLoading ? (
              <div className="text-center text-muted-foreground py-10">Loading notifications...</div>
            ) : notifications.length === 0 ? (
              <div className="text-center text-muted-foreground py-10">You have no notifications.</div>
            ) : Object.entries(groupedNotifications).map(([timeGroup, notifs]: any) => (
              <div key={timeGroup}>
                {/* Timeline Header (Non-sticky) */}
                <div className="px-6 py-2 bg-background border-b border-muted">
                  <h3 className="text-[11px] font-bold text-muted-foreground uppercase tracking-widest">{timeGroup}</h3>
                </div>
                
                {/* Notification Mini Cards */}
                {notifs.map((notif: any) => (
                  <div 
                    key={notif.id} 
                    className={`relative p-4 px-6 border-b border-muted/50 hover:bg-muted/20 cursor-pointer flex gap-4 transition-all duration-200 group ${notif.read ? '' : 'bg-primary/5'}`}
                  >
                    {/* Importance Color Indicator */}
                    <div className={`absolute left-0 top-0 bottom-0 w-[3px] ${getImportanceColor(notif.importance)}`}></div>
                    
                    {/* Avatar & Badge */}
                    <div className="relative shrink-0 mt-0.5">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold text-base text-white shadow-sm border border-muted/20 transition-transform duration-200 group-hover:scale-105 ${
                        typeof notif.avatar === 'string' && notif.avatar.match(/[^\x00-\x7F]/) ? "bg-transparent text-2xl" : notif.color
                      }`}>
                        {notif.avatar}
                      </div>
                      {notif.icon && (
                        <div className={`absolute -bottom-1 -right-1 w-[18px] h-[18px] rounded-full flex items-center justify-center border-2 border-background shadow-sm ${notif.color}`}>
                           {notif.icon}
                        </div>
                      )}
                    </div>
                    
                    {/* Content */}
                    <div className="flex-1 pt-0">
                      <div className="flex items-start justify-between gap-4">
                        <div className="flex-1">
                          {/* Title Row */}
                          <div className="flex items-center gap-2 mb-1">
                            <span className={`text-[9px] font-black uppercase tracking-widest ${notif.categoryColor.replace('bg-', 'text-')}`}>
                              {notif.category}
                            </span>
                          </div>

                          <p className="text-[14px] leading-snug font-semibold text-foreground">
                            {notif.user} <span className="font-normal text-muted-foreground">{notif.text}</span>
                          </p>
                          
                          {/* Rich Preview Snippet */}
                          {notif.preview && (
                            <div className="mt-1.5">
                              <p className="text-[13px] font-normal text-foreground/90 line-clamp-2">{notif.preview}</p>
                            </div>
                          )}
                          
                          <p className="text-[12px] text-muted-foreground mt-1.5 font-medium flex items-center gap-1.5">
                             {notif.timeAgo}
                          </p>
                        </div>

                        {/* Right Side Actions & Unread */}
                        <div className="shrink-0 flex items-center gap-2">
                           {/* Hover Actions */}
                           <div className="flex items-center opacity-0 group-hover:opacity-100 transition-opacity duration-200 bg-background/80 backdrop-blur-sm border border-muted shadow-sm rounded-lg overflow-hidden">
                             <button className="p-1.5 text-muted-foreground hover:text-foreground hover:bg-muted transition-colors border-r border-muted" title="Mark read">
                               <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg>
                             </button>
                             <button className="p-1.5 text-muted-foreground hover:text-foreground hover:bg-muted transition-colors border-r border-muted" title="Archive">
                               <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><polyline points="21 8 21 21 3 21 3 8"></polyline><rect x="1" y="3" width="22" height="5"></rect><line x1="10" y1="12" x2="14" y2="12"></line></svg>
                             </button>
                             <button className="p-1.5 text-muted-foreground hover:text-foreground hover:bg-muted transition-colors" title="More">
                               <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><circle cx="12" cy="12" r="1"></circle><circle cx="19" cy="12" r="1"></circle><circle cx="5" cy="12" r="1"></circle></svg>
                             </button>
                           </div>
                           
                           {/* Unread Indicator */}
                           {!notif.read && (
                             <div className="w-2 h-2 bg-primary rounded-full shadow-[0_0_8px_rgba(var(--primary),0.6)] ml-2"></div>
                           )}
                        </div>
                      </div>
                    </div>
                    
                  </div>
                ))}
              </div>
            ))}
          </div>
        )}
      </div>
      
      {/* 22% Right Panel (Desktop Only) */}
      <div className="hidden xl:block w-[35%] pl-8">
         <NotificationsRightSidebar className="sticky top-[88px] h-[calc(100vh-88px)] overflow-y-auto hide-scrollbar" />
      </div>
    </div>
  );
}
