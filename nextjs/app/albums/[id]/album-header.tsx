import Image from "next/image";
import Link from "next/link";
import { Play, Heart, MoreHorizontal } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { TrustScoreBadge } from "@/components/trust-score-badge";
import { VerifiedBadge } from "@/components/verified-badge";
import { ShareDialog } from "./share-dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface Album {
  id: string;
  title: string;
  artist: string;
  artistId: string;
  coverUrl: string;
  releaseDate: string;
  releaseYear: string;
  label: string;
  genre: string;
  trackCount: number;
  duration: string;
  trustScore: number;
  isVerified: boolean;
  description: string;
}

interface AlbumHeaderProps {
  album: Album;
}

export function AlbumHeader({ album }: AlbumHeaderProps) {
  return (
    <div className="flex flex-col md:flex-row gap-6">
      <div className="relative aspect-square w-full max-w-[250px] mx-auto md:mx-0 overflow-hidden rounded-md bg-muted">
        <Image
          src={album.coverUrl || "/placeholder.svg"}
          alt={album.title}
          fill
          className="object-cover"
          priority
        />
      </div>
      <div className="flex-1 space-y-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">{album.title}</h1>
          <div className="flex items-center gap-1 mt-1">
            <Link
              href={`/artist/${album.artistId}`}
              className="text-lg hover:text-primary transition-colors"
            >
              {album.artist}
            </Link>
            {album.isVerified && <VerifiedBadge />}
            <TrustScoreBadge score={album.trustScore} />
          </div>
        </div>
        <div className="flex flex-wrap gap-2">
          <Badge variant="outline">{album.genre}</Badge>
          <Badge variant="outline">{album.releaseYear}</Badge>
          <Badge variant="outline">{album.trackCount} tracks</Badge>
          <Badge variant="outline">{album.duration}</Badge>
        </div>
        <div className="flex flex-wrap gap-2 pt-4">
          <Button className="rounded-full gap-2">
            <Play className="h-4 w-4" />
            Play
          </Button>
          <Button variant="outline" className="rounded-full gap-2">
            <Heart className="h-4 w-4" />
            Save
          </Button>
          <ShareDialog
            item={{
              id: album.id,
              title: album.title,
              artist: album.artist,
              coverUrl: album.coverUrl,
              type: "album",
            }}
          />
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="icon" className="rounded-full">
                <MoreHorizontal className="h-4 w-4" />
                <span className="sr-only">More options</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <DropdownMenuLabel>Album Options</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <DropdownMenuItem>Add to Queue</DropdownMenuItem>
              <DropdownMenuItem>Add to Playlist</DropdownMenuItem>
              <DropdownMenuItem>Share Album</DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem>View Artist</DropdownMenuItem>
              <DropdownMenuItem>Report Album</DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </div>
  );
}
