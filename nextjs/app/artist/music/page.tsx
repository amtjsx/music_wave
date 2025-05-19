"use client";

import { CardContent } from "@/components/ui/card";

import { Card } from "@/components/ui/card";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Edit, MoreHorizontal, Play, Plus, Search, Trash2 } from "lucide-react";

import { useTranslation } from "@/hooks/use-translation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
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

// Sample data for artist's music
const artistMusic = {
  tracks: [
    {
      id: "1",
      title: "Summer Vibes",
      album: "Summer Collection",
      releaseDate: "2023-06-15",
      duration: "3:45",
      plays: 45280,
      status: "published",
      coverArt: getAlbumArtPlaceholder(40, 40, "Summer Vibes", "ec4899"),
    },
    {
      id: "2",
      title: "Midnight Dreams",
      album: "Summer Collection",
      releaseDate: "2023-06-15",
      duration: "4:20",
      plays: 32150,
      status: "published",
      coverArt: getAlbumArtPlaceholder(40, 40, "Midnight Dreams", "ec4899"),
    },
    {
      id: "3",
      title: "Ocean Waves",
      album: "Summer Collection",
      releaseDate: "2023-06-15",
      duration: "3:12",
      plays: 28490,
      status: "published",
      coverArt: getAlbumArtPlaceholder(40, 40, "Ocean Waves", "ec4899"),
    },
    {
      id: "4",
      title: "Winter Wonderland",
      album: "Winter Melodies",
      releaseDate: "2022-12-01",
      duration: "3:58",
      plays: 18720,
      status: "published",
      coverArt: getAlbumArtPlaceholder(40, 40, "Winter Wonderland", "8b5cf6"),
    },
    {
      id: "5",
      title: "Snowfall",
      album: "Winter Melodies",
      releaseDate: "2022-12-01",
      duration: "4:05",
      plays: 15640,
      status: "published",
      coverArt: getAlbumArtPlaceholder(40, 40, "Snowfall", "8b5cf6"),
    },
    {
      id: "6",
      title: "New Track Demo",
      album: "Unreleased",
      releaseDate: "-",
      duration: "3:22",
      plays: 0,
      status: "draft",
      coverArt: getAlbumArtPlaceholder(40, 40, "New Track Demo", "f97316"),
    },
  ],
  albums: [
    {
      id: "1",
      title: "Summer Collection",
      tracks: 8,
      releaseDate: "2023-06-15",
      plays: 105920,
      status: "published",
      coverArt: getColoredPlaceholder(200, 200, "ec4899"),
    },
    {
      id: "2",
      title: "Winter Melodies",
      tracks: 10,
      releaseDate: "2022-12-01",
      plays: 87450,
      status: "published",
      coverArt: getColoredPlaceholder(200, 200, "8b5cf6"),
    },
    {
      id: "3",
      title: "Spring Awakening",
      tracks: 6,
      releaseDate: "2022-03-20",
      plays: 65280,
      status: "published",
      coverArt: getColoredPlaceholder(200, 200, "3b82f6"),
    },
    {
      id: "4",
      title: "Upcoming Album",
      tracks: 2,
      releaseDate: "-",
      plays: 0,
      status: "draft",
      coverArt: getColoredPlaceholder(200, 200, "f97316"),
    },
  ],
};

export default function ArtistMusicPage() {
  const { t } = useTranslation("artist");
  const [searchQuery, setSearchQuery] = useState("");
  const [activeTab, setActiveTab] = useState("tracks");

  // Filter tracks based on search query
  const filteredTracks = artistMusic.tracks.filter(
    (track) =>
      track.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      track.album.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // Filter albums based on search query
  const filteredAlbums = artistMusic.albums.filter((album) =>
    album.title.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            {t("artist.yourMusic")}
          </h1>
          <p className="text-muted-foreground">{t("artist.manageMusic")}</p>
        </div>
        <Button asChild>
          <Link href="/artist/upload">
            <Plus className="mr-2 h-4 w-4" />
            {t("artist.uploadNew")}
          </Link>
        </Button>
      </div>

      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <Tabs
          defaultValue="tracks"
          value={activeTab}
          onValueChange={setActiveTab}
          className="w-full max-w-md"
        >
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="tracks">{t("artist.tracks")}</TabsTrigger>
            <TabsTrigger value="albums">{t("artist.albums")}</TabsTrigger>
          </TabsList>
        </Tabs>
        <div className="relative w-full max-w-sm">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            type="search"
            placeholder={t("artist.searchMusic")}
            className="w-full pl-8"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      <TabsContent value="tracks" className="mt-0">
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead className="w-[60px]">#</TableHead>
                <TableHead>{t("artist.title")}</TableHead>
                <TableHead className="hidden md:table-cell">
                  {t("artist.album")}
                </TableHead>
                <TableHead className="hidden md:table-cell">
                  {t("artist.releaseDate")}
                </TableHead>
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
              {filteredTracks.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} className="h-24 text-center">
                    {searchQuery
                      ? t("artist.noSearchResults")
                      : t("artist.noTracks")}
                  </TableCell>
                </TableRow>
              ) : (
                filteredTracks.map((track, index) => (
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
                        <div>
                          <div className="font-medium">{track.title}</div>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="hidden md:table-cell">
                      {track.album}
                    </TableCell>
                    <TableCell className="hidden md:table-cell">
                      {track.releaseDate !== "-"
                        ? new Date(track.releaseDate).toLocaleDateString()
                        : "-"}
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
      </TabsContent>

      <TabsContent value="albums" className="mt-0">
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4">
          {filteredAlbums.length === 0 ? (
            <div className="col-span-full py-12 text-center">
              <p className="text-lg font-medium">
                {searchQuery
                  ? t("artist.noSearchResults")
                  : t("artist.noAlbums")}
              </p>
            </div>
          ) : (
            filteredAlbums.map((album) => (
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
                      {album.status === "draft" && (
                        <span className="absolute top-2 right-2 rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300">
                          {t("artist.draft")}
                        </span>
                      )}
                    </div>
                    <div className="p-4">
                      <h3 className="font-semibold">{album.title}</h3>
                      <p className="text-sm text-muted-foreground">
                        {album.tracks} tracks •{" "}
                        {album.releaseDate !== "-"
                          ? new Date(album.releaseDate).getFullYear()
                          : t("artist.unreleased")}
                      </p>
                      <p className="mt-1 text-sm text-muted-foreground">
                        {album.plays.toLocaleString()} plays
                      </p>
                    </div>
                  </Link>
                </CardContent>
              </Card>
            ))
          )}
        </div>
      </TabsContent>
    </div>
  );
}
