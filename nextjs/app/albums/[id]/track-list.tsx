import { Play, MoreHorizontal, Plus, Clock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ShareDialog } from "./share-dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface Track {
  id: string;
  number: number;
  title: string;
  duration: string;
  plays: number;
  isExplicit: boolean;
}

interface TrackListProps {
  tracks: Track[];
}

export function TrackList({ tracks }: TrackListProps) {
  return (
    <div className="space-y-1">
      <div className="grid grid-cols-[auto_1fr_auto_auto] items-center gap-4 px-4 py-2 text-sm text-muted-foreground">
        <span className="w-8 text-center">#</span>
        <span>Title</span>
        <span className="flex items-center gap-1">
          <Clock className="h-4 w-4" />
          <span className="sr-only">Duration</span>
        </span>
        <span></span>
      </div>
      {tracks.map((track) => (
        <div
          key={track.id}
          className="group grid grid-cols-[auto_1fr_auto_auto] items-center gap-4 rounded-md px-4 py-2 hover:bg-muted/50"
        >
          <div className="w-8 text-center text-sm font-medium text-muted-foreground group-hover:hidden">
            {track.number}
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="hidden h-8 w-8 group-hover:flex"
          >
            <Play className="h-4 w-4" />
            <span className="sr-only">Play</span>
          </Button>
          <div className="flex items-center gap-2 truncate">
            <div className="truncate">
              <div className="truncate font-medium">{track.title}</div>
              <div className="flex items-center gap-1 text-sm text-muted-foreground">
                {track.isExplicit && (
                  <Badge variant="outline" className="text-xs px-1 py-0">
                    E
                  </Badge>
                )}
                <span>{formatPlays(track.plays)} plays</span>
              </div>
            </div>
          </div>
          <div className="text-sm text-muted-foreground">{track.duration}</div>
          <div className="flex items-center gap-1">
            <ShareDialog
              item={{
                id: track.id,
                title: track.title,
                artist: "Artist Name", // This would come from the album or track data
                coverUrl: "/album-cover-1.png", // This would come from the album
                type: "track",
              }}
              className="hidden group-hover:flex"
            />
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-8 w-8 hidden group-hover:flex"
                >
                  <MoreHorizontal className="h-4 w-4" />
                  <span className="sr-only">More options</span>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                <DropdownMenuLabel>Track Options</DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem>Add to Queue</DropdownMenuItem>
                <DropdownMenuItem>
                  <Plus className="mr-2 h-4 w-4" />
                  Add to Playlist
                </DropdownMenuItem>
                <DropdownMenuItem>Share Track</DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem>View Lyrics</DropdownMenuItem>
                <DropdownMenuItem>View Credits</DropdownMenuItem>
                <DropdownMenuItem>Report Track</DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      ))}
    </div>
  );
}

function formatPlays(plays: number): string {
  if (plays >= 1000000) {
    return `${(plays / 1000000).toFixed(1)}M`;
  }
  if (plays >= 1000) {
    return `${(plays / 1000).toFixed(1)}K`;
  }
  return plays.toString();
}
