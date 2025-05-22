"use client";

import {
    Calendar,
    Heart,
    MapPin,
    MoreHorizontal,
    Pause,
    Play,
    Share2,
    Users,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { VerifiedBadge } from "@/components/verified-badge";

export default function ArtistProfilePage({
  params,
}: {
  params: { slug: string };
}) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [activeTab, setActiveTab] = useState("tracks");

  // This would come from your API in a real implementation
  const artist = {
    id: "1",
    name: "Jane Doe",
    slug: "jane-doe",
    bio: "Electronic music producer and DJ based in Los Angeles. Known for blending ambient soundscapes with driving beats and melodic elements.",
    followers: 24500,
    isVerified: true,
    verificationDate: "May 18, 2025",
    genres: ["Electronic", "Ambient", "Techno"],
    location: "Los Angeles, CA",
    joinedDate: "January 2023",
    socialLinks: {
      spotify: "https://open.spotify.com/artist/example",
      instagram: "https://instagram.com/janedoe",
      twitter: "https://twitter.com/janedoe",
      website: "https://janedoemusic.com",
    },
  };

  // Sample tracks
  const tracks = [
    {
      id: "1",
      title: "Midnight Dreams",
      album: "Echoes",
      duration: "3:45",
      plays: 845200,
    },
    {
      id: "2",
      title: "Ocean Waves",
      album: "Echoes",
      duration: "4:12",
      plays: 632700,
    },
    {
      id: "3",
      title: "Starlight",
      album: "Cosmos",
      duration: "5:30",
      plays: 521300,
    },
    {
      id: "4",
      title: "Electric Soul",
      album: "Voltage",
      duration: "3:58",
      plays: 412800,
    },
    {
      id: "5",
      title: "Neon Lights",
      album: "Voltage",
      duration: "4:25",
      plays: 387500,
    },
  ];

  // Sample upcoming events
  const events = [
    {
      id: "1",
      name: "Summer Electronic Festival",
      location: "Los Angeles, CA",
      date: "June 15, 2025",
    },
    {
      id: "2",
      name: "Club Horizon",
      location: "New York, NY",
      date: "July 8, 2025",
    },
    {
      id: "3",
      name: "Ambient Nights",
      location: "Berlin, Germany",
      date: "August 22, 2025",
    },
  ];

  const formatNumber = (num: number) => {
    if (num >= 1000000) {
      return (num / 1000000).toFixed(1) + "M";
    }
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + "K";
    }
    return num.toString();
  };

  return (
    <div className="flex flex-col gap-6">
      {/* Artist Header */}
      <div className="relative">
        {/* Cover Image */}
        <div className="relative h-48 w-full overflow-hidden rounded-xl md:h-64">
          <Image
            src="/abstract-music-cover.png"
            alt="Artist Cover"
            fill
            className="object-cover"
            priority
          />
        </div>

        {/* Artist Info */}
        <div className="relative mt-[-4rem] flex flex-col items-start gap-4 px-4 md:flex-row md:items-end md:px-6">
          <Avatar className="h-32 w-32 border-4 border-background md:h-40 md:w-40">
            <AvatarImage src="/artist-profile.png" alt={artist.name} />
            <AvatarFallback>{artist.name.charAt(0)}</AvatarFallback>
          </Avatar>

          <div className="flex flex-1 flex-col gap-2">
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold md:text-3xl">{artist.name}</h1>
              {artist.isVerified && (
                <VerifiedBadge
                  size="md"
                  variant="default"
                  verificationDate={artist.verificationDate}
                />
              )}
            </div>

            <div className="flex flex-wrap gap-2">
              {artist.genres.map((genre) => (
                <Badge key={genre} variant="secondary">
                  {genre}
                </Badge>
              ))}
            </div>

            <div className="flex items-center gap-4 text-sm text-muted-foreground">
              <div className="flex items-center gap-1">
                <Users className="h-4 w-4" />
                <span>{formatNumber(artist.followers)} followers</span>
              </div>
              <div className="flex items-center gap-1">
                <MapPin className="h-4 w-4" />
                <span>{artist.location}</span>
              </div>
              <div className="flex items-center gap-1">
                <Calendar className="h-4 w-4" />
                <span>Joined {artist.joinedDate}</span>
              </div>
            </div>
          </div>

          <div className="flex w-full flex-wrap gap-2 md:w-auto md:justify-end">
            <Button className="gap-2 bg-purple-600 hover:bg-purple-700">
              <Play className="h-4 w-4" /> Play All
            </Button>
            <Button variant="outline" className="gap-2">
              <Heart className="h-4 w-4" /> Follow
            </Button>
            <Button variant="outline" size="icon">
              <Share2 className="h-4 w-4" />
            </Button>
            <Button variant="outline" size="icon">
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>

      {/* Artist Bio */}
      <div className="px-4 md:px-6">
        <p className="text-muted-foreground">{artist.bio}</p>
      </div>

      <Separator />

      {/* Content Tabs */}
      <Tabs
        value={activeTab}
        onValueChange={setActiveTab}
        className="px-4 md:px-6"
      >
        <TabsList>
          <TabsTrigger value="tracks">Tracks</TabsTrigger>
          <TabsTrigger value="albums">Albums</TabsTrigger>
          <TabsTrigger value="events">Events</TabsTrigger>
          <TabsTrigger value="about">About</TabsTrigger>
        </TabsList>

        {/* Tracks Tab */}
        <TabsContent value="tracks" className="mt-6">
          <div className="space-y-4">
            {tracks.map((track, index) => (
              <div
                key={track.id}
                className="group flex items-center justify-between rounded-md p-3 hover:bg-muted"
              >
                <div className="flex items-center gap-4">
                  <div className="flex h-10 w-10 items-center justify-center rounded-md bg-muted group-hover:bg-background">
                    {isPlaying && index === 0 ? (
                      <Pause
                        className="h-5 w-5 cursor-pointer text-purple-600"
                        onClick={() => setIsPlaying(false)}
                      />
                    ) : (
                      <Play
                        className="h-5 w-5 cursor-pointer"
                        onClick={() => setIsPlaying(true)}
                      />
                    )}
                  </div>
                  <div>
                    <div className="font-medium">{track.title}</div>
                    <div className="text-xs text-muted-foreground">
                      Album: {track.album}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <span className="text-sm text-muted-foreground">
                    {formatNumber(track.plays)} plays
                  </span>
                  <span className="text-sm text-muted-foreground">
                    {track.duration}
                  </span>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="opacity-0 group-hover:opacity-100"
                  >
                    <Heart className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="opacity-0 group-hover:opacity-100"
                  >
                    <MoreHorizontal className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            ))}
          </div>
        </TabsContent>

        {/* Events Tab */}
        <TabsContent value="events" className="mt-6">
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {events.map((event) => (
              <Card key={event.id}>
                <CardContent className="p-4">
                  <div className="flex flex-col gap-2">
                    <h3 className="font-semibold">{event.name}</h3>
                    <div className="flex items-center gap-1 text-sm text-muted-foreground">
                      <Calendar className="h-4 w-4" />
                      <span>{event.date}</span>
                    </div>
                    <div className="flex items-center gap-1 text-sm text-muted-foreground">
                      <MapPin className="h-4 w-4" />
                      <span>{event.location}</span>
                    </div>
                    <Button className="mt-2 w-full bg-purple-600 hover:bg-purple-700">
                      Get Tickets
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>

        {/* About Tab */}
        <TabsContent value="about" className="mt-6">
          <div className="grid gap-6 md:grid-cols-2">
            <div>
              <h3 className="mb-3 text-lg font-semibold">Biography</h3>
              <p className="text-muted-foreground">{artist.bio}</p>

              <h3 className="mb-3 mt-6 text-lg font-semibold">Genres</h3>
              <div className="flex flex-wrap gap-2">
                {artist.genres.map((genre) => (
                  <Badge key={genre} variant="secondary">
                    {genre}
                  </Badge>
                ))}
              </div>
            </div>

            <div>
              <h3 className="mb-3 text-lg font-semibold">Connect</h3>
              <div className="space-y-3">
                {Object.entries(artist.socialLinks).map(([platform, url]) => (
                  <Link
                    key={platform}
                    href={url}
                    className="flex items-center gap-2 text-sm text-purple-600 hover:underline"
                  >
                    {platform === "spotify" && (
                      <svg
                        className="h-4 w-4"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z" />
                      </svg>
                    )}
                    {platform === "instagram" && (
                      <svg
                        className="h-4 w-4"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z" />
                      </svg>
                    )}
                    {platform === "twitter" && (
                      <svg
                        className="h-4 w-4"
                        viewBox="0 0 24 24"
                        fill="currentColor"
                      >
                        <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z" />
                      </svg>
                    )}
                    {platform === "website" && (
                      <svg
                        className="h-4 w-4"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        strokeWidth="2"
                        strokeLinecap="round"
                        strokeLinejoin="round"
                      >
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="2" y1="12" x2="22" y2="12"></line>
                        <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"></path>
                      </svg>
                    )}
                    {platform.charAt(0).toUpperCase() + platform.slice(1)}
                  </Link>
                ))}
              </div>

              <div className="mt-6">
                <h3 className="mb-3 text-lg font-semibold">Verification</h3>
                <div className="rounded-md bg-muted p-4">
                  <div className="flex items-center gap-2">
                    <VerifiedBadge
                      size="md"
                      variant="default"
                      showTooltip={false}
                    />
                    <span className="font-medium">Verified Artist</span>
                  </div>
                  <p className="mt-2 text-sm text-muted-foreground">
                    This artist has been verified by MusicWave as authentic.
                    {artist.verificationDate &&
                      ` Verified on ${artist.verificationDate}.`}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
