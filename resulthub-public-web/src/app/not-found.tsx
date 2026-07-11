"use client";

import Link from 'next/link';
import { motion } from 'framer-motion';
import { Search, Home, ArrowLeft, HelpCircle } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function NotFound() {
  const router = useRouter();

  return (
    <div className="min-h-screen bg-[#F9FAFB] flex flex-col items-center justify-center p-4 relative overflow-hidden selection:bg-[#635BFF]/20">
      
      {/* Abstract Background Elements */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-gradient-to-tr from-[#635BFF]/5 to-purple-500/5 rounded-full blur-3xl pointer-events-none -z-10"></div>
      <div className="absolute top-0 right-0 w-96 h-96 bg-orange-500/5 rounded-full blur-3xl -translate-y-1/2 translate-x-1/3 pointer-events-none -z-10"></div>
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-blue-500/5 rounded-full blur-3xl translate-y-1/2 -translate-x-1/3 pointer-events-none -z-10"></div>

      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-lg text-center z-10"
      >
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ delay: 0.2, type: "spring", bounce: 0.5 }}
          className="relative inline-block mb-6"
        >
          <div className="text-[120px] font-black leading-none text-transparent bg-clip-text bg-gradient-to-r from-zinc-900 to-zinc-600 drop-shadow-sm select-none">
            404
          </div>
          <motion.div 
            animate={{ rotate: 360 }}
            transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
            className="absolute -top-4 -right-8 text-[#635BFF]/20 pointer-events-none"
          >
            <Search size={80} strokeWidth={1.5} />
          </motion.div>
        </motion.div>

        <h1 className="text-3xl font-extrabold text-zinc-900 tracking-tight mb-4">
          Page Not Found
        </h1>
        
        <p className="text-zinc-500 text-lg mb-10 max-w-md mx-auto">
          The page you are looking for might have been removed, had its name changed, or is temporarily unavailable.
        </p>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <button 
            onClick={() => router.back()}
            className="w-full sm:w-auto flex items-center justify-center gap-2 px-6 py-3 bg-white border border-zinc-200 text-zinc-700 font-bold rounded-xl shadow-sm hover:shadow-md hover:bg-zinc-50 transition-all group"
          >
            <ArrowLeft size={18} className="group-hover:-translate-x-1 transition-transform" /> 
            Go Back
          </button>
          
          <Link 
            href="/"
            className="w-full sm:w-auto flex items-center justify-center gap-2 px-6 py-3 bg-[#635BFF] text-white font-bold rounded-xl shadow-sm shadow-[#635BFF]/20 hover:shadow-md hover:bg-[#5249E5] hover:-translate-y-0.5 transition-all group"
          >
            <Home size={18} className="group-hover:scale-110 transition-transform" />
            Back to Home
          </Link>
        </div>

      </motion.div>

      {/* Helpful Links at bottom */}
      <motion.div 
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.6 }}
        className="absolute bottom-8 flex items-center gap-6 text-sm font-semibold text-zinc-400"
      >
        <Link href="/help" className="flex items-center gap-1.5 hover:text-zinc-600 transition-colors">
          <HelpCircle size={14} /> Help Center
        </Link>
        <Link href="/contact" className="hover:text-zinc-600 transition-colors">Contact Support</Link>
      </motion.div>

    </div>
  );
}
