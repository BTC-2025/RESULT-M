"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function SocialAuthGuard() {
  const router = useRouter();

  useEffect(() => {
    if (typeof window !== 'undefined') {
      const storedUser = localStorage.getItem('rh_user');
      if (storedUser) {
        try {
          const parsedUser = JSON.parse(storedUser);
          if (parsedUser.role === 'ORGANIZATION') {
            // Organizations cannot access the public social feed, they belong in the dashboard
            const sessionId = localStorage.getItem('rh_session_id');
            if (sessionId) {
              router.push(`/dashboard/${sessionId}`);
            } else {
              router.push('/login');
            }
          }
        } catch (e) {
          // Ignore parse errors
        }
      }
    }
  }, [router]);

  return null; // This component doesn't render anything
}
