"use client";


import { Download, Heart, Play, Plus } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { useTranslation } from "@/hooks/use-translation";
import {
  getAlbumArtPlaceholder,
  getColoredPlaceholder,
} from "@/utils/image-utils";
import { LibraryEmptyState } from "./library-empty-state";
import { LibraryFilterTabs } from "./library-filter-tabs";

// Sample data for user playlists
const userPlaylists = [
  {
    id: "1",
    title: "My Favorites",
    description: "All my favorite songs",
    image: getColoredPlaceholder(200, 200, "ec4899"),
    trackCount: 42,
    isCreatedByUser: true,
  },
  {
    id: "2",
    title: "Workout Mix",
    description: "High energy tracks for exercise",
    image: getColoredPlaceholder(200, 200, "8b5cf6"),
    trackCount: 28,
    isCreatedByUser: true,
  },
  {
    id: "3",
    title: "Chill Vibes",
    description: "Relaxing music for downtime",
    image: getColoredPlaceholder(200, 200, "3b82f6"),
    trackCount: 35,
    isCreatedByUser: false,
  },
];

// Sample data for saved albums
const savedAlbums = [
  {
    id: "1",
    title: "Renaissance",
    artist: "Beyoncé",
    image: getAlbumArtPlaceholder(200, 200, "Renaissance", "ec4899"),
    releaseYear: "2022",
  },
  {
    id: "2",
    title: "Midnights",
    artist: "Taylor Swift",
    image: getAlbumArtPlaceholder(200, 200, "Midnights", "8b5cf6"),
    releaseYear: "2022",
  },
  {
    id: "3",
    title: "Un Verano Sin Ti",
    artist: "Bad Bunny",
    image: getAlbumArtPlaceholder(200, 200, "Un Verano Sin Ti", "f97316"),
    releaseYear: "2022",
  },
];

// Sample data for followed artists
const followedArtists = [
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
];

// Sample data for liked songs
const likedSongs = [
  {
    id: "1",
    title: "Blinding Lights",
    artist: "The Weeknd",
    album: "After Hours",
    duration: "3:20",
    image: getAlbumArtPlaceholder(60, 60, "Blinding Lights", "8b5cf6"),
  },
  {
    id: "2",
    title: "Shape of You",
    artist: "Ed Sheeran",
    album: "÷ (Divide)",
    duration: "3:53",
    image: getAlbumArtPlaceholder(60, 60, "Shape of You", "ec4899"),
  },
  {
    id: "3",
    title: "Dance Monkey",
    artist: "Tones and I",
    album: "The Kids Are Coming",
    duration: "3:29",
    image: getAlbumArtPlaceholder(60, 60, "Dance Monkey", "f97316"),
  },
];

