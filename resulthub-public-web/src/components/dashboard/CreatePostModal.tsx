"use client";

import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X, Image as ImageIcon, Send, Loader2 } from 'lucide-react';
import { api } from '@/lib/api';

interface CreatePostModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export function CreatePostModal({ isOpen, onClose }: CreatePostModalProps) {
  const [content, setContent] = useState('');
  const [category, setCategory] = useState('');
  const [locationName, setLocationName] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [successMsg, setSuccessMsg] = useState('');

  const handleSubmit = async () => {
    if (!content.trim()) {
      setErrorMsg("Post content is required.");
      return;
    }
    
    setErrorMsg('');
    setSuccessMsg('');
    setIsSubmitting(true);

    try {
      const dataPayload = {
        postType: "UPDATE",
        text: content,
        category: category || "General",
        locationName: locationName || "Headquarters"
      };

      const formData = new FormData();
      formData.append('data', new Blob([JSON.stringify(dataPayload)], { type: 'application/json' }));
      
      if (file) {
        formData.append('files', file);
      }

      await api.posts.create(formData);
      
      setSuccessMsg("Post published successfully!");
      setTimeout(() => {
        setSuccessMsg('');
        setContent('');
        setCategory('');
        setLocationName('');
        setFile(null);
        onClose();
      }, 1500);

    } catch (err: any) {
      console.error(err);
      setErrorMsg(err.message || "Failed to publish post.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div 
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50"
          />
          <motion.div 
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 20 }}
            className="fixed top-[10%] left-1/2 -translate-x-1/2 w-full max-w-lg bg-white border border-zinc-200 rounded-3xl z-50 shadow-2xl overflow-hidden flex flex-col"
          >
            <div className="flex items-center justify-between p-5 border-b border-zinc-100">
              <h2 className="text-lg font-bold text-zinc-900">Publish a Post</h2>
              <button onClick={onClose} className="p-2 text-zinc-400 hover:text-zinc-900 hover:bg-zinc-100 rounded-xl transition-colors">
                <X className="w-5 h-5" />
              </button>
            </div>
            
            <div className="p-5 space-y-4">
              {errorMsg && <div className="text-sm font-medium text-red-500 bg-red-50 border border-red-100 p-3 rounded-xl">{errorMsg}</div>}
              {successMsg && <div className="text-sm font-medium text-emerald-500 bg-emerald-50 border border-emerald-100 p-3 rounded-xl">{successMsg}</div>}
              
              <textarea 
                placeholder="What's happening?"
                value={content}
                onChange={(e) => setContent(e.target.value)}
                className="w-full bg-zinc-50 border border-zinc-200 rounded-xl p-4 text-zinc-900 focus:outline-none focus:border-[#635BFF] focus:ring-1 focus:ring-[#635BFF] transition-all resize-none min-h-[120px]"
              />

              <div className="grid grid-cols-2 gap-3">
                <input 
                  type="text" 
                  placeholder="Category (e.g. Announcement)"
                  value={category}
                  onChange={(e) => setCategory(e.target.value)}
                  className="w-full px-4 py-2.5 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-[#635BFF]"
                />
                <input 
                  type="text" 
                  placeholder="Location (e.g. Headquarters)"
                  value={locationName}
                  onChange={(e) => setLocationName(e.target.value)}
                  className="w-full px-4 py-2.5 bg-zinc-50 border border-zinc-200 rounded-xl text-sm text-zinc-900 focus:outline-none focus:border-[#635BFF]"
                />
              </div>

              {file && (
                <div className="relative inline-block mt-2">
                  <img src={URL.createObjectURL(file)} alt="Preview" className="h-24 w-auto rounded-lg border border-zinc-200 object-cover" />
                  <button onClick={() => setFile(null)} className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 shadow-md"><X className="w-3 h-3" /></button>
                </div>
              )}
            </div>

            <div className="p-5 border-t border-zinc-100 bg-zinc-50 flex items-center justify-between">
              <div>
                <input type="file" id="postImageUpload" className="hidden" accept="image/*" onChange={(e) => { if(e.target.files && e.target.files[0]) setFile(e.target.files[0]); }} />
                <label htmlFor="postImageUpload" className="p-2.5 text-[#635BFF] hover:bg-[#635BFF]/10 rounded-xl cursor-pointer transition-colors inline-block">
                  <ImageIcon className="w-5 h-5" />
                </label>
              </div>
              <button 
                onClick={handleSubmit}
                disabled={isSubmitting}
                className="flex items-center gap-2 px-6 py-2.5 bg-[#635BFF] hover:bg-[#5249E5] text-white font-bold rounded-xl shadow-md disabled:opacity-50 transition-all"
              >
                {isSubmitting ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />}
                Publish
              </button>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
