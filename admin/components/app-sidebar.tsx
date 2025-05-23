"use client";

import {
    Home,
    Library,
    ListMusic,
    Music2,
    PlusCircle,
    Radio,
    Search,
    UserCircle,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import * as React from "react";

import {
    Sidebar,
    SidebarContent,
    SidebarFooter,
    SidebarGroup,
    SidebarGroupContent,
    SidebarGroupLabel,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
    SidebarMenuSub,
    SidebarMenuSubButton,
    SidebarMenuSubItem,
    SidebarSeparator,
} from "@/components/ui/sidebar";
import { useTranslation } from "@/hooks/use-translation";
import { getAlbumArtPlaceholder } from "@/utils/image-utils";

// Sample playlists data
const playlists = [
  { id: "1", name: "Favorites" },
  { id: "2", name: "Recently Added" },
  { id: "3", name: "Chill Vibes" },
  { id: "4", name: "Workout Mix" },
  { id: "5", name: "Road Trip" },
];

// Sample genres data
const genres = [
  { id: "1", name: "Pop" },
  { id: "2", name: "Rock" },
  { id: "3", name: "Hip Hop" },
  { id: "4", name: "Electronic" },
  { id: "5", name: "Jazz" },
  { id: "6", name: "Classical" },
  { id: "7", name: "R&B" },
  { id: "8", name: "Country" },
];

// Sample recently played tracks
const recentlyPlayed = [
  {
    id: "1",
    name: "Sample Track 1",
    artist: "Demo Artist",
    coverArt: getAlbumArtPlaceholder(32, 32, "Sample Track 1", "ec4899"),
  },
  {
    id: "2",
    name: "Sample Track 2",
    artist: "Demo Artist",
    coverArt: getAlbumArtPlaceholder(32, 32, "Sample Track 2", "8b5cf6"),
  },
  {
    id: "3",
    name: "Sample Track 3",
    artist: "Demo Artist",
    coverArt: getAlbumArtPlaceholder(32, 32, "Sample Track 3", "3b82f6"),
  },
];

export function AppSidebar({ ...props }: React.ComponentProps<typeof Sidebar>) {
  const { t } = useTranslation("sidebar");

  return (
    <Sidebar {...props} collapsible="icon">
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton size="lg" asChild>
              <Link href="/">
                <div className="flex aspect-square size-8 items-center justify-center rounded-lg bg-primary text-primary-foreground">
                  <Music2 className="size-4" />
                </div>
                <div className="flex flex-col gap-0.5 leading-none">
                  <span className="font-semibold">SOUNDWAVE</span>
                  <span className="text-xs">Music Streaming</span>
                </div>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton asChild>
                <Link href="/">
                  <Home className="h-4 w-4" />
                  <span>{t("nav.home", "Home")}</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
            <SidebarMenuItem>
              <SidebarMenuButton asChild>
                <Link href="/explore">
                  <Search className="h-4 w-4" />
                  <span>{t("nav.explore", "Explore")}</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
            <SidebarMenuItem>
              <SidebarMenuButton asChild>
                <Link href="/library">
                  <Library className="h-4 w-4" />
                  <span>{t("nav.library", "Library")}</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarGroup>

        <SidebarSeparator />

        <SidebarGroup>
          <SidebarGroupLabel className="flex items-center justify-between">
            <span>{t("sidebar.playlists", "Playlists")}</span>
            <PlusCircle className="h-4 w-4 cursor-pointer" />
          </SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {playlists.map((playlist) => (
                <SidebarMenuItem key={playlist.id}>
                  <SidebarMenuButton asChild>
                    <Link href={`/playlist/${playlist.id}`}>
                      <ListMusic className="h-4 w-4" />
                      <span>{playlist.name}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarSeparator />

        <SidebarGroup>
          <SidebarGroupLabel>{t("sidebar.genres", "Genres")}</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              <SidebarMenuItem>
                <SidebarMenuButton>
                  <Radio className="h-4 w-4" />
                  <span>{t("sidebar.browse", "Browse")}</span>
                </SidebarMenuButton>
                <SidebarMenuSub>
                  {genres.map((genre) => (
                    <SidebarMenuSubItem key={genre.id}>
                      <SidebarMenuSubButton asChild>
                        <Link href="#">{genre.name}</Link>
                      </SidebarMenuSubButton>
                    </SidebarMenuSubItem>
                  ))}
                </SidebarMenuSub>
              </SidebarMenuItem>
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>

        <SidebarSeparator />

        <SidebarGroup>
          <SidebarGroupLabel>{t("sidebar.recent", "Recent")}</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {recentlyPlayed.map((track) => (
                <SidebarMenuItem key={track.id}>
                  <SidebarMenuButton asChild>
                    <Link href="#" className="flex items-center gap-3">
                      <Image
                        src={track.coverArt || "/placeholder.svg"}
                        alt={`${track.name} cover`}
                        width={32}
                        height={32}
                        className="rounded-md"
                      />
                      <div className="flex flex-col">
                        <span>{track.name}</span>
                        <span className="text-xs text-muted-foreground">
                          {track.artist}
                        </span>
                      </div>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton asChild>
              <Link href="#">
                <UserCircle className="h-4 w-4" />
                <span>{t("sidebar.account", "Account")}</span>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  );
}
