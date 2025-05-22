import Image from "next/image"
import Link from "next/link"
import { Play } from "lucide-react"

import { Button } from "@/components/ui/button"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { getAlbumArtPlaceholder } from "@/utils/image-utils"

// Sample trending tracks data
const trendingTracks = [
  {
    id: 1,
    title: "Blinding Lights",
    artist: "The Weeknd",
    album: "After Hours",
    duration: "3:20",
    plays: "2.8B",
    coverArt: getAlbumArtPlaceholder(40, 40, "Blinding Lights", "8b5cf6"),
  },
  {
    id: 2,
    title: "Shape of You",
    artist: "Ed Sheeran",
    album: "÷ (Divide)",
    duration: "3:53",
    plays: "3.2B",
    coverArt: getAlbumArtPlaceholder(40, 40, "Shape of You", "ec4899"),
  },
  {
    id: 3,
    title: "Dance Monkey",
    artist: "Tones and I",
    album: "The Kids Are Coming",
    duration: "3:29",
    plays: "2.5B",
    coverArt: getAlbumArtPlaceholder(40, 40, "Dance Monkey", "f97316"),
  },
  {
    id: 4,
    title: "Someone You Loved",
    artist: "Lewis Capaldi",
    album: "Divinely Uninspired to a Hellish Extent",
    duration: "3:02",
    plays: "2.3B",
    coverArt: getAlbumArtPlaceholder(40, 40, "Someone You Loved", "22c55e"),
  },
  {
    id: 5,
    title: "Watermelon Sugar",
    artist: "Harry Styles",
    album: "Fine Line",
    duration: "2:54",
    plays: "2.1B",
    coverArt: getAlbumArtPlaceholder(40, 40, "Watermelon Sugar", "3b82f6"),
  },
]

export function TrendingTracks() {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold tracking-tight">Trending Tracks</h2>
        <Link href="#" className="text-sm font-medium text-primary hover:underline">
          View all
        </Link>
      </div>
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[60px]">#</TableHead>
              <TableHead>Title</TableHead>
              <TableHead className="hidden md:table-cell">Album</TableHead>
              <TableHead className="hidden sm:table-cell">Duration</TableHead>
              <TableHead className="hidden lg:table-cell">Plays</TableHead>
              <TableHead className="w-[70px]"></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {trendingTracks.map((track, index) => (
              <TableRow key={track.id}>
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
                      <div className="text-sm text-muted-foreground">{track.artist}</div>
                    </div>
                  </div>
                </TableCell>
                <TableCell className="hidden md:table-cell">{track.album}</TableCell>
                <TableCell className="hidden sm:table-cell">{track.duration}</TableCell>
                <TableCell className="hidden lg:table-cell">{track.plays}</TableCell>
                <TableCell>
                  <Button variant="ghost" size="icon">
                    <Play className="h-4 w-4" />
                    <span className="sr-only">Play</span>
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </div>
  )
}

