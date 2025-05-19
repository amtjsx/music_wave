"use client";

import Image from "next/image";
import Link from "next/link";

import { Card, CardContent } from "@/components/ui/card";
import { getAlbumArtPlaceholder } from "@/utils/image-utils";
import { useTranslation } from "@/hooks/use-translation";

// Sample new releases data
const newReleases = [
  {
    id: 1,
    title: "Renaissance",
    artist: "Beyoncé",
    releaseDate: "July 29, 2022",
    coverArt: getAlbumArtPlaceholder(200, 200, "Renaissance", "ec4899"),
  },
  {
    id: 2,
    title: "Midnights",
    artist: "Taylor Swift",
    releaseDate: "October 21, 2022",
    coverArt: getAlbumArtPlaceholder(200, 200, "Midnights", "8b5cf6"),
  },
  {
    id: 3,
    title: "Un Verano Sin Ti",
    artist: "Bad Bunny",
    releaseDate: "May 6, 2022",
    coverArt: getAlbumArtPlaceholder(200, 200, "Un Verano Sin Ti", "f97316"),
  },
  {
    id: 4,
    title: "Harry's House",
    artist: "Harry Styles",
    releaseDate: "May 20, 2022",
    coverArt: getAlbumArtPlaceholder(200, 200, "Harry's House", "22c55e"),
  },
  {
    id: 5,
    title: "SOS",
    artist: "SZA",
    releaseDate: "December 9, 2022",
    coverArt: getAlbumArtPlaceholder(200, 200, "SOS", "3b82f6"),
  },
  {
    id: 6,
    title: "Honestly, Nevermind",
    artist: "Drake",
    releaseDate: "June 17, 2022",
    coverArt: getAlbumArtPlaceholder(200, 200, "Honestly, Nevermind", "f43f5e"),
  },
];

export function NewReleases() {
  const { t } = useTranslation("common");

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold tracking-tight">
          {t("section.new")}
        </h2>
        <Link
          href="#"
          className="text-sm font-medium text-primary hover:underline"
        >
          {t("section.viewall")}
        </Link>
      </div>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6">
        {newReleases.map((album) => (
          <Card key={album.id} className="overflow-hidden">
            <CardContent className="p-0">
              <Link href="#" className="group block">
                <div className="relative">
                  <Image
                    src={album.coverArt || "/placeholder.svg"}
                    alt={`${album.title} album cover`}
                    width={200}
                    height={200}
                    className="aspect-square w-full object-cover transition-transform duration-300 group-hover:scale-105"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
                </div>
                <div className="p-4">
                  <h3 className="font-semibold line-clamp-1">{album.title}</h3>
                  <p className="text-sm text-muted-foreground line-clamp-1">
                    {album.artist}
                  </p>
                </div>
              </Link>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
