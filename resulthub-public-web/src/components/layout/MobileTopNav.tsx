"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { motion, AnimatePresence } from "framer-motion";
import { Menu, X, Bell } from "lucide-react";

export default function MobileTopNav() {
  const [isOpen, setIsOpen] = useState(false);
  const pathname = usePathname();

  const navLinks = [
    { label: "Home", href: "/" },
    { label: "Explore", href: "/results" },
    { label: "Search", href: "/search" },
    { label: "Notifications", href: "/notifications", badge: 3 },
    { label: "Bookmarks", href: "/bookmarks" },
    { label: "Organizations", href: "/organizations" },
    { label: "Sign In", href: "/login" },
  ];

  return (
    <>
      <header className="md:hidden sticky top-0 z-40 bg-background/80 backdrop-blur-md border-b border-muted h-14 flex items-center justify-between px-4 w-full">
        <div className="flex items-center gap-3">
          <button onClick={() => setIsOpen(true)} className="p-1 -ml-1 text-foreground/70 hover:text-foreground">
            <Menu size={24} />
          </button>
          <Link href="/" className="flex items-center gap-2">
            <div className="w-8 h-8 flex items-center justify-center rounded-lg bg-gradient-to-br from-primary to-accent text-white font-black text-sm shadow-sm">
              R
            </div>
            <span className="text-lg font-extrabold tracking-tight bg-clip-text text-transparent bg-gradient-to-r from-foreground to-foreground/70">
              ResultHub
            </span>
          </Link>
        </div>

        <Link href="/notifications" className="relative p-1 text-foreground/70 hover:text-foreground">
          <Bell size={22} />
          <span className="absolute top-1 right-1 w-2.5 h-2.5 bg-primary rounded-full border-2 border-background"></span>
        </Link>
      </header>

      {/* Mobile Drawer */}
      <AnimatePresence>
        {isOpen && (
          <>
            <motion.div 
              initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}
              onClick={() => setIsOpen(false)}
              className="md:hidden fixed inset-0 bg-background/80 backdrop-blur-sm z-50"
            />
            <motion.aside 
              initial={{ x: "-100%" }} animate={{ x: 0 }} exit={{ x: "-100%" }} transition={{ type: "spring", bounce: 0, duration: 0.3 }}
              className="md:hidden fixed top-0 left-0 bottom-0 w-[280px] bg-background border-r border-muted z-50 flex flex-col shadow-2xl"
            >
              <div className="h-14 flex items-center justify-between px-4 border-b border-muted">
                <span className="text-lg font-extrabold tracking-tight">Menu</span>
                <button onClick={() => setIsOpen(false)} className="p-1 text-foreground/70 hover:text-foreground bg-muted/50 rounded-lg">
                  <X size={20} />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto py-4 px-3 space-y-1">
                {navLinks.map((link) => {
                  const isActive = pathname === link.href;
                  return (
                    <Link 
                      key={link.label} 
                      href={link.href}
                      onClick={() => setIsOpen(false)}
                      className={`flex items-center justify-between px-4 py-3 rounded-xl transition-all font-semibold ${
                        isActive ? "bg-primary/10 text-primary" : "text-foreground/80 hover:bg-muted"
                      }`}
                    >
                      <span>{link.label}</span>
                      {link.badge && (
                        <span className="bg-primary text-white text-[10px] font-black w-5 h-5 flex items-center justify-center rounded-full">
                          {link.badge}
                        </span>
                      )}
                    </Link>
                  );
                })}
              </div>
              
              <div className="p-4 border-t border-muted">
                 <Link href="/profile" onClick={() => setIsOpen(false)} className="flex items-center gap-3 p-2 rounded-xl hover:bg-muted transition-colors">
                   <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary font-bold">A</div>
                   <div>
                     <h4 className="font-bold text-sm">Alex User</h4>
                     <p className="text-[11px] text-muted-foreground uppercase font-bold">Free Plan</p>
                   </div>
                 </Link>
              </div>
            </motion.aside>
          </>
        )}
      </AnimatePresence>
    </>
  );
}
