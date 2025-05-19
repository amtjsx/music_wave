"use client";

import Image from "next/image";
import { Play } from "lucide-react";

import { Button } from "@/components/ui/button";
import { getColoredPlaceholder } from "@/utils/image-utils";
import { useTranslation } from "@/hooks/use-translation";

export function HeroSection() {
  const { t } = useTranslation("hero");

  // Featured album with colorful cover art
  const featuredAlbum = {
    title: t("hero.featured.title", "Featured Album"),
    artist: t("hero.featured.artist", "Artist Name"),
    description: t("hero.featured.description", "Description"),
    coverArt: getColoredPlaceholder(600, 600, "4f46e5"),
  };

  return (
    <div className="relative overflow-hidden rounded-xl bg-muted/50">
      <div className="container relative z-10 grid gap-4 py-10 md:grid-cols-2 md:items-center md:gap-8 md:py-16">
        <div className="flex flex-col gap-4">
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl lg:text-5xl">
            {featuredAlbum.title}
          </h1>
          <p className="text-xl font-medium">{featuredAlbum.artist}</p>
          <p className="max-w-[600px] text-muted-foreground">
            {featuredAlbum.description}
          </p>
          <div className="flex gap-4">
            <Button size="lg" className="gap-2">
              <Play className="h-4 w-4" />
              {t("hero.play", "Play")}
            </Button>
            <Button size="lg" variant="outline">
              {t("hero.view", "View")}
            </Button>
          </div>
        </div>
        <div className="flex justify-center md:justify-end">
          <div className="relative aspect-square w-full max-w-[400px] overflow-hidden rounded-xl shadow-xl">
            <Image
              src={featuredAlbum.coverArt || "/placeholder.svg"}
              alt={`${featuredAlbum.title} by ${featuredAlbum.artist}`}
              width={400}
              height={400}
              className="h-full w-full object-cover"
              priority
            />
          </div>
        </div>
      </div>
      <div className="absolute inset-0 bg-gradient-to-r from-background/80 to-background/20" />
    </div>
  );
}
