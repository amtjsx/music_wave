"use client";

import type React from "react";

import {
  Heart,
  Loader2,
  MessageCircle,
  Music,
  Pause,
  Play,
  RefreshCw,
  Share2,
  Volume2,
  VolumeX,
} from "lucide-react";
import Image from "next/image";
import { useEffect, useRef, useState } from "react";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { CommentSection } from "./comment-section";

// Update the ShortVideoPlayerProps interface to include multiple video sources
interface ShortVideoPlayerProps {
  short: {
    id: string;
    videoUrl: string;
    videoSources?: {
      quality: string;
      label: string;
      url: string;
    }[];
    thumbnailUrl: string;
    caption: string;
    user: {
      id: string;
      name: string;
      username: string;
      avatarUrl: string;
      isVerified: boolean;
      trustScore: number;
      trustLevel: string;
    };
    track: {
      id: string;
      title: string;
      artist: string;
      duration: number;
    };
    likes: number;
    comments: number;
    shares: number;
  };
  isActive: boolean;
  onSwipe: (direction: "up" | "down") => void;
  onChangeVideo?: () => void;
}

export function ShortVideoPlayer({
  short,
  isActive,
  onSwipe,
  onChangeVideo,
}: ShortVideoPlayerProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const progressBarRef = useRef<HTMLDivElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isMuted, setIsMuted] = useState(true);
  const [isLiked, setIsLiked] = useState(false);
  const [touchStart, setTouchStart] = useState<number | null>(null);
  const [touchEnd, setTouchEnd] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [hasError, setHasError] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [isHoveringProgressBar, setIsHoveringProgressBar] = useState(false);
  // Add state for quality selection and quality menu
  const [currentQuality, setCurrentQuality] = useState<string>("auto");
  const [isQualityMenuOpen, setIsQualityMenuOpen] = useState(false);
  // Add state for comment section
  const [isCommentSectionOpen, setIsCommentSectionOpen] = useState(false);

  // Format numbers for display
  const formatNumber = (num: number): string => {
    if (num >= 1000000) {
      return (num / 1000000).toFixed(1) + "M";
    } else if (num >= 1000) {
      return (num / 1000).toFixed(1) + "K";
    } else {
      return num.toString();
    }
  };

  // Format time in seconds to MM:SS format
  const formatTime = (timeInSeconds: number): string => {
    if (isNaN(timeInSeconds)) return "0:00";

    const minutes = Math.floor(timeInSeconds / 60);
    const seconds = Math.floor(timeInSeconds % 60);

    return `${minutes}:${seconds.toString().padStart(2, "0")}`;
  };

  // Add a function to handle quality change
  const handleQualityChange = (quality: string) => {
    if (videoRef.current && quality !== currentQuality) {
      // Store current playback state and position
      const currentTime = videoRef.current.currentTime;
      const wasPlaying = !videoRef.current.paused;

      // Find the selected quality source
      const selectedSource = short.videoSources?.find(
        (source) => source.quality === quality
      );

      if (selectedSource) {
        // Set loading state
        setIsLoading(true);

        // Update video source
        videoRef.current.src = selectedSource.url;
        videoRef.current.load();

        // Add event listener to restore playback state after source change
        const handleSourceLoaded = () => {
          // Restore playback position
          videoRef.current!.currentTime = currentTime;

          // Restore play state if it was playing
          if (wasPlaying) {
            videoRef
              .current!.play()
              .then(() => {
                setIsPlaying(true);
                setIsLoading(false);
              })
              .catch((error) => {
                console.error(
                  "Error playing video after quality change:",
                  error
                );
                setIsPlaying(false);
                setIsLoading(false);
              });
          } else {
            setIsLoading(false);
          }

          // Remove the event listener
          videoRef.current!.removeEventListener(
            "loadeddata",
            handleSourceLoaded
          );
        };

        videoRef.current.addEventListener("loadeddata", handleSourceLoaded);

        // Update current quality state
        setCurrentQuality(quality);
      }

      // Close the quality menu
      setIsQualityMenuOpen(false);
    }
  };

  // Toggle comment section
  const toggleCommentSection = () => {
    setIsCommentSectionOpen(!isCommentSectionOpen);

    // Pause video when opening comments
    if (!isCommentSectionOpen && videoRef.current && isPlaying) {
      videoRef.current.pause();
      setIsPlaying(false);
    }
  };

  // Play/pause video when active state changes
  useEffect(() => {
    if (videoRef.current) {
      if (isActive) {
        // Reset video when becoming active
        videoRef.current.currentTime = 0;
        setIsLoading(true);

        // Set the video source based on current quality
        const initialSource =
          short.videoSources?.find(
            (source) => source.quality === currentQuality
          ) || short.videoSources?.[0];

        if (videoRef.current.src !== initialSource?.url) {
          videoRef.current.src = initialSource?.url || "";
          videoRef.current.load();
        }

        const playPromise = videoRef.current.play();

        if (playPromise !== undefined) {
          playPromise
            .then(() => {
              setIsPlaying(true);
              setIsLoading(false);
            })
            .catch((error) => {
              console.error("Error playing video:", error);
              setIsPlaying(false);
              setHasError(true);
              setIsLoading(false);
            });
        }
      } else {
        // Pause when becoming inactive
        videoRef.current.pause();
        setIsPlaying(false);
      }
    }

    // Clean up function
    return () => {
      if (videoRef.current) {
        videoRef.current.pause();
      }
    };
  }, [isActive, short.videoSources, currentQuality]);

  // Handle video play/pause
  const togglePlay = () => {
    if (videoRef.current) {
      if (isPlaying) {
        videoRef.current.pause();
        setIsPlaying(false);
      } else {
        videoRef.current.play();
        setIsPlaying(true);
      }
    }
  };

  // Handle video mute/unmute
  const toggleMute = () => {
    if (videoRef.current) {
      videoRef.current.muted = !isMuted;
      setIsMuted(!isMuted);
    }
  };

  // Handle like toggle
  const toggleLike = () => {
    setIsLiked(!isLiked);
  };

  // Handle touch events for swipe
  const handleTouchStart = (e: React.TouchEvent) => {
    setTouchStart(e.targetTouches[0].clientY);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    setTouchEnd(e.targetTouches[0].clientY);
  };

  const handleTouchEnd = () => {
    if (!touchStart || !touchEnd) return;

    const distance = touchStart - touchEnd;
    const isSwipeUp = distance > 50;
    const isSwipeDown = distance < -50;

    if (isSwipeUp) {
      onSwipe("up");
    } else if (isSwipeDown) {
      onSwipe("down");
    }

    setTouchStart(null);
    setTouchEnd(null);
  };

  // Handle video loading events
  const handleVideoLoaded = () => {
    setIsLoading(false);
    setHasError(false);
  };

  const handleVideoError = () => {
    setIsLoading(false);
    setHasError(true);
  };

  const handleTimeUpdate = () => {
    if (videoRef.current) {
      setCurrentTime(videoRef.current.currentTime);
    }
  };

  const handleLoadedMetadata = () => {
    if (videoRef.current) {
      setDuration(videoRef.current.duration);
    }
  };

  // Handle progress bar click/tap to seek
  const handleProgressBarClick = (
    e: React.MouseEvent<HTMLDivElement> | React.TouchEvent<HTMLDivElement>
  ) => {
    if (!progressBarRef.current || !videoRef.current || duration === 0) return;

    // Get the bounding rectangle of the progress bar
    const rect = progressBarRef.current.getBoundingClientRect();

    // Calculate click position
    let clickX: number;

    if ("clientX" in e) {
      // Mouse event
      clickX = e.clientX - rect.left;
    } else {
      // Touch event
      clickX = e.touches[0].clientX - rect.left;
    }

    // Calculate the percentage of the bar that was clicked
    const percentage = Math.max(0, Math.min(1, clickX / rect.width));

    // Calculate the new time based on the percentage
    const newTime = percentage * duration;

    // Set the video's current time
    videoRef.current.currentTime = newTime;
    setCurrentTime(newTime);
  };

  return (
    <div
      className="relative h-full w-full bg-black"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Video Progress Bar */}
      <div
        ref={progressBarRef}
        className="absolute top-0 left-0 right-0 z-10 h-2 bg-gray-800/50 cursor-pointer"
        onClick={handleProgressBarClick}
        onTouchStart={handleProgressBarClick}
        onMouseEnter={() => setIsHoveringProgressBar(true)}
        onMouseLeave={() => setIsHoveringProgressBar(false)}
      >
        <div
          className="h-full bg-primary transition-all duration-100 ease-linear"
          style={{
            width: `${duration > 0 ? (currentTime / duration) * 100 : 0}%`,
          }}
        />
        {isHoveringProgressBar && (
          <div
            className="absolute top-0 h-full w-3 h-3 bg-white rounded-full -mt-0.5 transform -translate-x-1/2"
            style={{
              left: `${duration > 0 ? (currentTime / duration) * 100 : 0}%`,
            }}
          />
        )}
      </div>
      <div className="absolute top-4 right-4 z-10 text-xs text-white bg-black/40 px-2 py-1 rounded-md">
        {formatTime(currentTime)} / {formatTime(duration)}
      </div>
      {/* Video or Thumbnail */}
      {hasError ? (
        <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/90 text-white">
          <div className="mb-4 rounded-full bg-red-500/20 p-4">
            <RefreshCw className="h-8 w-8 text-red-500" />
          </div>
          <p className="mb-2 text-center text-lg font-medium">
            Video unavailable
          </p>
          <p className="mb-4 text-center text-sm text-gray-400">
            This video could not be played
          </p>
          {onChangeVideo && (
            <Button
              variant="outline"
              onClick={onChangeVideo}
              className="border-white/20 text-white"
            >
              Change video
            </Button>
          )}
        </div>
      ) : (
        <>
          {/* Show thumbnail while video is loading */}
          {isLoading && (
            <Image
              src={short.thumbnailUrl || "/placeholder.svg"}
              alt={short.caption}
              fill
              className="object-cover"
              priority
            />
          )}

          <video
            ref={videoRef}
            src={short.videoUrl}
            className="h-full w-full object-cover"
            loop
            playsInline
            muted={isMuted}
            onLoadedData={handleVideoLoaded}
            onLoadedMetadata={handleLoadedMetadata}
            onTimeUpdate={handleTimeUpdate}
            onError={handleVideoError}
          />

          {isLoading && (
            <div className="absolute inset-0 flex items-center justify-center bg-black/50">
              <div className="rounded-full bg-black/50 p-4">
                <Loader2 className="h-8 w-8 animate-spin text-white" />
              </div>
            </div>
          )}
        </>
      )}

      {/* Video Controls */}
      <div className="absolute bottom-0 left-0 right-0 p-4">
        <div className="flex items-center justify-between">
          <Button
            variant="ghost"
            size="icon"
            className="h-10 w-10 rounded-full bg-black/50 text-white hover:bg-black/70"
            onClick={togglePlay}
          >
            {isPlaying ? (
              <Pause className="h-5 w-5" />
            ) : (
              <Play className="h-5 w-5" />
            )}
          </Button>

          <div className="flex items-center gap-2">
            <div className="relative">
              <Button
                variant="ghost"
                size="sm"
                className="h-8 rounded-full bg-black/50 text-white hover:bg-black/70 text-xs px-2"
                onClick={() => setIsQualityMenuOpen(!isQualityMenuOpen)}
              >
                {currentQuality.toUpperCase()}
              </Button>

              {isQualityMenuOpen && (
                <div className="absolute bottom-full mb-2 right-0 bg-black/90 rounded-md overflow-hidden shadow-lg z-20">
                  <div className="p-1">
                    {short.videoSources?.map((source) => (
                      <button
                        key={source.quality}
                        className={`w-full text-left px-3 py-2 text-sm rounded-sm ${
                          currentQuality === source.quality
                            ? "bg-primary text-primary-foreground"
                            : "text-white hover:bg-gray-800"
                        }`}
                        onClick={() => handleQualityChange(source.quality)}
                      >
                        {source.label}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>

            <Button
              variant="ghost"
              size="icon"
              className="h-10 w-10 rounded-full bg-black/50 text-white hover:bg-black/70"
              onClick={toggleMute}
            >
              {isMuted ? (
                <VolumeX className="h-5 w-5" />
              ) : (
                <Volume2 className="h-5 w-5" />
              )}
            </Button>
          </div>
        </div>
      </div>

      {/* User Info and Caption */}
      <div className="absolute bottom-16 left-0 right-0 p-4 text-white">
        <div className="mb-2 flex items-center gap-2">
          <Avatar className="h-10 w-10 border-2 border-white">
            <AvatarImage
              src={short.user.avatarUrl || "/placeholder.svg"}
              alt={short.user.name}
            />
            <AvatarFallback>{short.user.name.charAt(0)}</AvatarFallback>
          </Avatar>
          <div>
            <div className="flex items-center gap-1">
              <span className="font-semibold">{short.user.name}</span>
              {short.user.isVerified && (
                <Badge className="h-4 bg-primary px-1 text-[10px]">
                  Verified
                </Badge>
              )}
            </div>
            <div className="text-sm text-gray-300">@{short.user.username}</div>
          </div>
          <Button
            variant="outline"
            size="sm"
            className="ml-auto h-8 border-white/20 text-white"
          >
            Follow
          </Button>
        </div>

        <p className="mb-3 text-sm">{short.caption}</p>

        <div className="flex items-center gap-2 rounded-full bg-black/30 px-3 py-1.5 text-sm backdrop-blur-sm">
          <Music className="h-4 w-4" />
          <span className="font-medium">{short.track.title}</span>
          <span className="text-gray-300">• {short.track.artist}</span>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="absolute bottom-24 right-4 flex flex-col items-center gap-6">
        <div className="flex flex-col items-center">
          <Button
            variant="ghost"
            size="icon"
            className="h-12 w-12 rounded-full bg-black/30 text-white hover:bg-black/50"
            onClick={toggleLike}
          >
            <Heart
              className={cn("h-6 w-6", isLiked && "fill-red-500 text-red-500")}
            />
          </Button>
          <span className="mt-1 text-xs font-medium text-white">
            {formatNumber(short.likes)}
          </span>
        </div>

        <div className="flex flex-col items-center">
          <Button
            variant="ghost"
            size="icon"
            className={cn(
              "h-12 w-12 rounded-full bg-black/30 text-white hover:bg-black/50",
              isCommentSectionOpen &&
                "bg-primary text-primary-foreground hover:bg-primary/90"
            )}
            onClick={toggleCommentSection}
          >
            <MessageCircle className="h-6 w-6" />
          </Button>
          <span className="mt-1 text-xs font-medium text-white">
            {formatNumber(short.comments)}
          </span>
        </div>

        <div className="flex flex-col items-center">
          <Button
            variant="ghost"
            size="icon"
            className="h-12 w-12 rounded-full bg-black/30 text-white hover:bg-black/50"
          >
            <Share2 className="h-6 w-6" />
          </Button>
          <span className="mt-1 text-xs font-medium text-white">
            {formatNumber(short.shares)}
          </span>
        </div>

        {onChangeVideo && (
          <div className="flex flex-col items-center">
            <Button
              variant="ghost"
              size="icon"
              className="h-12 w-12 rounded-full bg-black/30 text-white hover:bg-black/50"
              onClick={onChangeVideo}
            >
              <RefreshCw className="h-6 w-6" />
            </Button>
            <span className="mt-1 text-xs font-medium text-white">Change</span>
          </div>
        )}
      </div>

      {/* Comment Section */}
      <CommentSection
        isOpen={isCommentSectionOpen}
        onClose={() => setIsCommentSectionOpen(false)}
        shortId={short.id}
      />

      {/* Swipe indicators */}
      <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 transform space-y-2 opacity-0 transition-opacity duration-300 group-hover:opacity-100">
        <div className="flex flex-col items-center text-white opacity-50">
          <span className="text-xs">Swipe up for next</span>
          <span className="text-xs">Swipe down for previous</span>
        </div>
      </div>
    </div>
  );
}

export default ShortVideoPlayer;
