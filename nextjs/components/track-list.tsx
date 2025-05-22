"use client";

import { Pause, Play } from "lucide-react";
import Image from "next/image";
import Link from "next/link";

import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useAudio } from "@/contexts/audio-context";
import type { Track } from "@/hooks/use-audio-player";
import { useTranslation } from "@/hooks/use-translation";
import { getAlbumArtPlaceholder } from "@/utils/image-utils";

export function TrackList() {
  const { t } = useTranslation("player");
  const { tracks, currentTrack, isPlaying, playTrack, togglePlayPause } =
    useAudio();

  const formatTime = (seconds: number) => {
    if (isNaN(seconds)) return "0:00";
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  };

  // Estimate duration for display purposes
  const getDuration = (index: number) => {
    const durations = ["3:45", "4:20", "3:12", "2:58", "3:33"];
    return durations[index % durations.length];
  };

  // Sample tracks with colored album art
  const sampleTracks: Track[] = [
    {
      id: "1",
      title: "Sample Track 1",
      artist: "Demo Artist",
      album: "Sample Album",
      coverArt: getAlbumArtPlaceholder(60, 60, "Sample Track 1", "ec4899"),
      audioSrc: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    },
    {
      id: "2",
      title: "Sample Track 2",
      artist: "Demo Artist",
      album: "Sample Album",
      coverArt: getAlbumArtPlaceholder(60, 60, "Sample Track 2", "8b5cf6"),
      audioSrc: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    },
    {
      id: "3",
      title: "Sample Track 3",
      artist: "Demo Artist",
      album: "Sample Album",
      coverArt: getAlbumArtPlaceholder(60, 60, "Sample Track 3", "3b82f6"),
      audioSrc: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    },
  ];

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-bold tracking-tight">
        {t("section.available")}
      </h2>
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-[60px]">#</TableHead>
              <TableHead>Title</TableHead>
              <TableHead className="hidden md:table-cell">Artist</TableHead>
              <TableHead className="hidden sm:table-cell">Duration</TableHead>
              <TableHead className="w-[70px]"></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {sampleTracks.map((track, index) => {
              const isCurrentTrack = currentTrack?.id === track.id;
              const isCurrentlyPlaying = isCurrentTrack && isPlaying;

              return (
                <TableRow
                  key={track.id}
                  className={isCurrentTrack ? "bg-muted/50" : ""}
                >
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
                        <Link
                          href={`/track/${track.id}`}
                          className="font-medium hover:underline cursor-pointer"
                        >
                          {track.title}
                        </Link>
                        <div className="text-sm text-muted-foreground">
                          {track.album}
                        </div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="hidden md:table-cell">
                    {track.artist}
                  </TableCell>
                  <TableCell className="hidden sm:table-cell">
                    {getDuration(index)}
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => {
                        if (isCurrentTrack) {
                          togglePlayPause();
                        } else {
                          playTrack(index);
                        }
                      }}
                    >
                      {isCurrentlyPlaying ? (
                        <Pause className="h-4 w-4" />
                      ) : (
                        <Play className="h-4 w-4" />
                      )}
                      <span className="sr-only">
                        {isCurrentlyPlaying
                          ? t("player.pause")
                          : t("player.play")}
                      </span>
                    </Button>
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
