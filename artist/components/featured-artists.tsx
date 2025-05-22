"use client"

import Image from "next/image"
import Link from "next/link"

import { Card, CardContent } from "@/components/ui/card"
import { getColoredPlaceholder } from "@/utils/image-utils"
import { useTranslation } from "@/hooks/use-translation"

// Sample featured artists data
const featuredArtists = [
  {
    id: 1,
    name: "Taylor Swift",
    image: getColoredPlaceholder(300, 300, "ec4899"),
    followers: "95.4M",
  },
  {
    id: 2,
    name: "The Weeknd",
    image: getColoredPlaceholder(300, 300, "8b5cf6"),
    followers: "82.1M",
  },
  {
    id: 3,
    name: "Drake",
    image: getColoredPlaceholder(300, 300, "3b82f6"),
    followers: "76.8M",
  },
  {
    id: 4,
    name: "Billie Eilish",
    image: getColoredPlaceholder(300, 300, "22c55e"),
    followers: "71.3M",
  },
]

export function FeaturedArtists() {
  const { t } = useTranslation("sidebar")

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold tracking-tight">{t("section.featured")}</h2>
        <Link href="#" className="text-sm font-medium text-primary hover:underline">
          {t("section.viewall")}
        </Link>
      </div>
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4">
        {featuredArtists.map((artist) => (
          <Card key={artist.id} className="overflow-hidden">
            <CardContent className="p-0">
              <Link href="#" className="group block">
                <div className="relative">
                  <Image
                    src={artist.image || "/placeholder.svg"}
                    alt={artist.name}
                    width={300}
                    height={300}
                    className="aspect-square w-full object-cover transition-transform duration-300 group-hover:scale-105"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 transition-opacity duration-300 group-hover:opacity-100" />
                </div>
                <div className="p-4">
                  <h3 className="font-semibold">{artist.name}</h3>
                  <p className="text-sm text-muted-foreground">{artist.followers} followers</p>
                </div>
              </Link>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  )
}

