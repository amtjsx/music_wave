"use client";

import { useState, useEffect } from "react";
import { useParams, useRouter } from "next/navigation";
import Image from "next/image";
import {
  ArrowLeft,
  Edit,
  MoreHorizontal,
  Play,
  Plus,
  Trash2,
} from "lucide-react";

import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  getAlbumArtPlaceholder,
  getColoredPlaceholder,
} from "@/utils/image-utils";
import { useTranslation } from "@/hooks/use-translation";

// Sample data for albums
const albumsData = [
  {
    id: "1",
    title: "Summer Collection",
    description: "A collection of summer-themed tracks",
    releaseDate: "2023-06-15",
    tracks: 8,
    plays: 105920,
    status: "published",
    coverArt: getColoredPlaceholder(300, 300, "ec4899"),
    trackList: [
      {
        id: "101",
        title: "Summer Vibes",
        duration: "3:45",
        plays: 45280,
        status: "published",
        coverArt: getAlbumArtPlaceholder(40, 40, "Summer Vibes", "ec4899"),
      },
      {
        id: "102",
        title: "Midnight Dreams",
        duration: "4:20",
        plays: 32150,
        status: "published",
        coverArt: getAlbumArtPlaceholder(40, 40, "Midnight Dreams", "ec4899"),
      },
      {
        id: "103",
        title: "Ocean Waves",
        duration: "3:12",
        plays: 28490,
        status: "published",
        coverArt: getAlbumArtPlaceholder(40, 40, "Ocean Waves", "ec4899"),
      },
    ],
  },
  {
    id: "2",
    title: "Winter Melodies",
    description: "Cozy winter tracks to warm your soul",
    releaseDate: "2022-12-01",
    tracks: 10,
    plays: 87450,
    status: "published",
    coverArt: getColoredPlaceholder(300, 300, "8b5cf6"),
    trackList: [
      {
        id: "201",
        title: "Winter Wonderland",
        duration: "3:58",
        plays: 18720,
        status: "published",
        coverArt: getAlbumArtPlaceholder(40, 40, "Winter Wonderland", "8b5cf6"),
      },
      {
        id: "202",
        title: "Snowfall",
        duration: "4:05",
        plays: 15640,
        status: "published",
        coverArt: getAlbumArtPlaceholder(40, 40, "Snowfall", "8b5cf6"),
      },
    ],
  },
  {
    id: "4",
    title: "Upcoming Album",
    description: "Work in progress album",
    releaseDate: "-",
    tracks: 2,
    plays: 0,
    status: "draft",
    coverArt: getColoredPlaceholder(300, 300, "f97316"),
    trackList: [
      {
        id: "401",
        title: "New Track Demo",
        duration: "3:22",
        plays: 0,
        status: "draft",
        coverArt: getAlbumArtPlaceholder(40, 40, "New Track Demo", "f97316"),
      },
      {
        id: "402",
        title: "Upcoming Hit",
        duration: "2:55",
        plays: 0,
        status: "draft",
        coverArt: getAlbumArtPlaceholder(40, 40, "Upcoming Hit", "f97316"),
      },
    ],
  },
];

