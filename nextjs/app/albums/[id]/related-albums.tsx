import Image from "next/image";
import Link from "next/link";

// Mock data for related albums
const relatedAlbums = [
  {
    id: "5",
    title: "Acoustic Journey",
    artist: "Harmony Woods",
    artistId: "harmony-woods",
    coverUrl: "/album-cover-5.png",
  },
  {
    id: "6",
    title: "Jazz Nights",
    artist: "Smooth Quartet",
    artistId: "smooth-quartet",
    coverUrl: "/album-cover-6.png",
  },
  {
    id: "7",
    title: "Classical Reimagined",
    artist: "Modern Orchestra",
    artistId: "modern-orchestra",
    coverUrl: "/album-cover-7.png",
  },
  {
    id: "8",
    title: "Summer Vibes",
    artist: "Beach Tones",
    artistId: "beach-tones",
    coverUrl: "/album-cover-8.png",
  },
];

export function RelatedAlbums() {
  return (
    <div>
      <h3 className="text-xl font-semibold mb-4">You might also like</h3>
      <div className="grid grid-cols-2 gap-4">
        {relatedAlbums.map((album) => (
          <Link
            key={album.id}
            href={`/albums/${album.id}`}
            className="group space-y-2"
          >
            <div className="relative aspect-square overflow-hidden rounded-md">
              <Image
                src={album.coverUrl || "/placeholder.svg"}
                alt={album.title}
                fill
                className="object-cover transition-transform group-hover:scale-105"
              />
            </div>
            <div>
              <h4 className="font-medium truncate group-hover:text-primary transition-colors">
                {album.title}
              </h4>
              <p className="text-sm text-muted-foreground">{album.artist}</p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
