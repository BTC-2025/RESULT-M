"use client";

import { useState, use, useEffect } from "react";
import Link from "next/link";
import { motion, AnimatePresence } from "framer-motion";
import { 
  ArrowLeft, Plus, Download, Undo2, Redo2, Filter, 
  ArrowUpDown, LayoutGrid, Eye, EyeOff, Save, Trash2, 
  X, Check, Lock, Globe, FileSpreadsheet, Search, Info, HelpCircle, Settings
} from "lucide-react";

import { api } from "@/lib/api";

interface PageProps {
  params: Promise<{ id: string; sessionId: string }>;
}

export default function DatasetRecordsPage({ params }: PageProps) {
  const resolvedParams = use(params);
  const datasetId = resolvedParams.id;
  const sessionId = resolvedParams.sessionId;

  const [columns, setColumns] = useState<any[]>([]);
  const [rows, setRows] = useState<{ id: string; originalId?: string, cells: Record<string, any> }[]>([]);
  const [history, setHistory] = useState<{ id: string; originalId?: string, cells: Record<string, any> }[][]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedRow, setSelectedRow] = useState<{ id: string; originalId?: string, cells: Record<string, any> } | null>(null);
  const [editingCell, setEditingCell] = useState<{ rowId: string, colId: string } | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isPublishing, setIsPublishing] = useState(false);

  useEffect(() => {
    async function loadRecords() {
      try {
        const response = await api.datasets.getRecords(datasetId);
        const fetchedRecords = response.content || [];
        
        if (fetchedRecords.length > 0) {
          // Extract columns from the first record's dataPayload
          const firstPayload = fetchedRecords[0].dataPayload || {};
          const dynamicColumns = Object.keys(firstPayload).map((key, idx) => ({
            id: key,
            name: key.charAt(0).toUpperCase() + key.slice(1).replace(/_/g, ' '),
            type: typeof firstPayload[key] === 'number' ? 'Number' : 'Text',
            width: 150
          }));
          setColumns(dynamicColumns);
          
          const dynamicRows = fetchedRecords.map((r: any, idx: number) => ({
            id: `row-${idx}`,
            originalId: r.id,
            cells: r.dataPayload || {}
          }));
          setRows(dynamicRows);
          setHistory([dynamicRows]);
          setHistoryIndex(0);
        } else {
          // Empty dataset fallback
          setColumns([
             { id: "col-1", name: "Column 1", type: "Text", width: 150 },
             { id: "col-2", name: "Column 2", type: "Text", width: 150 }
          ]);
          setRows([]);
        }
      } catch (error) {
        console.error("Failed to load records:", error);
      } finally {
        setIsLoading(false);
      }
    }
    loadRecords();
  }, [datasetId]);

  // Save state to undo/redo history
  const pushToHistory = (newRows: { id: string; originalId?: string, cells: Record<string, any> }[]) => {
    const updatedHistory = history.slice(0, historyIndex + 1);
    setHistory([...updatedHistory, newRows]);
    setHistoryIndex(updatedHistory.length);
  };

  const handleUndo = () => {
    if (historyIndex > 0) {
      setHistoryIndex(historyIndex - 1);
      setRows(history[historyIndex - 1]);
    }
  };

  const handleRedo = () => {
    if (historyIndex < history.length - 1) {
      setHistoryIndex(historyIndex + 1);
      setRows(history[historyIndex + 1]);
    }
  };

  // Add row
  const handleAddRow = () => {
    const newRow = {
      id: `row-${Date.now()}`,
      cells: columns.reduce((acc, col) => {
        acc[col.id] = col.type === "Number" ? 0 : col.type === "Select" ? "Select Option" : "";
        return acc;
      }, {} as Record<string, any>),
    };
    const updatedRows = [...rows, newRow];
    setRows(updatedRows);
    pushToHistory(updatedRows);
  };

  // Add column
  const handleAddColumn = () => {
    const newColId = `col-${Date.now()}`;
    const newCol = { id: newColId, name: `New Column ${columns.length + 1}`, type: "Text", width: 150 };
    setColumns([...columns, newCol]);
    
    const updatedRows = rows.map(r => ({
      ...r,
      cells: { ...r.cells, [newColId]: "" }
    }));
    setRows(updatedRows);
    pushToHistory(updatedRows);
  };

  // Cell edit value commit
  const handleCellChange = (rowId: string, colId: string, value: any) => {
    const updatedRows = rows.map(r => {
      if (r.id === rowId) {
        return {
          ...r,
          cells: { ...r.cells, [colId]: value }
        };
      }
      return r;
    });
    setRows(updatedRows);
    pushToHistory(updatedRows);
  };

  const filteredRows = rows.filter(r => {
    return Object.values(r.cells).some(val => 
      String(val).toLowerCase().includes(searchQuery.toLowerCase())
    );
  });

  const handlePublish = async () => {
    setIsPublishing(true);
    try {
      // 1. New Rows
      const newRows = rows.filter(r => !r.originalId);
      // 2. Modified Rows
      const originalRowsMap = new Map(history[0].map(r => [r.originalId, r]));
      const modifiedRows = rows.filter(r => {
        if (!r.originalId) return false;
        const orig = originalRowsMap.get(r.originalId);
        return orig && JSON.stringify(orig.cells) !== JSON.stringify(r.cells);
      });
      // 3. Deleted Rows
      const currentRowIds = new Set(rows.map(r => r.originalId).filter(Boolean));
      const deletedIds = history[0]
        .map(r => r.originalId)
        .filter((id): id is string => Boolean(id) && !currentRowIds.has(id));

      // Process DELETES
      for (const id of deletedIds) {
        await api.datasets.deleteRecord(id);
      }
      
      // Process UPDATES
      for (const row of modifiedRows) {
        if (row.originalId) {
          await api.datasets.updateRecord(row.originalId, { data: row.cells });
        }
      }

      // Process CREATES
      for (const row of newRows) {
        await api.datasets.createRecord(datasetId, { data: row.cells });
      }

      // Reload to get actual IDs
      const response = await api.datasets.getRecords(datasetId);
      const fetchedRecords = response.content || [];
      const dynamicRows = fetchedRecords.map((r: any, idx: number) => ({
        id: `row-${idx}`,
        originalId: r.id,
        cells: r.dataPayload || {}
      }));
      setRows(dynamicRows);
      setHistory([dynamicRows]);
      setHistoryIndex(0);
      alert("Successfully published changes!");
    } catch (err: any) {
      console.error(err);
      alert("Error publishing changes: " + err.message);
    } finally {
      setIsPublishing(false);
    }
  };

  return (
    <div className="space-y-6 font-sans pb-16">
      
      {/* 1. BREADCRUMBS & HEADER */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-zinc-200/60 pb-6">
        <div>
          <div className="flex items-center gap-2 text-zinc-400 text-xs font-semibold select-none mb-2">
            <Link href="/dashboard/datasets" className="hover:text-zinc-600">Datasets</Link>
            <span>/</span>
            <span className="text-zinc-500 font-bold">{datasetId}</span>
            <span>/</span>
            <span className="text-[#635BFF]">Records</span>
          </div>
          <h1 className="text-2xl font-extrabold tracking-tight text-zinc-950 flex items-center gap-3">
            Dataset Records Viewer
            <span className="text-[10px] font-black uppercase tracking-wider px-2.5 py-0.5 rounded-full bg-emerald-50 border border-emerald-100 text-emerald-600">
              Live
            </span>
          </h1>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={handlePublish}
            disabled={isPublishing}
            className="flex items-center gap-2 bg-[#635BFF] hover:bg-[#5249E5] text-white px-5 py-2.5 rounded-xl text-sm font-bold shadow-md shadow-[#635BFF]/10 transition-all active:scale-95 disabled:opacity-50"
          >
            <Save size={16} />
            {isPublishing ? "Publishing..." : "Publish Changes"}
          </button>
          <Link href="/dashboard/imports" className="flex items-center gap-2 bg-white border border-zinc-200 text-zinc-700 px-4 py-2.5 rounded-xl text-sm font-semibold hover:bg-zinc-50 transition-colors shadow-sm">
            <Download size={16} />
            Import CSV
          </Link>
        </div>
      </div>

      {/* 2. SPREADSHEET TOOLBAR */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-4 bg-white border border-zinc-200/80 p-3 rounded-2xl shadow-sm">
        
        {/* Operations */}
        <div className="flex flex-wrap items-center gap-2">
          <button 
            onClick={handleAddRow}
            className="flex items-center gap-1.5 px-3.5 py-2 hover:bg-zinc-50 rounded-xl text-zinc-700 font-semibold text-xs border border-zinc-200 shadow-sm transition-colors"
          >
            <Plus size={14} /> Add Row
          </button>
          <button 
            onClick={handleAddColumn}
            className="flex items-center gap-1.5 px-3.5 py-2 hover:bg-zinc-50 rounded-xl text-zinc-700 font-semibold text-xs border border-zinc-200 shadow-sm transition-colors"
          >
            <Plus size={14} /> Add Column
          </button>
          <Link
            href={`/dashboard/${sessionId}/datasets/${datasetId}/schema`}
            className="flex items-center gap-1.5 px-3.5 py-2 hover:bg-zinc-50 rounded-xl text-zinc-700 font-semibold text-xs border border-zinc-200 shadow-sm transition-colors"
          >
            <Settings size={14} /> Schema Editor
          </Link>
          <div className="h-5 w-px bg-zinc-200 mx-2 hidden sm:block"></div>
          <button className="flex items-center gap-1.5 px-3.5 py-2 hover:bg-zinc-50 rounded-xl text-zinc-600 font-semibold text-xs transition-colors"><Filter size={14} /> Filter</button>
          <button className="flex items-center gap-1.5 px-3.5 py-2 hover:bg-zinc-50 rounded-xl text-zinc-600 font-semibold text-xs transition-colors"><ArrowUpDown size={14} /> Sort</button>
        </div>

        {/* Search & History */}
        <div className="flex items-center justify-between sm:justify-end gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400" size={14} />
            <input 
              type="text" 
              placeholder="Query cells..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="bg-zinc-50 border border-zinc-200 focus:border-[#635BFF]/30 focus:bg-white pl-9 pr-3 py-1.5 rounded-xl text-xs font-semibold outline-none transition-all w-48"
            />
          </div>

          <div className="flex items-center bg-zinc-100 p-0.5 rounded-lg">
            <button 
              onClick={handleUndo}
              disabled={historyIndex < 0}
              className="p-1.5 text-zinc-600 hover:text-zinc-950 disabled:opacity-30 disabled:hover:text-zinc-600 transition-colors"
              title="Undo"
            >
              <Undo2 size={16} />
            </button>
            <button 
              onClick={handleRedo}
              disabled={historyIndex >= history.length - 1}
              className="p-1.5 text-zinc-600 hover:text-zinc-950 disabled:opacity-30 disabled:hover:text-zinc-600 transition-colors"
              title="Redo"
            >
              <Redo2 size={16} />
            </button>
          </div>
        </div>

      </div>

      {/* 3. AIRTABLE-STYLE GRID SPREADSHEET */}
      <div className="bg-white border border-zinc-200 rounded-3xl overflow-hidden shadow-sm flex flex-col">
        <div className="overflow-x-auto overflow-y-hidden">
          <table className="w-full border-collapse text-xs select-none">
            <thead>
              <tr className="border-b border-zinc-200 bg-zinc-50 text-zinc-500 font-extrabold uppercase tracking-wide">
                <th className="px-4 py-3.5 border-r border-zinc-200 w-12 text-center">#</th>
                {columns.map(col => (
                  <th 
                    key={col.id} 
                    style={{ width: col.width }}
                    className="px-4 py-3.5 border-r border-zinc-200 font-bold"
                  >
                    <div className="flex items-center justify-between">
                      <span>{col.name}</span>
                      <span className="text-[10px] lowercase text-zinc-400 font-medium">{col.type}</span>
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filteredRows.map((row, idx) => (
                <tr key={row.id} className="border-b border-zinc-100 hover:bg-zinc-50/30 group">
                  
                  {/* Index / Checkbox cell */}
                  <td className="px-4 py-2.5 border-r border-zinc-200 bg-zinc-50/50 text-center font-bold text-zinc-400 cursor-pointer" onClick={() => setSelectedRow(row)}>
                    {idx + 1}
                  </td>

                  {/* Dynamic cells */}
                  {columns.map(col => {
                    const cellValue = row.cells[col.id];
                    const isEditing = editingCell?.rowId === row.id && editingCell?.colId === col.id;
                    return (
                      <td 
                        key={col.id}
                        onDoubleClick={() => setEditingCell({ rowId: row.id, colId: col.id })}
                        className={`px-4 py-2 border-r border-zinc-100 transition-all font-medium text-zinc-800 relative cursor-text ${
                          isEditing ? "bg-indigo-50/10 ring-2 ring-indigo-500/20" : ""
                        }`}
                      >
                        {isEditing ? (
                          <input 
                            autoFocus
                            type={col.type === "Number" ? "number" : "text"}
                            value={cellValue}
                            onChange={(e) => handleCellChange(row.id, col.id, col.type === "Number" ? Number(e.target.value) : e.target.value)}
                            onBlur={() => setEditingCell(null)}
                            onKeyDown={(e) => e.key === "Enter" && setEditingCell(null)}
                            className="absolute inset-0 w-full h-full px-4 border-none bg-white font-semibold text-xs outline-none text-zinc-950"
                          />
                        ) : col.type === "Select" ? (
                          <span className={`inline-flex px-2 py-0.5 rounded-full font-bold text-[10px] ${
                            cellValue === "Eligible" ? "bg-emerald-50 text-emerald-600 border border-emerald-100" :
                            cellValue === "Ineligible" ? "bg-rose-50 text-rose-600 border border-rose-100" :
                            "bg-amber-50 text-amber-600 border border-amber-100"
                          }`}>
                            {String(cellValue)}
                          </span>
                        ) : (
                          <span>{String(cellValue)}</span>
                        )}
                      </td>
                    );
                  })}

                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* 4. ROW INSPECTOR DETAILS DRAWER */}
      <AnimatePresence>
        {selectedRow && (
          <>
            <motion.div 
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setSelectedRow(null)}
              className="fixed inset-0 bg-zinc-950/40 backdrop-blur-sm z-50"
            />
            <motion.div 
              initial={{ x: "100%" }}
              animate={{ x: 0 }}
              exit={{ x: "100%" }}
              transition={{ type: "spring", damping: 30, stiffness: 200 }}
              className="fixed top-0 right-0 bottom-0 w-full max-w-lg bg-white border-l border-zinc-200 shadow-2xl z-50 flex flex-col text-zinc-900"
            >
              {/* Header */}
              <div className="p-6 border-b border-zinc-100 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-primary/10 text-primary rounded-xl flex items-center justify-center"><FileSpreadsheet size={20}/></div>
                  <div>
                    <h3 className="text-lg font-bold">Row Inspection</h3>
                    <p className="text-zinc-400 text-xs mt-0.5">Inspecting row ID: {selectedRow.id}</p>
                  </div>
                </div>
                <button onClick={() => setSelectedRow(null)} className="p-2 text-zinc-400 hover:text-zinc-900 bg-zinc-50 rounded-lg"><X size={20}/></button>
              </div>

              {/* Body */}
              <div className="flex-1 overflow-y-auto p-6 space-y-6">
                
                {/* Inputs generated dynamically */}
                <div className="space-y-4">
                  <h4 className="text-xs font-black uppercase text-zinc-400 tracking-wider">Field Record Details</h4>
                  {columns.map(col => (
                    <div key={col.id} className="bg-zinc-50 border border-zinc-200/50 p-4 rounded-2xl">
                      <span className="text-[10px] font-black uppercase tracking-wider text-zinc-400 block">{col.name}</span>
                      <span className="text-sm font-bold text-zinc-950 block mt-1">{String(selectedRow.cells[col.id])}</span>
                    </div>
                  ))}
                </div>

                {/* Timeline mock */}
                <div>
                  <h4 className="text-xs font-black uppercase text-zinc-400 tracking-wider mb-4">Audit Trail Logs</h4>
                  <div className="space-y-4">
                    {[
                      { title: "Record updated", time: "1 hour ago", author: "Dr. A. Kurian", detail: "Changed Written Score score value." },
                      { title: "Record created", time: "3 days ago", author: "CSV Parser Service", detail: "Parsed line 12 values from sheet." }
                    ].map((activity, idx) => (
                      <div key={idx} className="flex gap-3 text-xs">
                        <div className="relative flex flex-col items-center">
                          <div className="w-2 h-2 bg-primary/20 border border-primary text-primary rounded-full mt-1 shrink-0" />
                          {idx !== 1 && <div className="w-0.5 flex-1 bg-zinc-200 my-1" />}
                        </div>
                        <div>
                          <span className="font-bold text-zinc-900 block">{activity.title}</span>
                          <span className="text-zinc-500 block leading-relaxed">{activity.detail}</span>
                          <span className="text-[10px] text-zinc-400 block mt-0.5">{activity.time} • by {activity.author}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

              </div>

              {/* Footer */}
              <div className="p-6 border-t border-zinc-100 bg-zinc-50 flex items-center justify-end gap-3">
                <button onClick={() => setSelectedRow(null)} className="px-5 py-2.5 bg-zinc-950 text-white rounded-xl text-sm font-semibold hover:bg-zinc-800 transition-all">Done</button>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>

    </div>
  );
}
