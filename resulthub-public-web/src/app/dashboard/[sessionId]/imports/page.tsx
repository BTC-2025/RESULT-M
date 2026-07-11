"use client";

import { useState, useEffect, ChangeEvent } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import { 
  Upload, FileSpreadsheet, CheckCircle2, AlertTriangle, 
  Trash2, ArrowDownToLine, RefreshCw, Layers, Sparkles, 
  Download, Play, Database, History, HelpCircle, X
} from "lucide-react";
import { api } from "@/lib/api";
import { useWorkspace } from "../WorkspaceContext";

const MOCK_VALIDATION_ERRORS = [
  { id: "err-1", line: 42, column: "Written Score", error: "Field must be a positive decimal.", value: "-24.5" },
];

export default function CSVImportCenter() {
  const { activeWorkspace } = useWorkspace();
  const [queue, setQueue] = useState<any[]>([]);

  const loadJobs = async () => {
    if (!activeWorkspace?.id) return;
    try {
      const res = await api.imports.getWorkspaceImports(activeWorkspace.id, 0, 50);
      if (res.content) {
        const mapped = res.content.map((job: any) => ({
          id: job.id,
          filename: job.filename,
          datasetName: job.datasetName || "Unknown Dataset",
          size: "Uploaded",
          progress: job.status === "COMPLETED" || job.status === "FAILED" ? 100 : 50,
          status: job.status,
          rows: job.totalRows || 0,
          errors: job.failedRows || 0,
          date: new Date(job.createdAt).toLocaleString(),
        }));
        setQueue(mapped);
      }
    } catch (e) {
      console.error("Failed to load import jobs", e);
    }
  };

  useEffect(() => {
    loadJobs();
  }, [activeWorkspace?.id]);
  const [datasets, setDatasets] = useState<any[]>([]);
  const [selectedDatasetId, setSelectedDatasetId] = useState("");
  const [selectedFile, setSelectedFile] = useState<{ file: File, name: string, size: string } | null>(null);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [uploadState, setUploadState] = useState<"idle" | "parsing" | "verifying" | "done" | "error">("idle");
  const [activeTab, setActiveTab] = useState<"queue" | "errors">("queue");
  const [errorMessage, setErrorMessage] = useState("");

  useEffect(() => {
    if (activeWorkspace?.id) {
      api.datasets.getByWorkspace(activeWorkspace.id, 0, 100)
        .then(res => setDatasets(res.content || []))
        .catch(console.error);
    }
  }, [activeWorkspace]);

  // Handle file selection
  const handleFileUpload = (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setSelectedFile({ file, name: file.name, size: `${(file.size / (1024 * 1024)).toFixed(2)} MB` });
  };

  const startIngestionSimulator = async () => {
    if (!selectedFile || !selectedDatasetId) return;

    setIsUploading(true);
    setUploadState("parsing");
    setUploadProgress(20);
    setErrorMessage("");

    try {
      const formData = new FormData();
      formData.append("file", selectedFile.file);

      const response = await api.datasets.uploadCsv(selectedDatasetId, formData);
      setUploadProgress(100);
      setUploadState("done");
      
      await loadJobs();
      setSelectedFile(null);
      setUploadState("idle");
    } catch (err: any) {
      setUploadState("error");
      setErrorMessage(err.message || "Failed to upload CSV");
    } finally {
      setIsUploading(false);
    }
  };

  return (
    <div className="space-y-8 font-sans pb-16">
      
      {/* 1. HEADER SECTION */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-zinc-200/60 pb-6">
        <div>
          <div className="flex items-center gap-2 text-zinc-400 text-xs font-semibold select-none mb-2">
            <Link href={`/dashboard/${activeWorkspace?.id}/datasets`} className="hover:text-zinc-600">Datasets</Link>
            <span>/</span>
            <span className="text-[#635BFF]">CSV Import Center</span>
          </div>
          <h1 className="text-3xl font-extrabold tracking-tight text-zinc-950">CSV Import Center</h1>
          <p className="text-zinc-500 text-sm mt-1">Enterprise data ingestion. Upload spreadsheets, run background parsing, and resolve validation errors.</p>
        </div>
      </div>

      {/* 2. UPLOAD ZONE CONTAINER */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* Upload Dropzone: 66% width */}
        <div className="lg:col-span-2 space-y-6">
          <div className="bg-white border border-zinc-200/80 rounded-3xl p-8 shadow-sm flex flex-col items-center justify-center min-h-[300px] relative overflow-hidden group">
            
            {/* Interactive Background Glow */}
            <div className="absolute inset-0 bg-[#635BFF]/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none" />

            {!selectedFile ? (
              <div className="text-center space-y-4 relative z-10 flex flex-col items-center">
                <div className="w-16 h-16 bg-zinc-50 rounded-2xl flex items-center justify-center border border-zinc-100 text-zinc-400 group-hover:scale-105 transition-transform duration-300">
                  <Upload size={32} className="group-hover:text-[#635BFF] transition-colors" />
                </div>
                <div>
                  <label htmlFor="file-upload" className="font-extrabold text-zinc-950 hover:text-[#635BFF] transition-colors cursor-pointer text-base block">
                    Upload a spreadsheet file
                  </label>
                  <p className="text-zinc-500 text-xs mt-1">Select a CSV file to import records</p>
                </div>
                <input 
                  id="file-upload" 
                  type="file" 
                  accept=".csv" 
                  onChange={handleFileUpload} 
                  className="hidden" 
                />
              </div>
            ) : (
              <div className="text-center space-y-6 relative z-10 w-full max-w-md">
                <div className="flex items-center gap-4 bg-zinc-50 border border-zinc-200 p-4 rounded-2xl text-left">
                  <div className="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-100 text-[#635BFF] flex items-center justify-center shrink-0">
                    <FileSpreadsheet size={20} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="font-bold text-zinc-950 text-sm block truncate">{selectedFile.name}</span>
                    <span className="text-[11px] text-zinc-400 block mt-0.5">{selectedFile.size}</span>
                  </div>
                  <button onClick={() => setSelectedFile(null)} className="p-1 hover:bg-zinc-200 rounded-lg text-zinc-400 hover:text-zinc-900 transition-colors">
                    <X size={16} />
                  </button>
                </div>

                <div className="text-left space-y-2">
                  <label className="text-xs font-bold text-zinc-700">Target Dataset</label>
                  <select 
                    value={selectedDatasetId}
                    onChange={(e) => setSelectedDatasetId(e.target.value)}
                    className="w-full bg-zinc-50 border border-zinc-200 px-3 py-2 rounded-xl text-sm font-semibold outline-none"
                  >
                    <option value="">Select a dataset...</option>
                    {datasets.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
                  </select>
                </div>

                {isUploading && (
                  <div className="space-y-2">
                    <div className="flex justify-between text-xs font-semibold text-zinc-500">
                      <span>{uploadState === "parsing" ? "Uploading and Parsing..." : "Verifying..."}</span>
                      <span>{uploadProgress}%</span>
                    </div>
                    <div className="h-2 bg-zinc-100 rounded-full overflow-hidden">
                      <div 
                        style={{ width: `${uploadProgress}%` }}
                        className="h-full bg-gradient-to-r from-[#635BFF] to-purple-500 rounded-full transition-all"
                      />
                    </div>
                  </div>
                )}
                
                {uploadState === "error" && (
                  <div className="text-xs font-bold text-red-500 bg-red-50 p-2 rounded-lg border border-red-100">
                    Error: {errorMessage}
                  </div>
                )}

                <div className="flex items-center justify-center gap-3">
                  <button 
                    onClick={() => setSelectedFile(null)} 
                    disabled={isUploading}
                    className="px-4 py-2 border border-zinc-200 text-zinc-700 bg-white rounded-xl text-xs font-semibold hover:bg-zinc-50 disabled:opacity-40 transition-all"
                  >
                    Reset
                  </button>
                  <button 
                    onClick={startIngestionSimulator}
                    disabled={isUploading || !selectedDatasetId}
                    className="flex items-center gap-2 bg-[#635BFF] hover:bg-[#5249E5] text-white px-5 py-2 rounded-xl text-xs font-bold shadow-md shadow-[#635BFF]/10 transition-all active:scale-95 disabled:opacity-40"
                  >
                    <Play size={14} /> Start Ingestion
                  </button>
                </div>
              </div>
            )}

          </div>
        </div>

        {/* Validation Metrics Cards */}
        <div className="space-y-6">
          <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm space-y-4">
            <h3 className="font-bold text-zinc-950 text-sm flex items-center gap-2">
              <Layers size={16} className="text-[#635BFF]" /> Ingestion Pipeline
            </h3>
            <p className="text-zinc-500 text-xs font-medium leading-relaxed">
              ResultHub processes data asynchronously. Once uploaded, the records are validated against the dataset's JSON Schema mapping.
            </p>
            <div className="h-px bg-zinc-100" />
            <div className="grid grid-cols-2 gap-4 text-center">
              <div className="bg-zinc-50 border border-zinc-200/40 p-4 rounded-2xl">
                <span className="text-[10px] font-black uppercase tracking-wider text-zinc-400">Errors Flagged</span>
                <span className="text-2xl font-black block text-rose-600 mt-1">4</span>
                <span className="text-[10px] text-zinc-500 font-medium block mt-0.5">Line validations</span>
              </div>
              <div className="bg-zinc-50 border border-zinc-200/40 p-4 rounded-2xl">
                <span className="text-[10px] font-black uppercase tracking-wider text-zinc-400">Total Ingested</span>
                <span className="text-2xl font-black block text-emerald-600 mt-1">42.3k</span>
                <span className="text-[10px] text-zinc-500 font-medium block mt-0.5">Rows live today</span>
              </div>
            </div>
          </div>
        </div>

      </div>

      {/* 3. SECTION CONTROL TABS */}
      <div className="bg-white border border-zinc-200/80 rounded-3xl p-6 shadow-sm space-y-6">
        <div className="flex items-center justify-between border-b border-zinc-100 pb-4">
          <div className="flex gap-4 border-b border-transparent">
            <button 
              onClick={() => setActiveTab("queue")}
              className={`pb-4 text-sm font-bold transition-all relative ${
                activeTab === "queue" ? "text-[#635BFF]" : "text-zinc-400 hover:text-zinc-900"
              }`}
            >
              Ingestion Queue
              {activeTab === "queue" && (
                <motion.div layoutId="activeTabIndicator" className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#635BFF] rounded-full" />
              )}
            </button>
            <button 
              onClick={() => setActiveTab("errors")}
              className={`pb-4 text-sm font-bold transition-all relative flex items-center gap-2 ${
                activeTab === "errors" ? "text-[#635BFF]" : "text-zinc-400 hover:text-zinc-900"
              }`}
            >
              Validation Warnings
              <span className="bg-rose-50 text-rose-600 border border-rose-100 rounded-md px-1.5 py-0.5 text-[10px] font-black">4</span>
              {activeTab === "errors" && (
                <motion.div layoutId="activeTabIndicator" className="absolute bottom-0 left-0 right-0 h-0.5 bg-[#635BFF] rounded-full" />
              )}
            </button>
          </div>

          {activeTab === "errors" && (
            <button className="flex items-center gap-2 text-xs font-bold text-rose-600 bg-rose-50 border border-rose-100 px-3.5 py-2 rounded-xl hover:bg-rose-100 transition-colors">
              <Download size={14} /> Download Error CSV
            </button>
          )}
        </div>

        {/* Dynamic content tables */}
        <AnimatePresence mode="wait">
          {activeTab === "queue" ? (
            <motion.div 
              key="queue"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              className="overflow-x-auto"
            >
              <table className="w-full text-left text-sm whitespace-nowrap border-collapse">
                <thead>
                  <tr className="border-b border-zinc-200 text-zinc-500 font-bold select-none">
                    <th className="pb-4">Source Filename</th>
                    <th className="pb-4">Target Dataset</th>
                    <th className="pb-4">File Size</th>
                    <th className="pb-4">Rows processed</th>
                    <th className="pb-4">Errors Found</th>
                    <th className="pb-4">Uploaded at</th>
                    <th className="pb-4 text-right">Pipeline Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-100">
                  {queue.map(job => (
                    <tr key={job.id} className="hover:bg-zinc-50/50 transition-colors">
                      <td className="py-4 font-bold text-zinc-950 flex items-center gap-2">
                        <FileSpreadsheet size={16} className="text-zinc-400" />
                        {job.filename}
                      </td>
                      <td className="py-4 text-zinc-600 font-semibold">{job.datasetName}</td>
                      <td className="py-4 text-zinc-500 font-medium">{job.size}</td>
                      <td className="py-4 text-zinc-900 font-extrabold">{job.rows.toLocaleString()}</td>
                      <td className={`py-4 font-extrabold ${job.errors > 0 ? "text-rose-600" : "text-zinc-400"}`}>{job.errors}</td>
                      <td className="py-4 text-zinc-400 font-medium">{job.date}</td>
                      <td className="py-4 text-right">
                        <span className={`inline-flex items-center gap-1 text-[10px] font-black uppercase tracking-wider px-2.5 py-1 rounded-full border ${
                          job.status === "Success" ? "bg-emerald-50 text-emerald-600 border-emerald-100" :
                          job.status === "Failed" ? "bg-rose-50 text-rose-600 border-rose-100" : "bg-amber-50 text-amber-600 border-amber-100"
                        }`}>
                          {job.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </motion.div>
          ) : (
            <motion.div 
              key="errors"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              className="space-y-4"
            >
              <div className="bg-rose-50/50 border border-rose-100 rounded-2xl p-4 flex gap-3 text-xs text-rose-700">
                <AlertTriangle size={18} className="shrink-0 mt-0.5" />
                <p className="leading-relaxed font-semibold">Validation checks identified 4 rows violating category schemas. Please correct these cells in your local spreadsheet and retry uploader queues, or download the corrected rows only.</p>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm whitespace-nowrap border-collapse">
                  <thead>
                    <tr className="border-b border-zinc-200 text-zinc-500 font-bold select-none">
                      <th className="pb-4">Row Index</th>
                      <th className="pb-4">Column Header</th>
                      <th className="pb-4">Invalid Value</th>
                      <th className="pb-4">Validation Failure Rule Details</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-zinc-100">
                    {MOCK_VALIDATION_ERRORS.map(err => (
                      <tr key={err.id} className="hover:bg-zinc-50/50 transition-colors">
                        <td className="py-4 font-extrabold text-zinc-900">Line {err.line}</td>
                        <td className="py-4 font-bold text-[#635BFF]">{err.column}</td>
                        <td className="py-4 font-mono text-zinc-500 bg-zinc-50 border border-zinc-100 px-2 py-0.5 rounded text-xs w-fit inline-block my-3">{err.value}</td>
                        <td className="py-4 text-zinc-500 font-medium">{err.error}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>

    </div>
  );
}
