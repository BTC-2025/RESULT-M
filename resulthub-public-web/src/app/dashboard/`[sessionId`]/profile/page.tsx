"use client";

import { useState } from "react";
import { Building2, UploadCloud, Globe, BadgeCheck, Palette, Save, Link2 } from "lucide-react";

export default function OrganizationProfilePage() {
  const [activeTab, setActiveTab] = useState('general');

  return (
    <div className="max-w-5xl mx-auto w-full space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-[#635BFF] mb-2">
            <Building2 size={20} />
            <h2 className="text-sm font-bold uppercase tracking-widest">Public Identity</h2>
          </div>
          <h1 className="text-3xl sm:text-4xl font-black text-zinc-950 tracking-tight">
            Organization Profile
          </h1>
          <p className="text-zinc-500 font-medium mt-1">
            Manage how your organization appears on the ResultHub public directory.
          </p>
        </div>
        <button className="flex items-center gap-2 bg-[#635BFF] text-white px-6 py-2.5 rounded-xl font-bold hover:bg-[#5249E5] transition-colors shadow-sm shadow-[#635BFF]/20 text-sm">
          <Save size={16} /> Save Changes
        </button>
      </div>

      <div className="flex flex-col md:flex-row gap-8">
        
        {/* Left Sidebar Nav */}
        <div className="w-full md:w-64 shrink-0 space-y-1">
           <button 
             onClick={() => setActiveTab('general')}
             className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-bold transition-all ${activeTab === 'general' ? 'bg-white text-[#635BFF] shadow-sm border border-zinc-200/50' : 'text-zinc-500 hover:text-zinc-900 hover:bg-zinc-50'}`}
           >
             <Building2 size={18} /> General Details
           </button>
           <button 
             onClick={() => setActiveTab('branding')}
             className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-bold transition-all ${activeTab === 'branding' ? 'bg-white text-[#635BFF] shadow-sm border border-zinc-200/50' : 'text-zinc-500 hover:text-zinc-900 hover:bg-zinc-50'}`}
           >
             <Palette size={18} /> Branding & Media
           </button>
           <button 
             onClick={() => setActiveTab('seo')}
             className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-bold transition-all ${activeTab === 'seo' ? 'bg-white text-[#635BFF] shadow-sm border border-zinc-200/50' : 'text-zinc-500 hover:text-zinc-900 hover:bg-zinc-50'}`}
           >
             <Globe size={18} /> SEO & Discovery
           </button>
           <button 
             onClick={() => setActiveTab('verification')}
             className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl text-sm font-bold transition-all ${activeTab === 'verification' ? 'bg-white text-[#635BFF] shadow-sm border border-zinc-200/50' : 'text-zinc-500 hover:text-zinc-900 hover:bg-zinc-50'}`}
           >
             <BadgeCheck size={18} /> Verification Status
           </button>
        </div>

        {/* Content Area */}
        <div className="flex-1 bg-white border border-zinc-200 rounded-3xl shadow-sm p-6 sm:p-8">
          
          {activeTab === 'general' && (
            <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
               <div>
                 <h3 className="text-xl font-bold text-zinc-950 mb-1">General Details</h3>
                 <p className="text-sm font-medium text-zinc-500">Update your organization's basic public information.</p>
               </div>
               
               <div className="space-y-4 pt-4">
                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-1">Organization Name</label>
                   <input type="text" defaultValue="Stanford University" className="w-full px-4 py-2.5 rounded-xl border border-zinc-200 text-zinc-900 font-medium focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] transition-all" />
                 </div>
                 
                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-1">Public Description</label>
                   <textarea rows={4} defaultValue="A private research university in Stanford, California. The campus occupies 8,180 acres, among the largest in the United States, and enrolls over 17,000 students." className="w-full px-4 py-3 rounded-xl border border-zinc-200 text-zinc-900 font-medium focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] transition-all resize-none"></textarea>
                 </div>

                 <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                   <div>
                     <label className="block text-sm font-bold text-zinc-700 mb-1">Industry / Category</label>
                     <select className="w-full px-4 py-2.5 rounded-xl border border-zinc-200 text-zinc-900 font-medium focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] transition-all bg-white">
                       <option>Education / University</option>
                       <option>Government</option>
                       <option>Corporate</option>
                       <option>Non-Profit</option>
                     </select>
                   </div>
                   <div>
                     <label className="block text-sm font-bold text-zinc-700 mb-1">Location</label>
                     <input type="text" defaultValue="Stanford, California, US" className="w-full px-4 py-2.5 rounded-xl border border-zinc-200 text-zinc-900 font-medium focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] transition-all" />
                   </div>
                 </div>
                 
                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-1">Official Website</label>
                   <div className="relative">
                     <Link2 size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" />
                     <input type="url" defaultValue="https://www.stanford.edu" className="w-full pl-9 pr-4 py-2.5 rounded-xl border border-zinc-200 text-zinc-900 font-medium focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] transition-all" />
                   </div>
                 </div>
               </div>
            </div>
          )}

          {activeTab === 'branding' && (
            <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
               <div>
                 <h3 className="text-xl font-bold text-zinc-950 mb-1">Branding & Media</h3>
                 <p className="text-sm font-medium text-zinc-500">Customize your portal's visual identity.</p>
               </div>
               
               <div className="space-y-8 pt-4">
                 
                 {/* Logo Upload */}
                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-3">Organization Logo</label>
                   <div className="flex items-center gap-6">
                     <div className="w-24 h-24 rounded-2xl bg-zinc-100 flex items-center justify-center border-2 border-dashed border-zinc-300">
                        <span className="text-2xl font-black text-zinc-400">SU</span>
                     </div>
                     <div>
                       <button className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 px-4 py-2 rounded-xl font-bold hover:bg-zinc-50 transition-colors shadow-sm text-sm">
                         <UploadCloud size={16} /> Upload New Logo
                       </button>
                       <p className="text-xs font-medium text-zinc-500 mt-2">Recommended size: 512x512px. Max 2MB (PNG, JPG, SVG).</p>
                     </div>
                   </div>
                 </div>

                 {/* Banner Upload */}
                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-3">Cover Banner</label>
                   <div className="w-full h-40 rounded-2xl bg-zinc-100 flex flex-col items-center justify-center border-2 border-dashed border-zinc-300 hover:bg-zinc-50 hover:border-zinc-400 transition-colors cursor-pointer group">
                      <div className="p-3 bg-white rounded-full shadow-sm group-hover:scale-110 transition-transform mb-2">
                        <UploadCloud size={20} className="text-[#635BFF]" />
                      </div>
                      <p className="text-sm font-bold text-zinc-700">Click to upload cover image</p>
                      <p className="text-xs font-medium text-zinc-500 mt-1">1200x400px recommended.</p>
                   </div>
                 </div>

                 {/* Brand Colors */}
                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-3">Brand Theme Color</label>
                   <div className="flex items-center gap-4">
                     <div className="w-10 h-10 rounded-full bg-[#8C1515] border-4 border-white shadow-md ring-2 ring-zinc-200 cursor-pointer"></div>
                     <div className="w-10 h-10 rounded-full bg-[#635BFF] cursor-pointer hover:scale-110 transition-transform"></div>
                     <div className="w-10 h-10 rounded-full bg-zinc-900 cursor-pointer hover:scale-110 transition-transform"></div>
                     <div className="w-10 h-10 rounded-full bg-emerald-600 cursor-pointer hover:scale-110 transition-transform"></div>
                     <div className="w-10 h-10 rounded-full bg-orange-500 cursor-pointer hover:scale-110 transition-transform"></div>
                     
                     <div className="ml-2 flex items-center gap-2">
                       <input type="text" defaultValue="#8C1515" className="w-24 px-3 py-1.5 rounded-lg border border-zinc-200 text-sm font-bold font-mono text-zinc-900 uppercase" />
                     </div>
                   </div>
                 </div>

               </div>
            </div>
          )}

          {activeTab === 'seo' && (
            <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
               <div>
                 <h3 className="text-xl font-bold text-zinc-950 mb-1">SEO & Discovery</h3>
                 <p className="text-sm font-medium text-zinc-500">Control how your organization appears in Google and internal search.</p>
               </div>
               <div className="space-y-4 pt-4">
                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-1">Public URL Slug</label>
                   <div className="flex items-center">
                     <span className="px-4 py-2.5 bg-zinc-50 border border-r-0 border-zinc-200 rounded-l-xl text-zinc-500 font-medium text-sm">resulthub.com/</span>
                     <input type="text" defaultValue="stanford" className="w-full px-4 py-2.5 rounded-r-xl border border-zinc-200 text-zinc-900 font-bold focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] transition-all" />
                   </div>
                 </div>
                 
                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-1">Meta Title</label>
                   <input type="text" defaultValue="Stanford University Official ResultHub" className="w-full px-4 py-2.5 rounded-xl border border-zinc-200 text-zinc-900 font-medium focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] transition-all" />
                 </div>

                 <div>
                   <label className="block text-sm font-bold text-zinc-700 mb-1">Search Keywords (Comma separated)</label>
                   <input type="text" defaultValue="stanford, university, admissions, transcripts, california" className="w-full px-4 py-2.5 rounded-xl border border-zinc-200 text-zinc-900 font-medium focus:outline-none focus:ring-2 focus:ring-[#635BFF]/20 focus:border-[#635BFF] transition-all" />
                 </div>
               </div>
            </div>
          )}

          {activeTab === 'verification' && (
            <div className="space-y-6 animate-in fade-in slide-in-from-right-4 duration-300">
               <div>
                 <h3 className="text-xl font-bold text-zinc-950 mb-1">Verification Status</h3>
                 <p className="text-sm font-medium text-zinc-500">Manage your verified badge and official documents.</p>
               </div>
               
               <div className="mt-6 p-6 bg-emerald-50 border border-emerald-200 rounded-2xl flex flex-col sm:flex-row items-center gap-6">
                 <div className="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center shrink-0">
                    <BadgeCheck size={32} />
                 </div>
                 <div className="text-center sm:text-left flex-1">
                   <h4 className="text-lg font-bold text-emerald-800">You are a Verified Organization</h4>
                   <p className="text-sm font-medium text-emerald-600/80 mt-1">
                     Your domain (stanford.edu) has been verified. The blue checkmark appears next to all your published datasets and polls.
                   </p>
                 </div>
               </div>
            </div>
          )}

        </div>
      </div>
    </div>
  );
}
