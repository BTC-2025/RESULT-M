"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { Loader2 } from "lucide-react";

export default function DashboardRootRedirect() {
  const router = useRouter();

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const sessionId = localStorage.getItem('rh_session_id');
      const user = localStorage.getItem('rh_user');
      
      if (sessionId && user) {
        try {
          const parsedUser = JSON.parse(user);
          if (parsedUser.role === 'ORGANIZATION') {
            router.replace(`/dashboard/${sessionId}`);
            return;
          }
        } catch(e) {}
      }
      
      // If no valid session ID or not an organization, kick them to login
      router.replace('/login');
    }
  }, [router]);

  return (
    <div className="h-screen w-full flex items-center justify-center bg-[#F9FAFB]">
      <div className="flex flex-col items-center gap-4 text-zinc-500">
        <Loader2 className="w-8 h-8 animate-spin text-[#635BFF]" />
        <p className="font-semibold text-sm animate-pulse">Securing your session...</p>
      </div>
    </div>
  );
}