export default function AlbumDetailPage() {
  const { t } = useTranslation("artist");
  const params = useParams();
  const router = useRouter();
  const [album, setAlbum] = useState<(typeof albumsData)[0] | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const albumId = params.id as string;
    // Simulate API call
    setTimeout(() => {
      const foundAlbum = albumsData.find((a) => a.id === albumId);
      setAlbum(foundAlbum || null);
      setIsLoading(false);
    }, 500);
  }, [params.id]);

  if (isLoading) {
    return (
      <div className="space-y-6">
        <div className="animate-pulse">
          <div className="h-8 w-64 bg-muted rounded mb-2"></div>
          <div className="h-4 w-48 bg-muted rounded"></div>
        </div>
        <div className="animate-pulse flex flex-col md:flex-row gap-6">
          <div className="w-full md:w-64 h-64 bg-muted rounded"></div>
          <div className="flex-1 space-y-4">
            <div className="h-6 w-48 bg-muted rounded"></div>
            <div className="h-4 w-full bg-muted rounded"></div>
            <div className="h-4 w-3/4 bg-muted rounded"></div>
            <div className="h-10 w-32 bg-muted rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!album) {
    return (
      <div className="space-y-6">
        <Button variant="ghost" onClick={() => router.back()} className="mb-4">
          <ArrowLeft className="mr-2 h-4 w-4" />
          {t("artist.back")}
        </Button>
        <div className="text-center py-12">
          <h2 className="text-2xl font-bold mb-2">
            {t("artist.albumNotFound")}
          </h2>
          <p className="text-muted-foreground mb-6">
            {t("artist.albumNotFoundDescription")}
          </p>
          <Button asChild>
            <a href="/artist/music">{t("artist.backToMusic")}</a>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <Button variant="ghost" onClick={() => router.back()} className="mb-4">
        <ArrowLeft className="mr-2 h-4 w-4" />
        {t("artist.back")}
      </Button>

      <div className="flex flex-col gap-6 md:flex-row">
        {/* Album Cover and Info */}
        <div className="w-full md:w-64">
          <Card className="overflow-hidden">
            <CardContent className="p-0">
              <div className="relative">
                <Image
                  src={album.coverArt || "/placeholder.svg"}
                  alt={album.title}
                  width={300}
                  height={300}
                  className="aspect-square w-full object-cover"
                />
                {album.status === "draft" && (
                  <span className="absolute top-2 right-2 rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300">
                    {t("artist.draft")}
                  </span>
                )}
              </div>
              <div className="p-4">
                <h2 className="text-xl font-bold">{album.title}</h2>
                <p className="text-sm text-muted-foreground">
                  {album.tracks} tracks •{" "}
                  {album.releaseDate !== "-"
                    ? new Date(album.releaseDate).getFullYear()
                    : t("artist.unreleased")}
                </p>
                <p className="mt-1 text-sm text-muted-foreground">
                  {album.plays.toLocaleString()} plays
                </p>
                <div className="mt-4 flex gap-2">
                  <Button variant="outline" size="sm" className="w-full">
                    <Edit className="mr-2 h-4 w-4" />
                    {t("artist.edit")}
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Tracks List */}
        <div className="flex-1">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-bold">{t("artist.tracks")}</h2>
            <Button size="sm">
              <Plus className="mr-2 h-4 w-4" />
              {t("artist.addTrack")}
            </Button>
          </div>

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[60px]">#</TableHead>
                  <TableHead>{t("artist.title")}</TableHead>
                  <TableHead className="hidden sm:table-cell">
                    {t("artist.duration")}
                  </TableHead>
                  <TableHead className="hidden lg:table-cell">
                    {t("artist.plays")}
                  </TableHead>
                  <TableHead className="hidden sm:table-cell">
                    {t("artist.status")}
                  </TableHead>
                  <TableHead className="w-[70px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {album.trackList.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="h-24 text-center">
                      {t("artist.noTracksInAlbum")}
                    </TableCell>
                  </TableRow>
                ) : (
                  album.trackList.map((track, index) => (
                    <TableRow key={track.id} className="group">
                      <TableCell className="font-medium">{index + 1}</TableCell>
                      <TableCell>
                        <div className="flex items-center space-x-3">
                          <Image
                            src={track.coverArt || "/placeholder.svg"}
                            alt={`${track.title} cover`}
                            width={40}
                            height={40}
                            className="rounded-md"
                          />
                          <div className="font-medium">{track.title}</div>
                        </div>
                      </TableCell>
                      <TableCell className="hidden sm:table-cell">
                        {track.duration}
                      </TableCell>
                      <TableCell className="hidden lg:table-cell">
                        {track.plays.toLocaleString()}
                      </TableCell>
                      <TableCell className="hidden sm:table-cell">
                        <span
                          className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${
                            track.status === "published"
                              ? "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300"
                              : "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300"
                          }`}
                        >
                          {track.status === "published"
                            ? t("artist.published")
                            : t("artist.draft")}
                        </span>
                      </TableCell>
                      <TableCell>
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon">
                              <MoreHorizontal className="h-4 w-4" />
                              <span className="sr-only">
                                {t("artist.actions")}
                              </span>
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            <DropdownMenuItem>
                              <Play className="mr-2 h-4 w-4" />
                              <span>{t("artist.play")}</span>
                            </DropdownMenuItem>
                            <DropdownMenuItem>
                              <Edit className="mr-2 h-4 w-4" />
                              <span>{t("artist.edit")}</span>
                            </DropdownMenuItem>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem className="text-destructive">
                              <Trash2 className="mr-2 h-4 w-4" />
                              <span>{t("artist.delete")}</span>
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </div>
      </div>
    </div>
  );
}
