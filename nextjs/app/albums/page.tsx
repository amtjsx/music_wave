import { Suspense } from "react";
import Link from "next/link";
import Image from "next/image";
import { ChevronRight, Filter, Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { AlbumCard } from "./album-card";
import { Skeleton } from "@/components/ui/skeleton";

// Mock data for albums
const featuredAlbums = [
  {
    id: "1",
    title: "Midnight Waves",
    artist: "Luna Echo",
    artistId: "luna-echo",
    coverUrl: "/album-cover-1.png",
    releaseDate: "2023-05-15",
    trackCount: 12,
    trustScore: 92,
    isVerified: true,
    genre: "Electronic",
  },
  {
    id: "2",
    title: "Purple Haze",
    artist: "Violet Dreams",
    artistId: "violet-dreams",
    coverUrl: "/album-cover-2.png",
    releaseDate: "2023-04-22",
    trackCount: 10,
    trustScore: 88,
    isVerified: true,
    genre: "Pop",
  },
  {
    id: "3",
    title: "Digital Pulse",
    artist: "Byte Beats",
    artistId: "byte-beats",
    coverUrl: "/album-cover-3.png",
    releaseDate: "2023-06-01",
    trackCount: 8,
    trustScore: 85,
    isVerified: false,
    genre: "Electronic",
  },
  {
    id: "4",
    title: "Urban Flow",
    artist: "City Soundscape",
    artistId: "city-soundscape",
    coverUrl: "/album-cover-4.png",
    releaseDate: "2023-03-18",
    trackCount: 14,
    trustScore: 90,
    isVerified: true,
    genre: "Hip Hop",
  },
];

const newReleases = [
  {
    id: "5",
    title: "Acoustic Journey",
    artist: "Harmony Woods",
    artistId: "harmony-woods",
    coverUrl: "/album-cover-5.png",
    releaseDate: "2023-06-10",
    trackCount: 9,
    trustScore: 82,
    isVerified: false,
    genre: "Indie",
  },
  {
    id: "6",
    title: "Jazz Nights",
    artist: "Smooth Quartet",
    artistId: "smooth-quartet",
    coverUrl: "/album-cover-6.png",
    releaseDate: "2023-06-05",
    trackCount: 7,
    trustScore: 94,
    isVerified: true,
    genre: "Jazz",
  },
  {
    id: "7",
    title: "Classical Reimagined",
    artist: "Modern Orchestra",
    artistId: "modern-orchestra",
    coverUrl: "/album-cover-7.png",
    releaseDate: "2023-06-08",
    trackCount: 11,
    trustScore: 91,
    isVerified: true,
    genre: "Classical",
  },
  {
    id: "8",
    title: "Summer Vibes",
    artist: "Beach Tones",
    artistId: "beach-tones",
    coverUrl: "/album-cover-8.png",
    releaseDate: "2023-06-12",
    trackCount: 10,
    trustScore: 86,
    isVerified: false,
    genre: "Pop",
  },
];

const trendingAlbums = [...featuredAlbums.slice(2), ...newReleases.slice(0, 2)];

const recommendedAlbums = [
  ...newReleases.slice(2),
  ...featuredAlbums.slice(0, 2),
];

export default function AlbumsPage() {
  return (
    <main className="container mx-auto px-4 py-6">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Albums</h1>
          <p className="text-muted-foreground mt-1">
            Discover new music and complete collections
          </p>
        </div>
        <div className="flex items-center gap-2 w-full md:w-auto">
          <div className="relative w-full md:w-[300px]">
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder="Search albums..."
              className="pl-8 w-full"
            />
          </div>
          <Button variant="outline" size="icon">
            <Filter className="h-4 w-4" />
            <span className="sr-only">Filter</span>
          </Button>
        </div>
      </div>

      <section className="mb-10">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-2xl font-bold">Featured Albums</h2>
          <Button variant="link" className="text-primary" asChild>
            <Link href="/albums/featured">
              View all <ChevronRight className="h-4 w-4 ml-1" />
            </Link>
          </Button>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 md:gap-6">
          {featuredAlbums.map((album) => (
            <AlbumCard key={album.id} album={album} />
          ))}
        </div>
      </section>

      <section className="space-y-4">
        <div className="mt-0 space-y-4">
          <h2 className="text-2xl font-bold">New Albums</h2>

          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 md:gap-6">
            <Suspense
              fallback={Array(8)
                .fill(0)
                .map((_, i) => (
                  <div key={i} className="space-y-2">
                    <Skeleton className="h-[160px] sm:h-[180px] md:h-[200px] w-full rounded-md" />
                    <Skeleton className="h-4 w-3/4" />
                    <Skeleton className="h-4 w-1/2" />
                  </div>
                ))}
            >
              {newReleases.map((album) => (
                <AlbumCard key={album.id} album={album} />
              ))}
            </Suspense>
          </div>
        </div>

        <div className="mt-0 space-y-4">
          <h2 className="text-2xl font-bold">Trending Albums</h2>

          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 md:gap-6">
            {trendingAlbums.map((album) => (
              <AlbumCard key={album.id} album={album} />
            ))}
          </div>
        </div>

        <div className="mt-0 space-y-4">
          <h2 className="text-2xl font-bold">Recommended Albums</h2>

          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4 md:gap-6">
            {recommendedAlbums.map((album) => (
              <AlbumCard key={album.id} album={album} />
            ))}
          </div>
        </div>
      </section>

      <section className="mb-10">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-2xl font-bold">Genres</h2>
          <Button variant="link" className="text-primary" asChild>
            <Link href="/genres">
              View all <ChevronRight className="h-4 w-4 ml-1" />
            </Link>
          </Button>
        </div>
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-4">
          {["Pop", "Electronic", "Hip Hop", "Indie", "Jazz", "Classical"].map(
            (genre) => (
              <Link
                key={genre}
                href={`/albums?genre=${genre.toLowerCase()}`}
                className="group relative overflow-hidden rounded-md aspect-square"
              >
                <Image
                  src={`/album-cover-${
                    [
                      "Pop",
                      "Electronic",
                      "Hip Hop",
                      "Indie",
                      "Jazz",
                      "Classical",
                    ].indexOf(genre) + 3
                  }.png`}
                  alt={genre}
                  fill
                  className="object-cover transition-transform group-hover:scale-105"
                />
                <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                  <span className="text-white font-semibold text-lg">
                    {genre}
                  </span>
                </div>
              </Link>
            )
          )}
        </div>
      </section>
    </main>
  );
}
