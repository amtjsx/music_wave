"use client";


import {
  Clock,
  Download,
  Heart,
  MoreHorizontal,
  Music,
  Play,
  Plus,
  Share2,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useEffect, useState } from "react";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useTranslation } from "@/hooks/use-translation";
import {
  getAlbumArtPlaceholder,
  getColoredPlaceholder,
} from "@/utils/image-utils";

// Sample playlists data
const samplePlaylists = [
  {
    id: "1",
    title: "My Favorites",
    description: "All my favorite songs in one playlist",
    creator: "Your Name",
    coverArt: getColoredPlaceholder(300, 300, "ec4899"),
    isPublic: true,
    followers: 12,
    trackCount: 42,
    totalDuration: "2h 45m",
    createdAt: "2023-05-15",
    isInLibrary: true,
    isCreatedByUser: true,
    tracks: [
      {
        id: "101",
        title: "Blinding Lights",
        artist: "The Weeknd",
        album: "After Hours",
        duration: "3:20",
        dateAdded: "2023-05-15",
        coverArt: getAlbumArtPlaceholder(40, 40, "Blinding Lights", "8b5cf6"),
        isLiked: true,
      },
      {
        id: "102",
        title: "Shape of You",
        artist: "Ed Sheeran",
        album: "÷ (Divide)",
        duration: "3:53",
        dateAdded: "2023-05-15",
        coverArt: getAlbumArtPlaceholder(40, 40, "Shape of You", "ec4899"),
        isLiked: false,
      },
      {
        id: "103",
        title: "Dance Monkey",
        artist: "Tones and I",
        album: "The Kids Are Coming",
        duration: "3:29",
        dateAdded: "2023-05-16",
        coverArt: getAlbumArtPlaceholder(40, 40, "Dance Monkey", "f97316"),
        isLiked: true,
      },
      {
        id: "104",
        title: "Someone You Loved",
        artist: "Lewis Capaldi",
        album: "Divinely Uninspired to a Hellish Extent",
        duration: "3:02",
        dateAdded: "2023-05-16",
        coverArt: getAlbumArtPlaceholder(40, 40, "Someone You Loved", "22c55e"),
        isLiked: false,
      },
      {
        id: "105",
        title: "Watermelon Sugar",
        artist: "Harry Styles",
        album: "Fine Line",
        duration: "2:54",
        dateAdded: "2023-05-17",
        coverArt: getAlbumArtPlaceholder(40, 40, "Watermelon Sugar", "3b82f6"),
        isLiked: true,
      },
    ],
  },
  {
    id: "2",
    title: "Workout Mix",
    description: "High energy tracks for exercise",
    creator: "Your Name",
    coverArt: getColoredPlaceholder(300, 300, "8b5cf6"),
    isPublic: false,
    followers: 5,
    trackCount: 28,
    totalDuration: "1h 52m",
    createdAt: "2023-06-10",
    isInLibrary: true,
    isCreatedByUser: true,
    tracks: [
      {
        id: "201",
        title: "Eye of the Tiger",
        artist: "Survivor",
        album: "Eye of the Tiger",
        duration: "4:05",
        dateAdded: "2023-06-10",
        coverArt: getAlbumArtPlaceholder(40, 40, "Eye of the Tiger", "f43f5e"),
        isLiked: true,
      },
      {
        id: "202",
        title: "Can't Hold Us",
        artist: "Macklemore & Ryan Lewis",
        album: "The Heist",
        duration: "4:18",
        dateAdded: "2023-06-10",
        coverArt: getAlbumArtPlaceholder(40, 40, "Can't Hold Us", "06b6d4"),
        isLiked: false,
      },
      {
        id: "203",
        title: "Stronger",
        artist: "Kanye West",
        album: "Graduation",
        duration: "5:12",
        dateAdded: "2023-06-11",
        coverArt: getAlbumArtPlaceholder(40, 40, "Stronger", "eab308"),
        isLiked: true,
      },
    ],
  },
  {
    id: "3",
    title: "Chill Vibes",
    description: "Relaxing music for downtime",
    creator: "SoundWave",
    coverArt: getColoredPlaceholder(300, 300, "3b82f6"),
    isPublic: true,
    followers: 1243,
    trackCount: 35,
    totalDuration: "2h 15m",
    createdAt: "2023-04-22",
    isInLibrary: true,
    isCreatedByUser: false,
    tracks: [
      {
        id: "301",
        title: "Circles",
        artist: "Post Malone",
        album: "Hollywood's Bleeding",
        duration: "3:35",
        dateAdded: "2023-04-22",
        coverArt: getAlbumArtPlaceholder(40, 40, "Circles", "8b5cf6"),
        isLiked: false,
      },
      {
        id: "302",
        title: "Sunflower",
        artist: "Post Malone, Swae Lee",
        album: "Spider-Man: Into the Spider-Verse",
        duration: "2:38",
        dateAdded: "2023-04-22",
        coverArt: getAlbumArtPlaceholder(40, 40, "Sunflower", "eab308"),
        isLiked: true,
      },
      {
        id: "303",
        title: "Memories",
        artist: "Maroon 5",
        album: "Memories",
        duration: "3:09",
        dateAdded: "2023-04-23",
        coverArt: getAlbumArtPlaceholder(40, 40, "Memories", "ec4899"),
        isLiked: false,
      },
    ],
  },
];

