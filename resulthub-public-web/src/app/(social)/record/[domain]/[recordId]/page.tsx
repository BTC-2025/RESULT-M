"use client";

import { useEffect, useState, useRef } from "react";
import { useParams } from "next/navigation";
import html2canvas from "html2canvas";
import { api } from "@/lib/api";

export default function RecordDetailPage() {
  const params = useParams();
  const domain = (params.domain as string) || "academic";
  const recordId = params.recordId as string;
  const cardRef = useRef<HTMLDivElement>(null);
  
  const [downloading, setDownloading] = useState(false);

  const [recordData, setRecordData] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchRecord();
  }, [recordId]);

  const fetchRecord = async () => {
    try {
      const res = await api.datasets.getRecord(recordId);
      setRecordData(res.data);
    } catch (error) {
      console.error("Failed to load record details", error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDownload = async () => {
    if (!cardRef.current) return;
    setDownloading(true);
    try {
      const canvas = await html2canvas(cardRef.current, {
        scale: 2,
        backgroundColor: "#ffffff",
        logging: false,
      });
      const image = canvas.toDataURL("image/png");
      const a = document.createElement("a");
      a.href = image;
      a.download = `ResultHub_Record_${recordId}.png`;
      a.click();
    } catch (e) {
      console.error(e);
    } finally {
      setDownloading(false);
    }
  };

  if (isLoading) {
    return <div className="text-center py-20 text-muted-foreground font-bold">Loading record...</div>;
  }

  if (!recordData) {
    return <div className="text-center py-20 text-muted-foreground font-bold">Record not found or access denied.</div>;
  }

  return (
    <div className="mx-auto max-w-3xl px-4 py-12 w-full">
        
        <div className="mb-6 flex justify-between items-end">
          <div>
             <h1 className="text-sm font-bold text-muted-foreground uppercase tracking-wider mb-1">Official Record Viewer</h1>
             <h2 className="text-2xl font-black text-foreground">Verification Portal</h2>
          </div>
        </div>

        {/* The Card we will capture with html2canvas */}
        <div 
          ref={cardRef} 
          className="bg-white rounded-xl shadow-lg border border-muted/50 overflow-hidden mb-8"
        >
          {/* Header */}
          <div className="p-8 border-b border-muted/30">
             <div className="flex items-center gap-6">
                <div className="w-16 h-16 bg-primary/10 rounded-2xl flex items-center justify-center text-primary">
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                </div>
                <div>
                  <h2 className="text-2xl font-black text-slate-900 uppercase tracking-tight">{domain.toUpperCase()}</h2>
                  <h3 className="text-sm font-bold text-orange-600 uppercase tracking-widest mt-1">B.E Semester 8 Results</h3>
                  <div className="text-[10px] font-black text-slate-400 tracking-[0.2em] mt-2">VERIFIED DATA RECORD</div>
                </div>
             </div>
          </div>

           {/* Record Data */}
          <div className="p-8 bg-slate-50/50">
             <div className="grid grid-cols-2 gap-y-6 gap-x-12">
               {Object.entries(recordData).map(([key, value]) => {
                 if (typeof value === 'object') return null; // skip nested objects for now
                 return (
                   <div key={key}>
                     <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-1">
                       {key.replace('_', ' ')}
                     </div>
                     <div className="text-sm font-black text-slate-900">
                       {value as string}
                     </div>
                   </div>
                 );
               })}
             </div>

             {/* Nested Data (If any subjects/nested object) */}
             {Object.entries(recordData).filter(([_, v]) => typeof v === 'object' && v !== null).map(([key, nestedObj]) => (
               <div key={key} className="mt-8 pt-6 border-t border-slate-200">
                 <div className="text-[11px] font-bold text-slate-400 uppercase tracking-wider mb-4">{key}</div>
                 <div className="space-y-3">
                   {Object.entries(nestedObj as object).map(([sub, data]) => (
                     <div key={sub} className="flex justify-between items-center bg-white p-3 rounded-lg border border-slate-200">
                       <span className="font-bold text-sm text-slate-800">{sub}</span>
                       <div className="flex gap-4">
                         <span className="text-xs font-black text-primary px-2 py-0.5 bg-primary/10 rounded">
                           {typeof data === 'object' ? JSON.stringify(data) : String(data)}
                         </span>
                       </div>
                     </div>
                   ))}
                 </div>
               </div>
             ))}
          </div>

          {/* Verification Footer */}
          <div className="p-8 bg-slate-900 text-white flex items-center gap-6">
             <div className="w-20 h-20 bg-white p-1 rounded-lg">
               {/* Fake QR Code */}
               <svg viewBox="0 0 100 100" fill="black" xmlns="http://www.w3.org/2000/svg">
                  <path d="M10,10 h30 v30 h-30 z M15,15 h20 v20 h-20 z M20,20 h10 v10 h-10 z" />
                  <path d="M60,10 h30 v30 h-30 z M65,15 h20 v20 h-20 z M70,20 h10 v10 h-10 z" />
                  <path d="M10,60 h30 v30 h-30 z M15,65 h20 v20 h-20 z M20,70 h10 v10 h-10 z" />
                  <path d="M50,50 h10 v10 h-10 z M70,60 h20 v10 h-20 z M60,80 h20 v10 h-20 z M80,50 h10 v40 h-10 z" />
               </svg>
             </div>
             <div>
               <div className="flex items-center gap-2 text-emerald-400 mb-2">
                 <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3"><polyline points="20 6 9 17 4 12"></polyline></svg>
                 <span className="text-[11px] font-black tracking-widest uppercase">Digitally Verified</span>
               </div>
               <p className="text-[10px] text-slate-400">Generated via ResultHub Universal Portal</p>
               <p className="text-[10px] text-slate-400 mt-1">Date: {new Date().toISOString().split('T')[0]} • ID: {recordId}</p>
             </div>
          </div>
        </div>

        {/* Action Buttons */}
        <button 
          onClick={handleDownload}
          disabled={downloading}
          className="w-full flex items-center justify-center gap-2 py-4 rounded-xl border-2 border-foreground text-foreground font-black tracking-wide hover:bg-foreground hover:text-background transition-colors"
        >
          {downloading ? (
             <span>GENERATING...</span>
          ) : (
            <>
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
              DOWNLOAD & SHARE
            </>
          )}
        </button>

    </div>
  );
}
