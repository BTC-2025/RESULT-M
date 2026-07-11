"use client";

import { useState, useRef, useEffect } from "react";

export default function CreateOrganizationPage() {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [selectedDomain, setSelectedDomain] = useState("Education");
  const dropdownRef = useRef<HTMLDivElement>(null);

  const domains = [
    "Education", "Sports", "Finance", "Politics", "Entertainment", 
    "Government", "Law", "Healthcare", "Business", "Hyperlocal", 
    "Technology", "Custom"
  ];

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <main className="flex min-h-screen flex-col bg-background text-foreground">
      <div className="flex-1 py-16 px-6 bg-muted/10 border-b border-muted">
        <div className="mx-auto max-w-3xl bg-background rounded-3xl p-8 md:p-12 border border-muted shadow-sm hover:shadow-md transition-shadow duration-500">
          <div className="mb-10">
            <h1 className="text-3xl font-extrabold tracking-tight mb-2">Register your Organization</h1>
            <p className="text-muted-foreground">Get verified and start publishing datasets globally on ResultHub.</p>
          </div>

          <form className="space-y-8">
            {/* Step 1 */}
            <section>
              <h2 className="text-xl font-semibold border-b border-muted pb-2 mb-6">1. Organization Details</h2>
              <div className="space-y-4">
                <div className="group">
                  <label className="block text-sm font-semibold mb-2 group-focus-within:text-primary transition-colors">Organization Name</label>
                  <input type="text" placeholder="e.g. Stanford University" className="w-full px-4 py-3 rounded-xl border border-muted bg-background outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all duration-300" />
                </div>
                <div className="grid md:grid-cols-2 gap-4">
                  
                  {/* Animative Custom Dropdown */}
                  <div className="relative group" ref={dropdownRef}>
                    <label className="block text-sm font-semibold mb-2 group-focus-within:text-primary transition-colors">Primary Domain</label>
                    <div 
                      className={`w-full px-4 py-3 rounded-xl border cursor-pointer flex items-center justify-between bg-background transition-all duration-300 ${isDropdownOpen ? 'border-primary ring-2 ring-primary/20 shadow-sm' : 'border-muted hover:border-primary/50'}`}
                      onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                    >
                      <span className="font-medium">{selectedDomain}</span>
                      <svg 
                        width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                        className={`transition-transform duration-300 ${isDropdownOpen ? 'rotate-180 text-primary' : 'text-muted-foreground'}`}
                      >
                        <polyline points="6 9 12 15 18 9"></polyline>
                      </svg>
                    </div>
                    
                    {/* Dropdown Menu Options */}
                    <div 
                      className={`absolute z-20 w-full mt-2 bg-background border border-muted rounded-xl shadow-xl overflow-hidden transition-all duration-300 origin-top ${
                        isDropdownOpen ? 'opacity-100 scale-y-100 translate-y-0' : 'opacity-0 scale-y-95 -translate-y-2 pointer-events-none'
                      }`}
                    >
                      <div className="max-h-60 overflow-y-auto hide-scrollbar p-1">
                        {domains.map(domain => (
                          <div 
                            key={domain}
                            className={`px-4 py-2.5 rounded-lg cursor-pointer text-sm font-medium transition-all duration-200 flex items-center gap-2 ${
                              selectedDomain === domain 
                                ? 'bg-primary/10 text-primary' 
                                : 'hover:bg-muted/50 hover:pl-5 text-foreground'
                            }`}
                            onClick={() => {
                              setSelectedDomain(domain);
                              setIsDropdownOpen(false);
                            }}
                          >
                            {selectedDomain === domain && (
                              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className="text-primary animate-in zoom-in duration-300">
                                <polyline points="20 6 9 17 4 12"></polyline>
                              </svg>
                            )}
                            <span className={selectedDomain === domain ? 'ml-0' : 'ml-[22px]'}>{domain}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  <div className="group">
                    <label className="block text-sm font-semibold mb-2 group-focus-within:text-primary transition-colors">Official Website</label>
                    <input type="url" placeholder="https://" className="w-full px-4 py-3 rounded-xl border border-muted bg-background outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all duration-300" />
                  </div>
                </div>
              </div>
            </section>

            {/* Step 2 */}
            <section>
              <h2 className="text-xl font-semibold border-b border-muted pb-2 mb-6 mt-8">2. Administrative Contact</h2>
              <div className="grid md:grid-cols-2 gap-4">
                <div className="group">
                  <label className="block text-sm font-semibold mb-2 group-focus-within:text-primary transition-colors">Full Name</label>
                  <input type="text" className="w-full px-4 py-3 rounded-xl border border-muted bg-background outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all duration-300" />
                </div>
                <div className="group">
                  <label className="block text-sm font-semibold mb-2 group-focus-within:text-primary transition-colors">Work Email (Must match domain)</label>
                  <input type="email" className="w-full px-4 py-3 rounded-xl border border-muted bg-background outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all duration-300" />
                </div>
              </div>
            </section>

            <div className="pt-6">
              <button type="button" className="relative overflow-hidden w-full md:w-auto px-8 py-3 rounded-xl bg-primary text-white font-bold shadow-lg hover:shadow-primary/25 transition-all duration-300 hover:-translate-y-0.5 active:translate-y-0 group">
                <span className="relative z-10 flex items-center justify-center gap-2">
                  Submit Registration Request
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="transition-transform duration-300 group-hover:translate-x-1"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
                </span>
              </button>
              <p className="mt-4 text-xs text-muted-foreground flex items-center gap-2">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                Your request will be manually verified by our team within 24-48 hours before publishing rights are granted.
              </p>
            </div>
          </form>
        </div>
      </div>
      </main>
  );
}
