"use client";

import {
    Pause,
    Play,
    SkipBack,
    SkipForward,
    Volume2,
    VolumeX,
} from "lucide-react";
import Image from "next/image";
import { useEffect } from "react";

import { Button } from "@/components/ui/button";
import { Slider } from "@/components/ui/slider";
import { useAudio } from "@/contexts/audio-context";
import { Track } from "@/hooks/use-audio-player";
import { useTranslation } from "@/hooks/use-translation";
import { getAlbumArtPlaceholder } from "@/utils/image-utils";

// Sample tracks data with audio files
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

export function MusicPlayer() {
  const { t } = useTranslation("player");
  const {
    tracks,
    setTracks,
    currentTrack,
    isPlaying,
    duration,
    currentTime,
    volume,
    isMuted,
    togglePlayPause,
    nextTrack,
    previousTrack,
    seek,
    setVolume,
    toggleMute,
  } = useAudio();

  // Load sample tracks on component mount
  useEffect(() => {
    setTracks(sampleTracks);
  }, [setTracks]);

  const formatTime = (seconds: number) => {
    if (isNaN(seconds)) return "0:00";
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, "0")}`;
  };

  if (!currentTrack) {
    return null;
  }

  return (
    <div className="sticky bottom-0 md:left-72 left-0 right-0 border-t bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-20 items-center justify-between">
        <div className="flex items-center space-x-4">
          <Image
            src={currentTrack.coverArt || "/placeholder.svg"}
            alt={`${currentTrack.title} album cover`}
            width={60}
            height={60}
            className="rounded-md"
          />
          <div>
            <h3 className="text-sm font-medium">{currentTrack.title}</h3>
            <p className="text-xs text-muted-foreground">
              {currentTrack.artist}
            </p>
          </div>
        </div>
        <div className="flex w-full max-w-md flex-col items-center space-y-2">
          <div className="flex items-center space-x-4">
            <Button
              variant="ghost"
              size="icon"
              onClick={previousTrack}
              aria-label={t("previous")}
            >
              <SkipBack className="h-5 w-5" />
            </Button>
            <Button
              onClick={togglePlayPause}
              variant="outline"
              size="icon"
              className="h-10 w-10 rounded-full"
              aria-label={isPlaying ? t("pause") : t("play")}
            >
              {isPlaying ? (
                <Pause className="h-5 w-5" />
              ) : (
                <Play className="h-5 w-5" />
              )}
            </Button>
            <Button
              variant="ghost"
              size="icon"
              onClick={nextTrack}
              aria-label={t("next")}
            >
              <SkipForward className="h-5 w-5" />
            </Button>
          </div>
          <div className="flex w-full items-center space-x-2">
            <span className="text-xs tabular-nums text-muted-foreground">
              {formatTime(currentTime)}
            </span>
            <Slider
              value={[currentTime]}
              max={duration || 100}
              step={1}
              onValueChange={(value) => seek(value[0])}
              className="w-full"
              aria-label="Playback progress"
            />
            <span className="text-xs tabular-nums text-muted-foreground">
              {formatTime(duration)}
            </span>
          </div>
        </div>
        <div className="flex items-center space-x-2">
          <Button
            variant="ghost"
            size="icon"
            onClick={toggleMute}
            aria-label={isMuted ? t("player.unmute") : t("player.mute")}
          >
            {isMuted ? (
              <VolumeX className="h-5 w-5" />
            ) : (
              <Volume2 className="h-5 w-5" />
            )}
          </Button>
          <Slider
            value={[isMuted ? 0 : volume * 100]}
            max={100}
            step={1}
            onValueChange={(value) => setVolume(value[0] / 100)}
            className="w-24"
            aria-label="Volume"
          />
        </div>
      </div>
    </div>
  );
}