export default function PlaylistPage() {
  const { t } = useTranslation("playlist");
  const params = useParams();
  const [playlist, setPlaylist] = useState<(typeof samplePlaylists)[0] | null>(
    null
  );
  const [isLoading, setIsLoading] = useState(true);

  // Fetch playlist data based on ID
  useEffect(() => {
    const playlistId = params.id as string;
    // Simulate API call
    setTimeout(() => {
      const foundPlaylist = samplePlaylists.find((p) => p.id === playlistId);
      setPlaylist(foundPlaylist || null);
      setIsLoading(false);
    }, 500);
  }, [params.id]);

  // Toggle like status for a track
  const toggleLike = (trackId: string) => {
    if (!playlist) return;

    setPlaylist({
      ...playlist,
      tracks: playlist.tracks.map((track) =>
        track.id === trackId ? { ...track, isLiked: !track.isLiked } : track
      ),
    });
  };

  // Toggle library status for the playlist
  const toggleLibrary = () => {
    if (!playlist) return;

    setPlaylist({
      ...playlist,
      isInLibrary: !playlist.isInLibrary,
    });
  };

  if (isLoading) {
    return (
      <main className="flex-1 pb-20">
        <div className="container py-8">
          <div className="animate-pulse">
            <div className="flex flex-col md:flex-row gap-8">
              <div className="w-64 h-64 bg-muted rounded-lg"></div>
              <div className="flex flex-col justify-end gap-2">
                <div className="h-6 w-24 bg-muted rounded"></div>
                <div className="h-10 w-64 bg-muted rounded"></div>
                <div className="h-6 w-48 bg-muted rounded"></div>
                <div className="h-6 w-32 bg-muted rounded"></div>
              </div>
            </div>
            <div className="mt-8">
              <div className="h-10 w-full bg-muted rounded"></div>
              {[1, 2, 3, 4, 5].map((i) => (
                <div
                  key={i}
                  className="h-16 w-full bg-muted rounded mt-2"
                ></div>
              ))}
            </div>
          </div>
        </div>
      </main>
    );
  }

  if (!playlist) {
    return (
      <main className="flex-1 pb-20">
        <div className="container py-8 text-center">
          <h1 className="text-3xl font-bold mb-4">Playlist not found</h1>
          <p className="text-muted-foreground mb-6">
            The playlist you're looking for doesn't exist or has been removed.
          </p>
          <Button asChild>
            <Link href="/library">Go to Library</Link>
          </Button>
        </div>
      </main>
    );
  }

  return (
    <main className="flex-1 pb-20">
      {/* Playlist Header */}
      <div className="bg-gradient-to-b from-primary/10 to-background pt-8">
        <div className="container">
          <div className="flex flex-col md:flex-row gap-8">
            {/* Playlist Cover */}
            <div className="w-64 h-64 flex-shrink-0 rounded-lg overflow-hidden shadow-lg">
              <Image
                src={playlist.coverArt || "/placeholder.svg"}
                alt={playlist.title}
                width={300}
                height={300}
                className="w-full h-full object-cover"
              />
            </div>

            {/* Playlist Info */}
            <div className="flex flex-col justify-end">
              <div className="flex items-center gap-2 mb-2">
                <Badge variant={playlist.isPublic ? "default" : "outline"}>
                  {playlist.isPublic
                    ? t("playlist.public")
                    : t("playlist.private")}
                </Badge>
                {playlist.isCreatedByUser && (
                  <Badge variant="outline">{t("library.created")}</Badge>
                )}
              </div>
              <h1 className="text-3xl font-bold md:text-4xl lg:text-5xl mb-2">
                {playlist.title}
              </h1>
              <p className="text-muted-foreground mb-2">
                {playlist.description}
              </p>
              <div className="flex items-center gap-1 text-sm text-muted-foreground mb-4">
                <span className="font-medium">{playlist.creator}</span>
                <span>•</span>
                <span>
                  {playlist.trackCount} {t("playlist.tracks")}
                </span>
                <span>•</span>
                <span>{playlist.totalDuration}</span>
                {playlist.followers > 0 && (
                  <>
                    <span>•</span>
                    <span>
                      {playlist.followers} {t("playlist.followers")}
                    </span>
                  </>
                )}
              </div>

              {/* Action Buttons */}
              <div className="flex flex-wrap gap-3">
                <Button size="lg" className="gap-2">
                  <Play className="h-5 w-5" />
                  {t("playlist.playAll")}
                </Button>

                <Button
                  variant="outline"
                  size="lg"
                  onClick={toggleLibrary}
                  className="gap-2"
                >
                  {playlist.isInLibrary ? (
                    <>{t("playlist.removeFromLibrary")}</>
                  ) : (
                    <>{t("playlist.addToLibrary")}</>
                  )}
                </Button>

                <Button variant="outline" size="icon">
                  <Download className="h-5 w-5" />
                  <span className="sr-only">{t("playlist.download")}</span>
                </Button>

                <Button variant="outline" size="icon">
                  <Share2 className="h-5 w-5" />
                  <span className="sr-only">{t("playlist.share")}</span>
                </Button>

                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" size="icon">
                      <MoreHorizontal className="h-5 w-5" />
                      <span className="sr-only">{t("playlist.more")}</span>
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem>
                      {t("playlist.addToQueue")}
                    </DropdownMenuItem>
                    {playlist.isCreatedByUser && (
                      <>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem>
                          {t("playlist.editPlaylist")}
                        </DropdownMenuItem>
                        <DropdownMenuItem className="text-destructive">
                          {t("playlist.deletePlaylist")}
                        </DropdownMenuItem>
                      </>
                    )}
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Playlist Tracks */}
      <div className="container py-8">
        {playlist.tracks.length > 0 ? (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-[60px]">#</TableHead>
                <TableHead>Title</TableHead>
                <TableHead className="hidden md:table-cell">
                  {t("playlist.album")}
                </TableHead>
                <TableHead className="hidden lg:table-cell">
                  {t("playlist.dateAdded")}
                </TableHead>
                <TableHead className="text-right">
                  <Clock className="ml-auto h-4 w-4" />
                  <span className="sr-only">{t("playlist.duration")}</span>
                </TableHead>
                <TableHead className="w-[70px]"></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {playlist.tracks.map((track, index) => (
                <TableRow key={track.id} className="group">
                  <TableCell className="font-medium">{index + 1}</TableCell>
                  <TableCell>
                    <div className="flex items-center space-x-3">
                      <Image
                        src={track.coverArt || "/placeholder.svg"}
                        alt={`${track.title} album cover`}
                        width={40}
                        height={40}
                        className="rounded-md"
                      />
                      <div>
                        <div className="font-medium">{track.title}</div>
                        <div className="text-sm text-muted-foreground">
                          {track.artist}
                        </div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="hidden md:table-cell">
                    {track.album}
                  </TableCell>
                  <TableCell className="hidden lg:table-cell text-muted-foreground">
                    {track.dateAdded}
                  </TableCell>
                  <TableCell className="text-right text-muted-foreground">
                    {track.duration}
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center justify-end gap-2">
                      <Button
                        variant="ghost"
                        size="icon"
                        className="opacity-0 group-hover:opacity-100 transition-opacity"
                        onClick={() => toggleLike(track.id)}
                      >
                        <Heart
                          className={`h-4 w-4 ${
                            track.isLiked ? "fill-primary text-primary" : ""
                          }`}
                        />
                        <span className="sr-only">
                          {track.isLiked
                            ? t("library.liked")
                            : t("library.liked")}
                        </span>
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        className="opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        <MoreHorizontal className="h-4 w-4" />
                        <span className="sr-only">{t("playlist.more")}</span>
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        ) : (
          <div className="flex flex-col items-center justify-center py-16 text-center">
            <div className="mb-4 rounded-full bg-muted p-6">
              <Music className="h-12 w-12 text-muted-foreground" />
            </div>
            <h3 className="mb-2 text-xl font-semibold">
              {t("playlist.noTracks")}
            </h3>
            {playlist.isCreatedByUser && (
              <Button className="mt-4 gap-2">
                <Plus className="h-4 w-4" />
                {t("playlist.addTracks")}
              </Button>
            )}
          </div>
        )}
      </div>
    </main>
  );
}
