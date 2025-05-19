import "@/app/globals.css";
import { MusicPlayer } from "@/components/music-player";
import { SiteHeader } from "@/components/site-header";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { AudioProvider } from "@/contexts/audio-context";
import type React from "react";
import type { ReactNode } from "react";
import { ArtistDashboardNav } from "./components/artist-dashboard-nav";

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
        <ArtistDashboardNav />
        <SidebarInset>
          <SiteHeader />
          {children}
          <MusicPlayer />
        </SidebarInset>
      </SidebarProvider>
    </AudioProvider>
  );
}
