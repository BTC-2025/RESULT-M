"use client";

import { useState, useRef, useEffect } from "react";
import { api } from "@/lib/api";

interface EditProfileDrawerProps {
  isOpen: boolean;
  onClose: () => void;
  profile: {
    name: string;
    bio?: string;
    website?: string;
    phoneNumber?: string;
    profilePictureBase64?: string;
    email?: string;
    city?: string;
    coverPictureBase64?: string;
  };
  onSaved: (updated: any) => void;
}

/* ─── small form field wrappers ─────────────────────── */
function Field({ label, required, children }: { label: string; required?: boolean; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-[11px] font-black text-zinc-500 uppercase tracking-widest mb-1.5">
        {label}{required && <span className="text-red-400 ml-0.5">*</span>}
      </label>
      {children}
    </div>
  );
}

const inputCls = "w-full px-3.5 py-2.5 rounded-xl border border-zinc-200 bg-zinc-50/50 text-sm font-medium text-zinc-900 placeholder:text-zinc-300 outline-none focus:border-[#635BFF] focus:bg-white focus:ring-2 focus:ring-[#635BFF]/10 transition-all";
const iconCls = "absolute left-3 top-1/2 -translate-y-1/2 text-zinc-300 pointer-events-none";

export default function EditProfileDrawer({ isOpen, onClose, profile, onSaved }: EditProfileDrawerProps) {
  const [name, setName] = useState(profile.name || "");
  const [bio, setBio] = useState(profile.bio || "");
  const [website, setWebsite] = useState(profile.website || "");
  const [phoneNumber, setPhoneNumber] = useState(profile.phoneNumber || "");
  const [city, setCity] = useState(profile.city || "");
  const [avatarBase64, setAvatarBase64] = useState<string | undefined>(profile.profilePictureBase64);
  const [avatarPreview, setAvatarPreview] = useState<string | undefined>(
    profile.profilePictureBase64 ? `data:image/jpeg;base64,${profile.profilePictureBase64}` : undefined
  );
  const [coverBase64, setCoverBase64] = useState<string | undefined>(profile.coverPictureBase64);
  const [coverPreview, setCoverPreview] = useState<string | undefined>(
    profile.coverPictureBase64 ? `data:image/jpeg;base64,${profile.coverPictureBase64}` : undefined
  );
  const [isSaving, setIsSaving] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const coverInputRef = useRef<HTMLInputElement>(null);

  // Sync on prop changes
  useEffect(() => {
    setName(profile.name || "");
    setBio(profile.bio || "");
    setWebsite(profile.website || "");
    setPhoneNumber(profile.phoneNumber || "");
    setCity(profile.city || "");
    setAvatarBase64(profile.profilePictureBase64);
    setAvatarPreview(profile.profilePictureBase64 ? `data:image/jpeg;base64,${profile.profilePictureBase64}` : undefined);
    setCoverBase64(profile.coverPictureBase64);
    setCoverPreview(profile.coverPictureBase64 ? `data:image/jpeg;base64,${profile.coverPictureBase64}` : undefined);
  }, [profile]);

  useEffect(() => {
    document.body.style.overflow = isOpen ? "hidden" : "";
    return () => { document.body.style.overflow = ""; };
  }, [isOpen]);

  const handleAvatarChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 2 * 1024 * 1024) { setError("Image must be smaller than 2 MB."); return; }
    const reader = new FileReader();
    reader.onload = ev => {
      const dataUrl = ev.target?.result as string;
      setAvatarPreview(dataUrl);
      setAvatarBase64(dataUrl.split(",")[1]);
    };
    reader.readAsDataURL(file);
  };

  const handleCoverChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (file.size > 5 * 1024 * 1024) { setError("Cover image must be smaller than 5 MB."); return; }
    const reader = new FileReader();
    reader.onload = ev => {
      const dataUrl = ev.target?.result as string;
      setCoverPreview(dataUrl);
      setCoverBase64(dataUrl.split(",")[1]);
    };
    reader.readAsDataURL(file);
  };

  const handleSave = async () => {
    if (!name.trim()) { setError("Name is required."); return; }
    setError("");
    setIsSaving(true);
    try {
      const payload: any = {
        name: name.trim(),
        bio: bio || null,
        website: website || null,
        phoneNumber: phoneNumber || null,
        city: city || null,
      };
      if (avatarBase64) payload.profilePictureBase64 = avatarBase64;
      if (coverBase64) payload.coverPictureBase64 = coverBase64;
      const updated = await api.users.updateMe(payload);
      setSuccess(true);
      onSaved(updated);
      setTimeout(() => { setSuccess(false); onClose(); }, 1200);
    } catch (err: any) {
      setError(err.message || "Failed to save. Please try again.");
    } finally {
      setIsSaving(false);
    }
  };

  const initials = name.trim().split(" ").map(w => w[0]).join("").slice(0, 2).toUpperCase() || "?";

  if (!isOpen) return null;

  return (
    <>
      {/* Backdrop */}
      <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50" onClick={onClose} />

      {/* Drawer */}
      <div className="fixed right-0 top-0 h-full w-full max-w-[480px] bg-white z-50 shadow-2xl flex flex-col">

        {/* ── Header ── */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-zinc-100 shrink-0 bg-white">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-[#635BFF]/10 flex items-center justify-center">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" className="text-[#635BFF]">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
              </svg>
            </div>
            <div>
              <h2 className="text-base font-black text-zinc-900 leading-tight">Edit Profile</h2>
              <p className="text-[11px] text-zinc-400 font-medium">Update your personal information</p>
            </div>
          </div>
          <button onClick={onClose} className="w-8 h-8 rounded-full bg-zinc-100 hover:bg-zinc-200 flex items-center justify-center transition-colors">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        {/* ── Scrollable Body ── */}
        <div className="flex-1 overflow-y-auto">
          <div className="px-5 py-5 space-y-5">

            {/* ── PROFILE PHOTO section ── */}
            <div className="bg-zinc-50 border border-zinc-100 rounded-2xl p-4">
              <p className="text-[11px] font-black text-zinc-400 uppercase tracking-widest mb-3">Profile Photo</p>
              <div className="flex items-center gap-4">
                <div className="relative shrink-0">
                  <div className="w-18 h-18 w-[72px] h-[72px] rounded-full overflow-hidden bg-gradient-to-br from-violet-500 to-indigo-600 flex items-center justify-center text-white font-black text-xl shadow-md ring-2 ring-white">
                    {avatarPreview
                      ? <img src={avatarPreview} alt="Avatar" className="w-full h-full object-cover" />
                      : <span>{initials}</span>}
                  </div>
                  <button
                    onClick={() => fileInputRef.current?.click()}
                    className="absolute -bottom-0.5 -right-0.5 w-6 h-6 rounded-full bg-[#635BFF] text-white flex items-center justify-center shadow-md hover:bg-[#5249E5] transition-colors border-2 border-white"
                  >
                    <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round">
                      <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/>
                    </svg>
                  </button>
                  <input ref={fileInputRef} type="file" accept="image/*" className="hidden" onChange={handleAvatarChange} />
                </div>
                <div className="flex-1">
                  <button
                    onClick={() => fileInputRef.current?.click()}
                    className="w-full py-2 px-3 border-2 border-dashed border-zinc-200 rounded-xl text-xs font-bold text-zinc-500 hover:border-[#635BFF] hover:text-[#635BFF] transition-all text-center mb-2"
                  >
                    Upload new photo
                  </button>
                  <p className="text-[10px] text-zinc-400 text-center">JPG, PNG, WebP · Max 2 MB</p>
                  {avatarPreview && (
                    <button
                      onClick={() => { setAvatarPreview(undefined); setAvatarBase64(undefined); }}
                      className="text-[11px] text-red-400 font-semibold mt-1.5 w-full text-center hover:underline"
                    >
                      Remove photo
                    </button>
                  )}
                </div>
              </div>
            </div>

            {/* ── BASIC INFO section ── */}
            <div className="space-y-4">
              <p className="text-[11px] font-black text-zinc-400 uppercase tracking-widest">Basic Info</p>

              <Field label="Full Name" required>
                <input
                  type="text"
                  value={name}
                  onChange={e => setName(e.target.value)}
                  maxLength={80}
                  placeholder="Your full name"
                  className={inputCls}
                />
              </Field>

              <Field label="Bio">
                <textarea
                  value={bio}
                  onChange={e => setBio(e.target.value)}
                  maxLength={280}
                  rows={3}
                  placeholder="Write a short bio about yourself..."
                  className={`${inputCls} resize-none leading-relaxed`}
                />
                <p className="text-[11px] text-zinc-300 text-right mt-1">{bio.length}/280</p>
              </Field>
            </div>

            {/* ── CONTACT section ── */}
            <div className="space-y-4">
              <p className="text-[11px] font-black text-zinc-400 uppercase tracking-widest">Contact & Location</p>

              <Field label="Phone Number">
                <div className="relative">
                  <span className={iconCls}>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                      <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 13.1 19.79 19.79 0 0 1 1.61 4.5 2 2 0 0 1 3.58 2.4h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 10a16 16 0 0 0 6.1 6.1l1.96-1.96a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
                    </svg>
                  </span>
                  <input
                    type="tel"
                    value={phoneNumber}
                    onChange={e => setPhoneNumber(e.target.value)}
                    placeholder="+91 98765 43210"
                    className={`${inputCls} pl-9`}
                  />
                </div>
              </Field>

              <Field label="City">
                <div className="relative">
                  <span className={iconCls}>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                      <path d="M12 22s8-4.5 8-11.8A8 8 0 0 0 4 10.2C4 17.5 12 22 12 22z"/><circle cx="12" cy="10" r="3"/>
                    </svg>
                  </span>
                  <input
                    type="text"
                    value={city}
                    onChange={e => setCity(e.target.value)}
                    placeholder="e.g. Chennai, Mumbai, Delhi"
                    className={`${inputCls} pl-9`}
                  />
                </div>
              </Field>

              <Field label="Website">
                <div className="relative">
                  <span className={iconCls}>
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
                      <circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
                    </svg>
                  </span>
                  <input
                    type="url"
                    value={website}
                    onChange={e => setWebsite(e.target.value)}
                    placeholder="https://yourwebsite.com"
                    className={`${inputCls} pl-9`}
                  />
                </div>
              </Field>
            </div>

            {/* ── READ-ONLY section ── */}
            <div className="bg-zinc-50 border border-zinc-100 rounded-2xl p-4">
              <p className="text-[11px] font-black text-zinc-400 uppercase tracking-widest mb-3">Account (Read-only)</p>
              <div className="space-y-2.5">
                <div className="flex items-center gap-2.5">
                  <div className="w-7 h-7 rounded-lg bg-white border border-zinc-200 flex items-center justify-center shrink-0">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-zinc-400">
                      <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/>
                    </svg>
                  </div>
                  <div>
                    <p className="text-[10px] text-zinc-400 font-bold uppercase tracking-wide">Email</p>
                    <p className="text-xs font-semibold text-zinc-600">{profile.email}</p>
                  </div>
                </div>
              </div>
            </div>

            {/* ── COVER PHOTO section ── */}
            <div className="bg-zinc-50 border border-zinc-100 rounded-2xl p-4">
              <p className="text-[11px] font-black text-zinc-400 uppercase tracking-widest mb-3">Cover Photo</p>
              <div className="relative w-full h-32 rounded-xl overflow-hidden bg-gradient-to-br from-zinc-200 to-zinc-300 border border-zinc-200 flex items-center justify-center group cursor-pointer" onClick={() => coverInputRef.current?.click()}>
                {coverPreview ? (
                  <img src={coverPreview} alt="Cover" className="w-full h-full object-cover group-hover:opacity-75 transition-opacity" />
                ) : (
                  <div className="text-center">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" className="mx-auto text-zinc-400 mb-2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    <p className="text-xs font-bold text-zinc-500">Upload Banner</p>
                  </div>
                )}
                <div className="absolute inset-0 bg-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                  <span className="px-3 py-1.5 bg-white/20 backdrop-blur-sm text-white text-xs font-bold rounded-lg flex items-center gap-2 border border-white/20">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/><circle cx="12" cy="13" r="4"/></svg>
                    Change Cover
                  </span>
                </div>
                <input ref={coverInputRef} type="file" accept="image/*" className="hidden" onChange={handleCoverChange} />
              </div>
            </div>

            <p className="text-[11px] text-zinc-400 leading-relaxed">
              Your email address and account type cannot be changed here. Contact support to update these.
            </p>

          </div>
        </div>

        {/* ── Footer ── */}
        <div className="px-5 py-4 border-t border-zinc-100 bg-white shrink-0">
          {error && (
            <div className="flex items-center gap-2 mb-3 px-3 py-2 bg-red-50 border border-red-100 rounded-xl">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-red-500 shrink-0">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
              </svg>
              <p className="text-xs font-semibold text-red-600">{error}</p>
            </div>
          )}
          <div className="flex gap-3">
            <button
              onClick={onClose}
              className="flex-1 py-2.5 rounded-xl border-2 border-zinc-200 text-sm font-bold text-zinc-600 hover:bg-zinc-50 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleSave}
              disabled={isSaving || success}
              className={`flex-1 py-2.5 rounded-xl text-sm font-bold text-white transition-all flex items-center justify-center gap-2 shadow-sm ${
                success ? "bg-emerald-500 shadow-emerald-200" : "bg-[#635BFF] hover:bg-[#5249E5] shadow-[#635BFF]/20"
              } disabled:opacity-60 disabled:cursor-not-allowed`}
            >
              {success ? (
                <>
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round"><polyline points="20 6 9 17 4 12"/></svg>
                  Saved!
                </>
              ) : isSaving ? (
                <>
                  <svg className="animate-spin" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                    <circle cx="12" cy="12" r="10" strokeOpacity="0.2"/><path d="M12 2a10 10 0 0 1 10 10" strokeLinecap="round"/>
                  </svg>
                  Saving...
                </>
              ) : "Save Changes"}
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
