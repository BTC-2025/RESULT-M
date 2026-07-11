"use client";

import { useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { api } from "@/lib/api";
import { useWorkspace } from "../../WorkspaceContext";
import { 
  Plus, Trash2, ArrowLeft, ArrowRight, Eye, Code, CheckCircle, 
  HelpCircle, Settings, Lock, Sparkles, AlertCircle, Database, 
  Settings2, Sliders, Type, Key, Mail, Calendar, ToggleLeft, HelpCircle as HelpIcon,
  Check, Loader2
} from "lucide-react";

interface FieldItem {
  id: string;
  name: string;
  type: string;
  required: boolean;
  searchable: boolean;
  filterable: boolean;
  sortable: boolean;
}

export default function DatasetBuilderPage() {
  const [currentStep, setCurrentStep] = useState(1);
  const router = useRouter();
  const params = useParams();
  const { activeWorkspace } = useWorkspace();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMsg, setErrorMsg] = useState("");
  
  // Step 1: Info States
  const [name, setName] = useState("");
  const [desc, setDesc] = useState("");
  const [category, setCategory] = useState("Academic");
  const [tags, setTags] = useState("");
  const [visibility, setVisibility] = useState("Public");
  const [password, setPassword] = useState("");

  // Step 2: Schema Builder States
  const [fields, setFields] = useState<FieldItem[]>([
    { id: "f-1", name: "rollNumber", type: "Text", required: true, searchable: true, filterable: false, sortable: true },
    { id: "f-2", name: "studentName", type: "Text", required: true, searchable: true, filterable: false, sortable: true },
    { id: "f-3", name: "gpa", type: "Number", required: true, searchable: false, filterable: true, sortable: true },
  ]);

  const addField = () => {
    const newField: FieldItem = {
      id: `f-${Date.now()}`,
      name: `field_${fields.length + 1}`,
      type: "Text",
      required: false,
      searchable: false,
      filterable: false,
      sortable: false,
    };
    setFields([...fields, newField]);
  };

  const removeField = (id: string) => {
    setFields(fields.filter(f => f.id !== id));
  };

  const updateField = (id: string, updates: Partial<FieldItem>) => {
    setFields(fields.map(f => f.id === id ? { ...f, ...updates } : f));
  };

  // Convert field schemas to dynamic JSON Output
  const generateJSONSchema = () => {
    const properties: Record<string, any> = {};
    const requiredList: string[] = [];

    fields.forEach(f => {
      properties[f.name] = {
        type: f.type.toLowerCase() === "number" ? "number" : f.type.toLowerCase() === "boolean" ? "boolean" : "string",
        searchable: f.searchable,
        filterable: f.filterable,
        sortable: f.sortable,
      };
      if (f.required) {
        requiredList.push(f.name);
      }
    });

    return JSON.stringify({
      $schema: "http://json-schema.org/draft-07/schema#",
      title: name || "Untitled Dataset",
      description: desc,
      type: "object",
      properties,
      required: requiredList,
    }, null, 2);
  };

  const handlePublish = async () => {
    if (!activeWorkspace?.id) {
      setErrorMsg("Please select a valid workspace first.");
      return;
    }
    if (!name) {
      setErrorMsg("Dataset Name is required.");
      setCurrentStep(1);
      return;
    }

    // Map UI Category to DomainType Enum
    const categoryMap: any = {
      "Academic": "EDUCATION",
      "Healthcare": "HEALTHCARE",
      "Government": "GOVERNMENT",
      "Corporate": "BUSINESS",
      "Athletics": "SPORTS"
    };

    setIsSubmitting(true);
    setErrorMsg("");

    try {
      const dataset = await api.datasets.create(activeWorkspace.id, {
        name: name,
        slug: name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)+/g, ''),
        description: desc,
        domainType: categoryMap[category] || "CUSTOM"
      });
      
      // Generate Schema JSON object (not string)
      const properties: Record<string, any> = {};
      const requiredList: string[] = [];

      fields.forEach(f => {
        properties[f.name] = {
          type: f.type.toLowerCase() === "number" ? "number" : f.type.toLowerCase() === "boolean" ? "boolean" : "string",
          searchable: f.searchable,
          filterable: f.filterable,
          sortable: f.sortable,
        };
        if (f.required) {
          requiredList.push(f.name);
        }
      });

      const schemaDefinition = {
        $schema: "http://json-schema.org/draft-07/schema#",
        title: name || "Untitled Dataset",
        description: desc,
        type: "object",
        properties,
        required: requiredList,
      };

      // Send the JSON Schema to the schema endpoint
      await api.datasets.updateSchema(dataset.id, {
        schemaName: name + " Schema",
        schemaDefinition: schemaDefinition,
        isRequired: true
      });

      router.push(`/dashboard/${params.sessionId}/datasets`);
    } catch (err: any) {
      console.error("Create Dataset Error:", err);
      setErrorMsg(err.message || "Failed to create dataset");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-[1200px] mx-auto font-sans pb-16 space-y-8">
      
      {/* HEADER BAR */}
      <div className="flex items-center gap-4">
        <Link 
          href={`/dashboard/${params.sessionId}/datasets`}
          className="p-2 hover:bg-zinc-100 rounded-xl transition-colors text-zinc-500 hover:text-zinc-900"
        >
          <ArrowLeft size={20} />
        </Link>
        <div>
          <h1 className="text-2xl font-extrabold tracking-tight text-zinc-950">Dataset Creator</h1>
          <p className="text-zinc-500 text-xs mt-0.5">Design data schemas and publish custom databases in v1 format.</p>
        </div>
      </div>

      {/* STEP PROGRESS BAR */}
      <div className="bg-white border border-zinc-200/80 p-5 rounded-3xl shadow-sm flex items-center justify-between select-none">
        {[
          { step: 1, label: "Details & Metadata" },
          { step: 2, label: "Define Custom Fields" },
          { step: 3, label: "Schema Preview & Deploy" }
        ].map((item, index) => (
          <div key={item.step} className="flex items-center flex-1 last:flex-initial">
            <div className="flex items-center gap-3">
              <div className={`w-8 h-8 rounded-lg flex items-center justify-center font-bold text-sm border transition-all ${
                currentStep === item.step 
                  ? "bg-[#635BFF] text-white border-[#635BFF]" 
                  : currentStep > item.step 
                  ? "bg-emerald-50 text-emerald-600 border-emerald-200" 
                  : "bg-zinc-50 text-zinc-400 border-zinc-200"
              }`}>
                {currentStep > item.step ? <Check size={16} /> : item.step}
              </div>
              <span className={`text-sm font-semibold hidden md:block ${
                currentStep === item.step ? "text-zinc-950" : "text-zinc-400"
              }`}>
                {item.label}
              </span>
            </div>
            {index < 2 && (
              <div className="flex-1 h-px bg-zinc-200 mx-6 hidden md:block" />
            )}
          </div>
        ))}
      </div>

      {/* STEP RENDER PANELS */}
      <div className="bg-white border border-zinc-200/80 rounded-[32px] p-8 shadow-sm min-h-[450px] flex flex-col justify-between">
        <div className="space-y-6">
          
          {/* STEP 1: Details & Metadata */}
          {currentStep === 1 && (
            <motion.div 
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-6 max-w-2xl"
            >
              <div>
                <label className="block text-sm font-bold text-zinc-800 mb-2">Dataset Name</label>
                <input 
                  type="text" 
                  required
                  placeholder="e.g. TNPSC Group IV Merit List"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full bg-zinc-50 border border-zinc-200/80 focus:border-[#635BFF]/30 focus:bg-white px-4 py-3 rounded-xl text-sm font-medium outline-none transition-all"
                />
              </div>

              <div>
                <label className="block text-sm font-bold text-zinc-800 mb-2">Description</label>
                <textarea 
                  rows={4}
                  placeholder="Explain what data this covers, how records should be read, or compliance details..."
                  value={desc}
                  onChange={(e) => setDesc(e.target.value)}
                  className="w-full bg-zinc-50 border border-zinc-200/80 focus:border-[#635BFF]/30 focus:bg-white px-4 py-3 rounded-xl text-sm font-medium outline-none transition-all resize-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-bold text-zinc-800 mb-2">Category</label>
                  <select 
                    value={category}
                    onChange={(e) => setCategory(e.target.value)}
                    className="w-full bg-zinc-50 border border-zinc-200 px-3 py-2.5 rounded-xl text-sm font-semibold outline-none cursor-pointer"
                  >
                    {CATEGORIES.filter(c => c !== "All").map(cat => (
                      <option key={cat} value={cat}>{cat}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-bold text-zinc-800 mb-2">Tags (Comma Separated)</label>
                  <input 
                    type="text" 
                    placeholder="exams, 2026, tnpsc"
                    value={tags}
                    onChange={(e) => setTags(e.target.value)}
                    className="w-full bg-zinc-50 border border-zinc-200/80 focus:border-[#635BFF]/30 focus:bg-white px-4 py-2.5 rounded-xl text-sm font-medium outline-none transition-all"
                  />
                </div>
              </div>

              <div className="border-t border-zinc-100 pt-6 space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <span className="font-bold text-zinc-950 block text-sm">Workspace Visibility</span>
                    <span className="text-zinc-500 text-xs block">Public datasets are searchable by standard users.</span>
                  </div>
                  <select 
                    value={visibility}
                    onChange={(e) => setVisibility(e.target.value)}
                    className="bg-zinc-50 border border-zinc-200 px-3 py-2 rounded-xl text-sm font-semibold outline-none cursor-pointer"
                  >
                    <option value="Public">Public (Global search)</option>
                    <option value="Private">Private (Org Admins only)</option>
                    <option value="Password Protected">Password Protected</option>
                  </select>
                </div>

                {visibility === "Password Protected" && (
                  <motion.div 
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: "auto" }}
                    className="overflow-hidden"
                  >
                    <label className="block text-sm font-bold text-zinc-800 mb-2">Access Password</label>
                    <input 
                      type="password"
                      placeholder="Enter security key to access"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className="w-full max-w-sm bg-zinc-50 border border-zinc-200/80 focus:border-[#635BFF]/30 focus:bg-white px-4 py-2.5 rounded-xl text-sm font-medium outline-none transition-all"
                    />
                  </motion.div>
                )}
              </div>
            </motion.div>
          )}

          {/* STEP 2: Schema Builder */}
          {currentStep === 2 && (
            <motion.div 
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-6"
            >
              <div className="flex justify-between items-center">
                <div>
                  <h3 className="font-bold text-zinc-950 text-base">Schema Designer</h3>
                  <p className="text-zinc-500 text-xs mt-0.5">Define columns, select types, and configure search parameters.</p>
                </div>
                <button 
                  type="button" 
                  onClick={addField}
                  className="flex items-center gap-2 text-sm font-bold text-[#635BFF] hover:text-[#5249E5] bg-[#635BFF]/5 hover:bg-[#635BFF]/10 px-4 py-2.5 rounded-xl transition-all"
                >
                  <Plus size={16} /> Add Custom Field
                </button>
              </div>

              <div className="border border-zinc-200/80 rounded-2xl overflow-hidden bg-zinc-50/50">
                <div className="overflow-x-auto">
                  <table className="w-full text-left text-sm whitespace-nowrap">
                    <thead>
                      <tr className="border-b border-zinc-200 bg-zinc-100/50 text-zinc-500 font-bold select-none">
                        <th className="px-6 py-3.5">Field Name</th>
                        <th className="px-6 py-3.5">Type</th>
                        <th className="px-6 py-3.5 text-center">Required</th>
                        <th className="px-6 py-3.5 text-center">Searchable</th>
                        <th className="px-6 py-3.5 text-center">Filterable</th>
                        <th className="px-6 py-3.5 text-center">Sortable</th>
                        <th className="px-6 py-3.5 text-right w-12">Delete</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-zinc-200 bg-white">
                      {fields.map((f, i) => (
                        <tr key={f.id} className="hover:bg-zinc-50/30">
                          <td className="px-6 py-3">
                            <input 
                              type="text"
                              value={f.name}
                              onChange={(e) => updateField(f.id, { name: e.target.value })}
                              placeholder={`field_${i + 1}`}
                              className="bg-transparent font-semibold text-zinc-800 border-b border-transparent hover:border-zinc-200 focus:border-[#635BFF] outline-none py-1 transition-all"
                            />
                          </td>
                          <td className="px-6 py-3">
                            <select
                              value={f.type}
                              onChange={(e) => updateField(f.id, { type: e.target.value })}
                              className="bg-zinc-50 border border-zinc-200 px-2 py-1 rounded-lg font-medium text-xs text-zinc-700 outline-none"
                            >
                              {["Text", "Number", "Date", "Boolean", "Email", "URL"].map(opt => (
                                <option key={opt} value={opt}>{opt}</option>
                              ))}
                            </select>
                          </td>
                          <td className="px-6 py-3 text-center">
                            <input 
                              type="checkbox" 
                              checked={f.required} 
                              onChange={(e) => updateField(f.id, { required: e.target.checked })}
                              className="w-4 h-4 rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]"
                            />
                          </td>
                          <td className="px-6 py-3 text-center">
                            <input 
                              type="checkbox" 
                              checked={f.searchable} 
                              onChange={(e) => updateField(f.id, { searchable: e.target.checked })}
                              className="w-4 h-4 rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]"
                            />
                          </td>
                          <td className="px-6 py-3 text-center">
                            <input 
                              type="checkbox" 
                              checked={f.filterable} 
                              onChange={(e) => updateField(f.id, { filterable: e.target.checked })}
                              className="w-4 h-4 rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]"
                            />
                          </td>
                          <td className="px-6 py-3 text-center">
                            <input 
                              type="checkbox" 
                              checked={f.sortable} 
                              onChange={(e) => updateField(f.id, { sortable: e.target.checked })}
                              className="w-4 h-4 rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]"
                            />
                          </td>
                          <td className="px-6 py-3 text-right">
                            <button 
                              type="button" 
                              onClick={() => removeField(f.id)}
                              disabled={fields.length <= 1}
                              className="text-zinc-400 hover:text-red-600 disabled:opacity-30 disabled:hover:text-zinc-400 p-1 hover:bg-zinc-50 rounded"
                            >
                              <Trash2 size={16} />
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </motion.div>
          )}

          {/* STEP 3: Preview & Deploy */}
          {currentStep === 3 && (
            <motion.div 
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-6"
            >
              <div>
                <h3 className="font-bold text-zinc-950 text-base">Schema Verification</h3>
                <p className="text-zinc-500 text-xs mt-0.5">Verify your generic JSON Schema layout before committing deployment.</p>
              </div>

              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                
                {/* JSON Code block */}
                <div className="bg-zinc-50 rounded-3xl p-6 text-zinc-900 font-mono text-xs overflow-hidden shadow-inner border border-zinc-200 flex flex-col h-[350px]">
                  <div className="flex items-center justify-between pb-3 border-b border-zinc-200 text-zinc-500 mb-4 select-none shrink-0">
                    <span className="flex items-center gap-2"><Code size={14} className="text-[#635BFF]" /> json-schema.json</span>
                    <span className="text-[10px] uppercase font-bold text-zinc-400">v1 Spec</span>
                  </div>
                  <pre className="flex-1 overflow-auto text-indigo-700 font-medium leading-relaxed select-all">
                    <code>{generateJSONSchema()}</code>
                  </pre>
                </div>

                {/* Live mock input form generator */}
                <div className="bg-zinc-50 border border-zinc-200 p-6 rounded-3xl shadow-inner flex flex-col h-[350px] overflow-y-auto">
                  <div className="flex items-center gap-2 pb-3 border-b border-zinc-200 text-zinc-900 font-bold mb-6 select-none shrink-0">
                    <Eye size={16} className="text-[#635BFF]" />
                    <span>Live Mock Input Form</span>
                  </div>
                  <div className="space-y-4 flex-1">
                    {fields.map(f => (
                      <div key={f.id}>
                        <label className="block text-xs font-bold text-zinc-700 mb-1.5 flex items-center gap-1.5">
                          {f.name}
                          {f.required && <span className="text-red-500">*</span>}
                        </label>
                        {f.type === "Boolean" ? (
                          <input 
                            type="checkbox"
                            className="w-4 h-4 rounded border-zinc-300 text-[#635BFF] focus:ring-[#635BFF]"
                          />
                        ) : (
                          <input 
                            type={f.type === "Number" ? "number" : f.type === "Date" ? "date" : "text"}
                            disabled
                            placeholder={`Mock ${f.type.toLowerCase()} input...`}
                            className="w-full bg-white border border-zinc-200/80 px-3 py-2 rounded-xl text-xs outline-none cursor-not-allowed opacity-60"
                          />
                        )}
                      </div>
                    ))}
                  </div>
                </div>

              </div>
            </motion.div>
          )}

        </div>

        {/* STEP BUTTONS FOOTER */}
        <div className="flex items-center justify-between border-t border-zinc-100 pt-6 mt-8">
          <button
            type="button"
            onClick={() => setCurrentStep(prev => Math.max(1, prev - 1))}
            disabled={currentStep === 1}
            className="px-5 py-2.5 border border-zinc-200 text-zinc-700 bg-white rounded-xl text-sm font-semibold hover:bg-zinc-50 disabled:opacity-40 transition-all select-none"
          >
            Back
          </button>
          
          {currentStep < 3 ? (
            <button
              type="button"
              onClick={() => setCurrentStep(prev => Math.min(3, prev + 1))}
              className="flex items-center gap-2 bg-[#635BFF] hover:bg-[#5249E5] text-white px-5 py-2.5 rounded-xl text-sm font-bold shadow-md shadow-[#635BFF]/10 transition-all active:scale-95 select-none"
            >
              Continue <ArrowRight size={16} />
            </button>
          ) : (
            <div className="flex items-center gap-4">
              {errorMsg && <span className="text-red-500 text-sm font-semibold">{errorMsg}</span>}
              <button
                onClick={handlePublish}
                disabled={isSubmitting}
                className="flex items-center gap-2 bg-emerald-600 hover:bg-emerald-500 text-white px-6 py-2.5 rounded-xl text-sm font-bold shadow-md shadow-emerald-500/10 transition-all active:scale-95 select-none disabled:opacity-50"
              >
                {isSubmitting ? <Loader2 size={16} className="animate-spin" /> : <Sparkles size={16} />}
                {isSubmitting ? "Publishing..." : "Deploy & Publish"}
              </button>
            </div>
          )}
        </div>
      </div>

    </div>
  );
}

const CATEGORIES = ["All", "Academic", "Healthcare", "Government", "Corporate", "Athletics"];
