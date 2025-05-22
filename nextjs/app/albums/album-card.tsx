import Image from "next/image"
import Link from "next/link"
import { TrustScoreBadge } from "@/components/trust-score-badge"
import { VerifiedBadge } from "@/components/verified-badge"

interface Album {
  id: string
  title: string
  artist: string
  artistId: string
  coverUrl: string
  releaseDate: string
  trackCount: number
  trustScore: number
  isVerified: boolean
  genre: string
}

interface AlbumCardProps {
  album: Album
}

export function AlbumCard({ album }: AlbumCardProps) {
  // Format release date to show only the year
  const releaseYear = new Date(album.releaseDate).getFullYear()

  return (
    <div className="group space-y-3">
      <Link href={`/albums/${album.id}`} className="block">
        <div className="relative aspect-square overflow-hidden rounded-md bg-muted">
          <Image
            src={album.coverUrl || "/placeholder.svg"}
            alt={album.title}
            fill
            className="object-cover transition-transform group-hover:scale-105"
          />
        </div>
      </Link>
      <div>
        <Link href={`/albums/${album.id}`} className="block">
          <h3 className="font-medium truncate group-hover:text-primary transition-colors">{album.title}</h3>
        </Link>
        <div className="flex items-center gap-1">
          <Link
            href={`/artist/${album.artistId}`}
            className="text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            {album.artist}
          </Link>
          {album.isVerified && <VerifiedBadge size="sm" />}
        </div>
        <div className="flex items-center justify-between mt-1">
          <div className="flex items-center gap-2">
            <span className="text-xs text-muted-foreground">{releaseYear}</span>
            <span className="text-xs text-muted-foreground">•</span>
            <span className="text-xs text-muted-foreground">{album.trackCount} tracks</span>
          </div>
          <TrustScoreBadge score={album.trustScore} size="sm" />
        </div>
      </div>
    </div>
  )
}
