import "@/app/globals.css";
import { AppSidebar } from "@/components/app-sidebar";
import { MusicPlayer } from "@/components/music-player";
import { SiteHeader } from "@/components/site-header";
import { ThemeProvider } from "@/components/theme-provider";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { AudioProvider } from "@/contexts/audio-context";
import type React from "react";

export const metadata = {
  title: "SoundWave - Music Streaming",
  description: "Discover and stream your favorite music",
  generator: "v0.dev",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ThemeProvider
      attribute="class"
      defaultTheme="system"
      enableSystem
      disableTransitionOnChange
    >
      <AudioProvider>
        <SidebarProvider>
          <AppSidebar />
          <SidebarInset>
            <SiteHeader />
            {children}
            <MusicPlayer />
          </SidebarInset>
        </SidebarProvider>
      </AudioProvider>
    </ThemeProvider>
  );
}
