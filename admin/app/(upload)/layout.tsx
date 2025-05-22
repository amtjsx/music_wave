import "@/app/globals.css";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { AudioProvider } from "@/contexts/audio-context";
import type React from "react";
import type { ReactNode } from "react";
import { ArtistDashboardSidebar } from "../components/artist-dashboard-nav";

export default function ArtistDashboardLayout({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <AudioProvider>
      <SidebarProvider
        style={
          {
            "--sidebar-width": "18rem",
          } as React.CSSProperties
        }
      >
        <ArtistDashboardSidebar />
        <SidebarInset>{children}</SidebarInset>
      </SidebarProvider>
    </AudioProvider>
  );
}
