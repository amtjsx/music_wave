import Image from "next/image";
import Link from "next/link";
import { Play } from "lucide-react";
import { Button } from "@/components/ui/button";

// This would be a generic embed page that works for albums, tracks, playlists, etc.
export default function EmbedPage({
  params,
}: {
  params: { type: string; id: string };
}) {
  const { type, id } = params;

  // In a real implementation, this would fetch the item data from an API
  // For now, we'll use mock data
  const item = {
    id,
    title: type === "album" ? "Midnight Waves" : "Digital Dawn",
    artist: "Luna Echo",
    coverUrl: "/album-cover-1.png",
    type,
  };

  return (
    <div className="flex flex-col h-full w-full overflow-hidden rounded-lg border bg-background p-4">
      <div className="flex items-center gap-4">
        <div className="relative h-20 w-20 flex-shrink-0 overflow-hidden rounded-md">
          <Image
            src={item.coverUrl || "/placeholder.svg"}
            alt={item.title}
            fill
            className="object-cover"
          />
        </div>
        <div className="flex-1 min-w-0">
          <h1 className="text-lg font-semibold truncate">{item.title}</h1>
          <p className="text-sm text-muted-foreground truncate">
            {item.artist}
          </p>
          <div className="flex items-center gap-2 mt-2">
            <Button size="sm" className="rounded-full gap-1">
              <Play className="h-3 w-3" />
              Play
            </Button>
            <Link
              href={`https://musicwave.com/${type}/${id}`}
              target="_blank"
              className="text-xs text-primary hover:underline"
            >
              Listen on MusicWave
            </Link>
          </div>
        </div>
      </div>

      {type === "album" && (
        <div className="mt-4 space-y-1 overflow-y-auto">
          {/* This would show a few tracks from the album */}
          {Array.from({ length: 3 }).map((_, i) => (
            <div
              key={i}
              className="flex items-center justify-between py-1 px-2 rounded hover:bg-muted/50"
            >
              <div className="flex items-center gap-2">
                <span className="text-sm text-muted-foreground w-4">
                  {i + 1}
                </span>
                <span className="text-sm font-medium">
                  {i === 0
                    ? "Digital Dawn"
                    : i === 1
                    ? "Neon Pulse"
                    : "Midnight Synthesis"}
                </span>
              </div>
              <span className="text-xs text-muted-foreground">
                {i === 0 ? "3:42" : i === 1 ? "4:15" : "5:08"}
              </span>
            </div>
          ))}
          <div className="py-1 px-2 text-xs text-primary hover:underline">
            <Link href={`https://musicwave.com/${type}/${id}`} target="_blank">
              View all tracks
            </Link>
          </div>
        </div>
      )}

      <div className="mt-auto pt-4 flex items-center justify-between text-xs text-muted-foreground">
        <span>Powered by MusicWave</span>
        <Link
          href="https://musicwave.com"
          target="_blank"
          className="hover:text-primary hover:underline"
        >
          musicwave.com
        </Link>
      </div>
    </div>
  );
}
