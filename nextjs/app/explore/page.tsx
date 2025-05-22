"use client";


import { ChevronRight } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { useTranslation } from "@/hooks/use-translation";
import { getColoredPlaceholder } from "@/utils/image-utils";

// Sample data for genres
const genres = [
  { id: "1", name: "Pop", color: "ec4899", count: "1.2M" },
  { id: "2", name: "Rock", color: "8b5cf6", count: "850K" },
  { id: "3", name: "Hip Hop", color: "3b82f6", count: "1.5M" },
  { id: "4", name: "Electronic", color: "06b6d4", count: "950K" },
  { id: "5", name: "Jazz", color: "f97316", count: "420K" },
  { id: "6", name: "Classical", color: "22c55e", count: "380K" },
];

// Sample data for moods
const moods = [
  { id: "1", name: "Happy", color: "f97316", count: "750K" },
  { id: "2", name: "Chill", color: "06b6d4", count: "1.1M" },
  { id: "3", name: "Focus", color: "22c55e", count: "680K" },
  { id: "4", name: "Workout", color: "ef4444", count: "920K" },
  { id: "5", name: "Party", color: "8b5cf6", count: "830K" },
  { id: "6", name: "Sleep", color: "3b82f6", count: "540K" },
];

// Sample data for popular artists
const popularArtists = [
  {
    id: "1",
    name: "Taylor Swift",
    image: getColoredPlaceholder(200, 200, "ec4899"),
    followers: "95.4M",
  },
  {
    id: "2",
    name: "The Weeknd",
    image: getColoredPlaceholder(200, 200, "8b5cf6"),
    followers: "82.1M",
  },
  {
    id: "3",
    name: "Drake",
    image: getColoredPlaceholder(200, 200, "3b82f6"),
    followers: "76.8M",
  },
  {
    id: "4",
    name: "Billie Eilish",
    image: getColoredPlaceholder(200, 200, "22c55e"),
    followers: "71.3M",
  },
];

// Sample data for featured playlists
const featuredPlaylists = [
  {
    id: "1",
    title: "Today's Top Hits",
    description: "The most popular songs right now",
    image: getColoredPlaceholder(200, 200, "ec4899"),
    tracks: 50,
  },
  {
    id: "2",
    title: "Chill Vibes",
    description: "Relaxing beats for your day",
    image: getColoredPlaceholder(200, 200, "8b5cf6"),
    tracks: 45,
  },
  {
    id: "3",
    title: "Workout Motivation",
    description: "Energy-boosting tracks for your exercise",
    image: getColoredPlaceholder(200, 200, "3b82f6"),
    tracks: 40,
  },
  {
    id: "4",
    title: "Throwback Classics",
    description: "Hits from the past decades",
    image: getColoredPlaceholder(200, 200, "22c55e"),
    tracks: 60,
  },
];

export default function ExplorePage() {
  const { t } = useTranslation("explore");

  return (
    <main className="flex-1 pb-20">
      <section className="container py-8">
        <div className="space-y-2">
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            {t("explore.title")}
          </h1>
          <p className="text-muted-foreground">{t("explore.subtitle")}</p>
        </div>
      </section>

      {/* Browse by Genre */}
      <section className="container py-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">
              {t("explore.genres.title")}
            </h2>
            <p className="text-sm text-muted-foreground">
              {t("explore.genres.description")}
            </p>
          </div>
          <Button variant="link" className="gap-1">
            {t("explore.viewmore")}
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6">
          {genres.map((genre) => (
            <Link href="#" key={genre.id} className="block">
              <Card className="overflow-hidden transition-all hover:shadow-md">
                <CardHeader className="p-4 pb-2">
                  <div
                    className="h-24 w-full rounded-md"
                    style={{ backgroundColor: `#${genre.color}` }}
                  />
                </CardHeader>
                <CardContent className="p-4 pt-2">
                  <CardTitle className="text-lg">{genre.name}</CardTitle>
                  <CardDescription>{genre.count} tracks</CardDescription>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>

      {/* Browse by Mood */}
      <section className="container py-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">
              {t("explore.moods.title")}
            </h2>
            <p className="text-sm text-muted-foreground">
              {t("explore.moods.description")}
            </p>
          </div>
          <Button variant="link" className="gap-1">
            {t("explore.viewmore")}
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6">
          {moods.map((mood) => (
            <Link href="#" key={mood.id} className="block">
              <Card className="overflow-hidden transition-all hover:shadow-md">
                <CardHeader className="p-4 pb-2">
                  <div
                    className="h-24 w-full rounded-md"
                    style={{ backgroundColor: `#${mood.color}` }}
                  />
                </CardHeader>
                <CardContent className="p-4 pt-2">
                  <CardTitle className="text-lg">{mood.name}</CardTitle>
                  <CardDescription>{mood.count} tracks</CardDescription>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>

      {/* Popular Artists */}
      <section className="container py-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">
              {t("explore.artists.title")}
            </h2>
            <p className="text-sm text-muted-foreground">
              {t("explore.artists.description")}
            </p>
          </div>
          <Button variant="link" className="gap-1">
            {t("explore.viewmore")}
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
        <div className="grid grid-cols-2 gap-6 sm:grid-cols-2 md:grid-cols-4">
          {popularArtists.map((artist) => (
            <Link href="#" key={artist.id} className="block">
              <Card className="overflow-hidden transition-all hover:shadow-md">
                <CardContent className="p-0">
                  <div className="relative">
                    <Image
                      src={artist.image || "/placeholder.svg"}
                      alt={artist.name}
                      width={300}
                      height={300}
                      className="aspect-square w-full object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
                  </div>
                  <div className="p-4">
                    <h3 className="font-semibold">{artist.name}</h3>
                    <p className="text-sm text-muted-foreground">
                      {artist.followers} followers
                    </p>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>

      {/* Featured Playlists */}
      <section className="container py-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">
              {t("explore.playlists.title")}
            </h2>
            <p className="text-sm text-muted-foreground">
              {t("explore.playlists.description")}
            </p>
          </div>
          <Button variant="link" className="gap-1">
            {t("explore.viewmore")}
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-4">
          {featuredPlaylists.map((playlist) => (
            <Link href="#" key={playlist.id} className="block">
              <Card className="overflow-hidden transition-all hover:shadow-md">
                <CardContent className="p-0">
                  <div className="relative">
                    <Image
                      src={playlist.image || "/placeholder.svg"}
                      alt={playlist.title}
                      width={300}
                      height={300}
                      className="aspect-square w-full object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
                  </div>
                  <div className="p-4">
                    <h3 className="font-semibold">{playlist.title}</h3>
                    <p className="text-sm text-muted-foreground">
                      {playlist.description}
                    </p>
                    <p className="text-xs text-muted-foreground mt-1">
                      {playlist.tracks} tracks
                    </p>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>
    </main>
  );
}