export default function LibraryPage() {
  const { t } = useTranslation("library");
  const [activeFilter, setActiveFilter] = useState("all");

  // Filter content based on active filter
  const renderContent = () => {
    switch (activeFilter) {
      case "playlists":
        return renderPlaylists();
      case "artists":
        return renderArtists();
      case "albums":
        return renderAlbums();
      case "songs":
        return renderSongs();
      case "all":
      default:
        return (
          <>
            {renderPlaylists()}
            {renderArtists()}
            {renderAlbums()}
            {renderSongs()}
          </>
        );
    }
  };

  const renderPlaylists = () => {
    if (userPlaylists.length === 0) {
      return <LibraryEmptyState />;
    }

    return (
      <section className="py-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">
              {t("library.playlists.title")}
            </h2>
            <p className="text-sm text-muted-foreground">
              {t("library.playlists.description")}
            </p>
          </div>
          <Button className="gap-2">
            <Plus className="h-4 w-4" />
            {t("library.playlists.create")}
          </Button>
        </div>
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
          {userPlaylists.map((playlist) => (
            <Link
              href={`/playlist/${playlist.id}`}
              key={playlist.id}
              className="block"
            >
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
                    <h3 className="font-semibold">{playlist.title}</h3>
                    <p className="text-sm text-muted-foreground">
                      {playlist.description}
                    </p>
                    <div className="mt-2 flex items-center justify-between">
                      <p className="text-xs text-muted-foreground">
                        {playlist.trackCount} {t("library.tracks.count")}
                      </p>
                      {playlist.isCreatedByUser && (
                        <Badge variant="outline">{t("library.created")}</Badge>
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>
    );
  };

  const renderArtists = () => {
    if (followedArtists.length === 0) {
      return <LibraryEmptyState />;
    }

    return (
      <section className="py-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">
              {t("library.artists.title")}
            </h2>
            <p className="text-sm text-muted-foreground">
              {t("library.artists.description")}
            </p>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-6 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
          {followedArtists.map((artist) => (
            <Link href="#" key={artist.id} className="block">
              <Card className="overflow-hidden transition-all hover:shadow-md">
                <CardContent className="p-0">
                  <div className="relative">
                    <div className="aspect-square overflow-hidden rounded-full p-4">
                      <Image
                        src={artist.image || "/placeholder.svg"}
                        alt={artist.name}
                        width={200}
                        height={200}
                        className="aspect-square w-full rounded-full object-cover"
                      />
                    </div>
                  </div>
                  <div className="p-4 text-center">
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
    );
  };

  const renderAlbums = () => {
    if (savedAlbums.length === 0) {
      return <LibraryEmptyState />;
    }

    return (
      <section className="py-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">
              {t("library.albums.title")}
            </h2>
            <p className="text-sm text-muted-foreground">
              {t("library.albums.description")}
            </p>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-6 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
          {savedAlbums.map((album) => (
            <Link href="#" key={album.id} className="block">
              <Card className="overflow-hidden transition-all hover:shadow-md">
                <CardContent className="p-0">
                  <div className="relative">
                    <Image
                      src={album.image || "/placeholder.svg"}
                      alt={`${album.title} album cover`}
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
                      {album.artist} • {album.releaseYear}
                    </p>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))}
        </div>
      </section>
    );
  };

  const renderSongs = () => {
    if (likedSongs.length === 0) {
      return <LibraryEmptyState />;
    }

    return (
      <section className="py-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">
              {t("library.tracks.title")}
            </h2>
            <p className="text-sm text-muted-foreground">
              {t("library.tracks.description")}
            </p>
          </div>
        </div>
        <Card>
          <CardContent className="p-0">
            <div className="relative overflow-hidden rounded-md">
              <div className="flex items-center gap-4 p-4 bg-muted/50">
                <div className="flex h-16 w-16 items-center justify-center rounded-md bg-primary">
                  <Heart className="h-8 w-8 text-primary-foreground" />
                </div>
                <div>
                  <h3 className="text-xl font-bold">
                    {t("library.tracks.title")}
                  </h3>
                  <p className="text-sm text-muted-foreground">
                    {likedSongs.length} {t("library.tracks.count")}
                  </p>
                </div>
                <div className="ml-auto flex gap-2">
                  <Button size="sm" variant="secondary" className="gap-1">
                    <Download className="h-4 w-4" />
                    {t("library.download")}
                  </Button>
                  <Button size="sm" className="gap-1">
                    <Play className="h-4 w-4" />
                    {t("player.play")}
                  </Button>
                </div>
              </div>
              <div className="p-4">
                {likedSongs.map((song, index) => (
                  <div
                    key={song.id}
                    className="flex items-center gap-4 py-2 hover:bg-muted/50 rounded-md px-2"
                  >
                    <span className="w-6 text-center text-muted-foreground">
                      {index + 1}
                    </span>
                    <Image
                      src={song.image || "/placeholder.svg"}
                      alt={`${song.title} album cover`}
                      width={40}
                      height={40}
                      className="rounded-md"
                    />
                    <div className="flex-1 min-w-0">
                      <p className="font-medium truncate">{song.title}</p>
                      <p className="text-sm text-muted-foreground truncate">
                        {song.artist}
                      </p>
                    </div>
                    <div className="hidden md:block text-sm text-muted-foreground truncate">
                      {song.album}
                    </div>
                    <div className="flex items-center gap-4">
                      <Heart className="h-4 w-4 text-primary" />
                      <span className="text-sm text-muted-foreground">
                        {song.duration}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </CardContent>
        </Card>
      </section>
    );
  };

  return (
    <main className="flex-1 pb-20">
      <section className="container py-8">
        <div className="space-y-2">
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            {t("library.title")}
          </h1>
          <p className="text-muted-foreground">{t("library.subtitle")}</p>
        </div>
      </section>

      <section className="container">
        <LibraryFilterTabs
          activeFilter={activeFilter}
          onFilterChange={setActiveFilter}
        />
      </section>

      <div className="container">{renderContent()}</div>
    </main>
  );
}
