"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { useState } from "react";
import { 
  Building2, Users, ShieldCheck, Zap, 
  ChevronRight, ArrowUpRight, CheckCircle2, 
  Loader2, Mail, Building, LayoutGrid
} from "lucide-react";

export default function ContactSalesPage() {
  const [formState, setFormState] = useState<"idle" | "submitting" | "success">("idle");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setFormState("submitting");
    // Simulate API call
    setTimeout(() => {
      setFormState("success");
    }, 2000);
  };

  const fadeUpVariant = {
    hidden: { opacity: 0, y: 20 },
    visible: (i: number) => ({
      opacity: 1, 
      y: 0, 
      transition: { duration: 0.6, delay: i * 0.1 }
    })
  };

  return (
    <div className="min-h-screen bg-[#FAFAFA] text-zinc-900 font-sans selection:bg-indigo-500/20 relative overflow-hidden">
      
      {/* LOCAL HEADER */}
      <nav className="fixed top-0 w-full z-50 bg-[#FAFAFA]/70 backdrop-blur-2xl border-b border-black/5 transition-all">
        <div className="max-w-[1440px] mx-auto px-6 h-16 flex items-center justify-between">
          <Link href="/" className="flex items-center gap-3 group">
             <div className="w-8 h-8 flex items-center justify-center rounded-xl bg-gradient-to-br from-indigo-600 to-purple-600 text-white font-black text-sm shadow-lg shadow-indigo-500/20 group-hover:scale-105 transition-transform duration-300">
                R
             </div>
             <span className="font-extrabold text-lg tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-zinc-900 to-zinc-600">ResultHub</span>
          </Link>
          <div className="flex items-center gap-6">
             <Link href="/organization" className="text-sm font-semibold text-zinc-500 hover:text-zinc-900 transition-colors hidden sm:block">Organizations</Link>
             <Link href="/organization/login" className="flex items-center gap-2 bg-zinc-900 text-white px-5 py-2 rounded-full text-sm font-bold shadow-[0_4px_14px_0_rgb(0,0,0,20%)] hover:shadow-[0_6px_20px_rgba(0,0,0,0.23)] hover:-translate-y-0.5 transition-all duration-200">
               Sign In
               <ChevronRight size={16} />
             </Link>
          </div>
        </div>
      </nav>

      {/* VIBRANT BACKGROUND MESHES */}
      <div className="absolute top-0 right-0 w-[800px] h-[800px] bg-indigo-500/10 rounded-full blur-[150px] pointer-events-none"></div>
      <div className="absolute bottom-0 left-0 w-[600px] h-[600px] bg-purple-500/10 rounded-full blur-[150px] pointer-events-none"></div>

      <main className="max-w-[1200px] mx-auto px-6 pt-32 pb-24 min-h-[90vh] flex flex-col lg:flex-row items-center gap-16 lg:gap-24 relative z-10">
        
        {/* LEFT COLUMN: The Form */}
        <div className="flex-1 w-full max-w-xl">
          <motion.div 
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, type: "spring", stiffness: 100 }}
            className="bg-white/80 backdrop-blur-xl border border-black/5 p-8 sm:p-10 rounded-[32px] shadow-[0_20px_60px_-15px_rgba(0,0,0,0.1)] relative overflow-hidden"
          >
             
             {formState === "success" ? (
               <motion.div 
                 initial={{ opacity: 0, scale: 0.9 }}
                 animate={{ opacity: 1, scale: 1 }}
                 className="flex flex-col items-center justify-center text-center py-12"
               >
                 <div className="w-20 h-20 bg-emerald-50 text-emerald-500 rounded-full flex items-center justify-center mb-6">
                   <CheckCircle2 size={40} />
                 </div>
                 <h3 className="text-3xl font-extrabold text-zinc-900 mb-4">Request Received</h3>
                 <p className="text-zinc-500 font-medium leading-relaxed max-w-sm">
                   Thank you for reaching out. An enterprise specialist will be in touch within 24 hours to discuss your tailored solution.
                 </p>
                 <button 
                   onClick={() => setFormState("idle")}
                   className="mt-8 px-6 py-3 font-bold text-indigo-600 bg-indigo-50 rounded-xl hover:bg-indigo-100 transition-colors"
                 >
                   Send another message
                 </button>
               </motion.div>
             ) : (
               <form onSubmit={handleSubmit} className="flex flex-col gap-6">
                 <div>
                   <h2 className="text-3xl font-extrabold tracking-tight text-zinc-900 mb-2">Talk to Sales</h2>
                   <p className="text-zinc-500 font-medium text-sm">Tell us about your organization and we'll help you scale.</p>
                 </div>
                 
                 <div className="flex flex-col sm:flex-row gap-6">
                    <div className="flex-1 flex flex-col gap-2">
                       <label className="text-xs font-bold text-zinc-700 uppercase tracking-wider">First Name</label>
                       <input required type="text" placeholder="Alex" className="w-full bg-zinc-50 border border-zinc-200 px-4 py-3.5 rounded-2xl text-zinc-900 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:bg-white transition-all font-medium placeholder:text-zinc-400" />
                    </div>
                    <div className="flex-1 flex flex-col gap-2">
                       <label className="text-xs font-bold text-zinc-700 uppercase tracking-wider">Last Name</label>
                       <input required type="text" placeholder="Chen" className="w-full bg-zinc-50 border border-zinc-200 px-4 py-3.5 rounded-2xl text-zinc-900 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:bg-white transition-all font-medium placeholder:text-zinc-400" />
                    </div>
                 </div>

                 <div className="flex flex-col gap-2">
                    <label className="text-xs font-bold text-zinc-700 uppercase tracking-wider flex items-center gap-2"><Mail size={14}/> Work Email</label>
                    <input required type="email" placeholder="alex@university.edu" className="w-full bg-zinc-50 border border-zinc-200 px-4 py-3.5 rounded-2xl text-zinc-900 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:bg-white transition-all font-medium placeholder:text-zinc-400" />
                 </div>

                 <div className="flex flex-col gap-2">
                    <label className="text-xs font-bold text-zinc-700 uppercase tracking-wider flex items-center gap-2"><Building size={14}/> Organization Type</label>
                    <div className="relative">
                      <select required defaultValue="" className="w-full bg-zinc-50 border border-zinc-200 px-4 py-3.5 rounded-2xl text-zinc-900 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:bg-white transition-all font-medium appearance-none">
                        <option value="" disabled>Select an industry...</option>
                        <option value="education">Education (School/University)</option>
                        <option value="government">Government</option>
                        <option value="healthcare">Healthcare</option>
                        <option value="corporate">Corporate Enterprise</option>
                        <option value="other">Other</option>
                      </select>
                      <LayoutGrid size={16} className="absolute right-4 top-1/2 -translate-y-1/2 text-zinc-400 pointer-events-none" />
                    </div>
                 </div>

                 <div className="flex flex-col gap-2">
                    <label className="text-xs font-bold text-zinc-700 uppercase tracking-wider">How can we help?</label>
                    <textarea required placeholder="Tell us about your data publishing needs, expected traffic, and timeline..." rows={4} className="w-full bg-zinc-50 border border-zinc-200 px-4 py-3.5 rounded-2xl text-zinc-900 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:bg-white transition-all font-medium placeholder:text-zinc-400 resize-none"></textarea>
                 </div>

                 <button 
                   type="submit" 
                   disabled={formState === "submitting"}
                   className="mt-2 w-full bg-zinc-900 text-white font-bold text-lg py-4 rounded-2xl shadow-[0_8px_30px_rgb(0,0,0,0.12)] hover:shadow-[0_10px_40px_rgb(0,0,0,0.25)] hover:-translate-y-1 active:scale-95 transition-all disabled:opacity-70 disabled:pointer-events-none flex items-center justify-center gap-2"
                 >
                   {formState === "submitting" ? (
                     <><Loader2 size={20} className="animate-spin" /> Processing...</>
                   ) : (
                     <>Contact Enterprise Sales <ArrowUpRight size={20} /></>
                   )}
                 </button>
               </form>
             )}
          </motion.div>
        </div>

        {/* RIGHT COLUMN: Value Prop & Social Proof */}
        <div className="flex-1 w-full max-w-xl">
           <motion.h1 
             custom={0} initial="hidden" animate="visible" variants={fadeUpVariant}
             className="text-5xl md:text-6xl font-extrabold tracking-tight text-zinc-900 leading-[1.1] mb-6"
           >
             Scale your organization with <span className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 to-purple-500">ResultHub.</span>
           </motion.h1>
           
           <motion.p 
             custom={1} initial="hidden" animate="visible" variants={fadeUpVariant}
             className="text-xl text-zinc-500 font-medium leading-relaxed mb-12"
           >
             Join the world's most innovative institutions. We provide the dedicated support and custom infrastructure required for mission-critical deployments.
           </motion.p>

           <div className="flex flex-col gap-8">
              
              <motion.div custom={2} initial="hidden" animate="visible" variants={fadeUpVariant} className="flex gap-4">
                <div className="w-12 h-12 shrink-0 bg-blue-50 text-blue-600 rounded-2xl flex items-center justify-center">
                  <ShieldCheck size={24} />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-zinc-900 mb-1">SSO & Advanced Security</h3>
                  <p className="text-zinc-500 font-medium leading-relaxed">SAML, Custom JWT routing, role-based strict isolation, and comprehensive audit logs for absolute compliance.</p>
                </div>
              </motion.div>

              <motion.div custom={3} initial="hidden" animate="visible" variants={fadeUpVariant} className="flex gap-4">
                <div className="w-12 h-12 shrink-0 bg-emerald-50 text-emerald-600 rounded-2xl flex items-center justify-center">
                  <Zap size={24} />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-zinc-900 mb-1">Custom API & Rate Limits</h3>
                  <p className="text-zinc-500 font-medium leading-relaxed">Dedicated infrastructure routing ensures you bypass standard public rate limits during massive traffic spikes.</p>
                </div>
              </motion.div>

              <motion.div custom={4} initial="hidden" animate="visible" variants={fadeUpVariant} className="flex gap-4">
                <div className="w-12 h-12 shrink-0 bg-purple-50 text-purple-600 rounded-2xl flex items-center justify-center">
                  <Building2 size={24} />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-zinc-900 mb-1">Dedicated Account Management</h3>
                  <p className="text-zinc-500 font-medium leading-relaxed">Direct Slack/Teams channels, 99.99% uptime SLAs, and 24/7 dedicated engineering support.</p>
                </div>
              </motion.div>

           </div>

           {/* Testimonial Snippet */}
           <motion.div 
             custom={5} initial="hidden" animate="visible" variants={fadeUpVariant}
             className="mt-12 p-6 rounded-3xl bg-white border border-black/5 shadow-sm relative"
           >
             <div className="absolute -top-3 -left-3 text-4xl text-indigo-200">"</div>
             <p className="text-zinc-700 font-medium italic relative z-10">
               ResultHub Enterprise allowed us to publish state-wide exam data without our servers crashing. Their dedicated routing and automated UI engine saved us thousands of engineering hours.
             </p>
             <div className="mt-4 flex items-center gap-3">
               <div className="w-10 h-10 rounded-full bg-zinc-200"></div>
               <div>
                 <span className="block font-bold text-sm text-zinc-900">Dr. Sarah Jenkins</span>
                 <span className="block font-semibold text-xs text-zinc-500 uppercase tracking-wide">Director of IT, State Education Board</span>
               </div>
             </div>
           </motion.div>
        </div>

      </main>

    </div>
  );
}
