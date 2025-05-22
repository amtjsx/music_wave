"use client";

import { BarChart3, Music, Play, Upload, Users } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useTranslation } from "@/hooks/use-translation";
import {
  getAlbumArtPlaceholder,
  getColoredPlaceholder,
} from "@/utils/image-utils";

// Sample artist data
const artistData = {
  name: "Your Artist Name",
  totalTracks: 24,
  totalAlbums: 3,
  totalPlays: 125840,
  monthlyListeners: 45620,
  followers: 12350,
  topTracks: [
    {
      id: "1",
      title: "Summer Vibes",
      plays: 45280,
      coverArt: getAlbumArtPlaceholder(40, 40, "Summer Vibes", "ec4899"),
    },
    {
      id: "2",
      title: "Midnight Dreams",
      plays: 32150,
      coverArt: getAlbumArtPlaceholder(40, 40, "Midnight Dreams", "8b5cf6"),
    },
    {
      id: "3",
      title: "Ocean Waves",
      plays: 28490,
      coverArt: getAlbumArtPlaceholder(40, 40, "Ocean Waves", "3b82f6"),
    },
  ],
  recentAlbums: [
    {
      id: "1",
      title: "Summer Collection",
      tracks: 8,
      releaseDate: "2023-06-15",
      coverArt: getColoredPlaceholder(200, 200, "ec4899"),
    },
    {
      id: "2",
      title: "Winter Melodies",
      tracks: 10,
      releaseDate: "2022-12-01",
      coverArt: getColoredPlaceholder(200, 200, "8b5cf6"),
    },
    {
      id: "3",
      title: "Spring Awakening",
      tracks: 6,
      releaseDate: "2022-03-20",
      coverArt: getColoredPlaceholder(200, 200, "3b82f6"),
    },
  ],
};

export default function ArtistDashboardPage() {
  const { t } = useTranslation("artist");
  const [timeRange, setTimeRange] = useState("week");

  return (
    <main className="space-y-6 p-4">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">
          {t("artist.dashboard")}
        </h1>
        <p className="text-muted-foreground">
          {t("artist.welcome", "Welcome")}
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              {t("artist.totalPlays")}
            </CardTitle>
            <Play className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {artistData.totalPlays.toLocaleString()}
            </div>
            <p className="text-xs text-muted-foreground">
              {t("artist.allTime")}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              {t("artist.monthlyListeners")}
            </CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {artistData.monthlyListeners.toLocaleString()}
            </div>
            <p className="text-xs text-muted-foreground">
              {t("artist.lastMonth")}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              {t("artist.followers")}
            </CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">
              {artistData.followers.toLocaleString()}
            </div>
            <p className="text-xs text-muted-foreground">
              {t("artist.totalFollowers")}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              {t("artist.catalog")}
            </CardTitle>
            <Music className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{artistData.totalTracks}</div>
            <p className="text-xs text-muted-foreground">
              {t("artist.tracksInAlbums", undefined, {
                albums: artistData.totalAlbums,
              })}
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="lg:col-span-4">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle>{t("artist.performance")}</CardTitle>
              <Tabs
                defaultValue="week"
                value={timeRange}
                onValueChange={setTimeRange}
              >
                <TabsList>
                  <TabsTrigger value="week">{t("artist.week")}</TabsTrigger>
                  <TabsTrigger value="month">{t("artist.month")}</TabsTrigger>
                  <TabsTrigger value="year">{t("artist.year")}</TabsTrigger>
                </TabsList>
              </Tabs>
            </div>
            <CardDescription>
              {t("artist.performanceDescription")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-[200px] w-full rounded-md bg-muted flex items-center justify-center">
              <BarChart3 className="h-16 w-16 text-muted-foreground/50" />
            </div>
          </CardContent>
        </Card>
        <Card className="lg:col-span-3">
          <CardHeader>
            <CardTitle>{t("artist.topTracks")}</CardTitle>
            <CardDescription>
              {t("artist.topTracksDescription")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {artistData.topTracks.map((track, index) => (
                <div key={track.id} className="flex items-center gap-4">
                  <div className="text-muted-foreground w-4">{index + 1}</div>
                  <Image
                    src={track.coverArt || "/placeholder.svg"}
                    alt={track.title}
                    width={40}
                    height={40}
                    className="rounded-md"
                  />
                  <div className="flex-1 min-w-0">
                    <p className="font-medium truncate">{track.title}</p>
                    <p className="text-sm text-muted-foreground">
                      {track.plays.toLocaleString()} plays
                    </p>
                  </div>
                  <Button variant="ghost" size="icon">
                    <Play className="h-4 w-4" />
                    <span className="sr-only">Play</span>
                  </Button>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      <div>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-2xl font-bold tracking-tight">
            {t("artist.recentReleases")}
          </h2>
          <Button asChild variant="outline">
            <Link href="/artist/upload">
              <Upload className="mr-2 h-4 w-4" />
              {t("artist.uploadNew")}
            </Link>
          </Button>
        </div>
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4">
          {artistData.recentAlbums.map((album) => (
            <Card key={album.id} className="overflow-hidden">
              <CardContent className="p-0">
                <Link href={`/artist/music/${album.id}`} className="block">
                  <div className="relative">
                    <Image
                      src={album.coverArt || "/placeholder.svg"}
                      alt={album.title}
                      width={200}
                      height={200}
                      className="aspect-square w-full object-cover"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 transition-opacity duration-300 hover:opacity-100">
                      <Button
                        size="icon"
                        variant="secondary"
                        className="absolute bottom-4 right-4 rounded-full"
                      >
                        <Play className="h-5 w-5" />
                      </Button>
                    </div>
                  </div>
                  <div className="p-4">
                    <h3 className="font-semibold">{album.title}</h3>
                    <p className="text-sm text-muted-foreground">
                      {album.tracks} tracks •{" "}
                      {new Date(album.releaseDate).getFullYear()}
                    </p>
                  </div>
                </Link>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </main>
  );
}
