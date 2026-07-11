import BottomNav from "@/components/layout/BottomNav";
import LeftSidebar from "@/components/feed/LeftSidebar";
import MobileTopNav from "@/components/layout/MobileTopNav";
import SocialAuthGuard from "@/components/layout/SocialAuthGuard";

export default function SocialLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <div className="flex flex-col md:flex-row min-h-screen pb-16 md:pb-0 w-full">
      <SocialAuthGuard />
      <MobileTopNav />
      <LeftSidebar />
      <div className="flex-1 flex flex-col min-w-0 w-full overflow-x-hidden">
        <div className="mx-auto w-full max-w-[1352px] px-2 sm:px-4 lg:px-6 pb-4">
          {children}
        </div>
      </div>
      <BottomNav />
    </div>
  );
}
