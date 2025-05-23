"use client";

import React from "react";

import { Loader2, MoreHorizontal, RefreshCw, Shield, X } from "lucide-react";
import { useEffect, useRef, useState } from "react";

import { AppSidebar } from "@/components/app-sidebar";
import { Button } from "@/components/ui/button";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useRouter } from "next/navigation";
import { ShortVideoPlayer } from "./short-video-player";

interface Short {
  id: string;
  videoUrl: string;
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
}

export default function ShortsPage() {
  const [shorts, setShorts] = useState<Short[]>([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);
  const [hasMore, setHasMore] = useState(true);
  const [isSwapDialogOpen, setIsSwapDialogOpen] = useState(false);
  const [selectedShortId, setSelectedShortId] = useState<string | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  // Animation states
  const [isAnimating, setIsAnimating] = useState(false);
  const [nextIndex, setNextIndex] = useState<number | null>(null);
  const [animationDirection, setAnimationDirection] = useState<
    "up" | "down" | null
  >(null);
  const [animationPhase, setAnimationPhase] = useState<"exit" | "enter" | null>(
    null
  );

  const router = useRouter();

  // Fetch initial shorts
  useEffect(() => {
    fetchShorts();
  }, []);

  // Function to fetch shorts from API
  const fetchShorts = async () => {
    try {
      setLoading(true);
      // In a real app, this would be a fetch call to your API
      // const response = await fetch('/api/shorts')
      // const data = await response.json()

      // Mock data for demonstration
      const mockShorts: Short[] = [
        {
          id: "1",
          videoUrl: "/videos/dj-video.mp4", // This would be a real video URL in production
          thumbnailUrl: "/placeholder-j9dep.png",
          caption:
            "Dropping this new beat! What do you think? #newmusic #producer #beats",
          user: {
            id: "u1",
            name: "DJ Wavelength",
            username: "djwavelength",
            avatarUrl: "/placeholder.svg?height=40&width=40&text=DJ",
            isVerified: true,
            trustScore: 92,
            trustLevel: "Exceptional",
          },
          track: {
            id: "t1",
            title: "Midnight Groove",
            artist: "DJ Wavelength",
            duration: 30,
          },
          likes: 4523,
          comments: 342,
          shares: 89,
        },
        {
          id: "2",
          videoUrl: "/videos/singer-video.mp4",
          thumbnailUrl: "/female-singer-stage.png",
          caption:
            "Behind the scenes of my new single! #behindthescenes #newrelease",
          user: {
            id: "u2",
            name: "Melody Carter",
            username: "melodycarter",
            avatarUrl: "/placeholder.svg?height=40&width=40&text=MC",
            isVerified: true,
            trustScore: 87,
            trustLevel: "Core",
          },
          track: {
            id: "t2",
            title: "Ocean Eyes",
            artist: "Melody Carter",
            duration: 30,
          },
          likes: 8912,
          comments: 723,
          shares: 231,
        },
        {
          id: "3",
          videoUrl: "/videos/band-video.mp4",
          thumbnailUrl: "/live-rock-band.png",
          caption:
            "Jamming with the band! New album coming soon #livemusic #band",
          user: {
            id: "u3",
            name: "The Wave Makers",
            username: "wavemakers",
            avatarUrl: "/placeholder.svg?height=40&width=40&text=WM",
            isVerified: false,
            trustScore: 76,
            trustLevel: "Trusted",
          },
          track: {
            id: "t3",
            title: "Sunset Ride",
            artist: "The Wave Makers",
            duration: 30,
          },
          likes: 2341,
          comments: 187,
          shares: 45,
        },
        {
          id: "4",
          videoUrl: "/videos/producer-video.mp4",
          thumbnailUrl: "/music-producer-studio.png",
          caption:
            "Creating this beat from scratch! Watch the process #beatmaking #production",
          user: {
            id: "u4",
            name: "BeatMaster Pro",
            username: "beatmasterpro",
            avatarUrl: "/placeholder.svg?height=40&width=40&text=BP",
            isVerified: false,
            trustScore: 54,
            trustLevel: "Basic",
          },
          track: {
            id: "t4",
            title: "Urban Rhythm",
            artist: "BeatMaster Pro",
            duration: 30,
          },
          likes: 1256,
          comments: 98,
          shares: 23,
        },
      ];

      setShorts((prevShorts) => [...prevShorts, ...mockShorts]);
      setLoading(false);

      // In a real app, you'd check if there are more shorts to load
      // setHasMore(data.hasMore)
    } catch (error) {
      console.error("Error fetching shorts:", error);
      setLoading(false);
    }
  };

  // Load more shorts when user reaches near the end
  const loadMoreShorts = () => {
    if (!loading && hasMore) {
      fetchShorts();
    }
  };

  // Handle navigation to next video
  const goToNextVideo = () => {
    if (isAnimating || currentIndex >= shorts.length - 1) return;

    // Set up animation for current video to exit upward
    setIsAnimating(true);
    setAnimationDirection("up");
    setAnimationPhase("exit");
    setNextIndex(currentIndex + 1);

    // First phase: current video exits
    setTimeout(() => {
      // Second phase: next video enters
      setAnimationPhase("enter");

      // Complete animation and update current index
      setTimeout(() => {
        setCurrentIndex(currentIndex + 1);
        setIsAnimating(false);
        setAnimationDirection(null);
        setAnimationPhase(null);
        setNextIndex(null);
      }, 300);
    }, 300);
  };

  // Handle navigation to previous video
  const goToPreviousVideo = () => {
    if (isAnimating || currentIndex <= 0) return;

    // Set up animation for current video to exit downward
    setIsAnimating(true);
    setAnimationDirection("down");
    setAnimationPhase("exit");
    setNextIndex(currentIndex - 1);

    // First phase: current video exits
    setTimeout(() => {
      // Second phase: previous video enters
      setAnimationPhase("enter");

      // Complete animation and update current index
      setTimeout(() => {
        setCurrentIndex(currentIndex - 1);
        setIsAnimating(false);
        setAnimationDirection(null);
        setAnimationPhase(null);
        setNextIndex(null);
      }, 300);
    }, 300);
  };

  // Handle swipe navigation
  const handleSwipe = (direction: "up" | "down") => {
    if (direction === "up") {
      goToNextVideo();
    } else if (direction === "down") {
      goToPreviousVideo();
    }
  };

  // Use keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "ArrowUp") {
        goToPreviousVideo();
      } else if (e.key === "ArrowDown") {
        goToNextVideo();
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [currentIndex, isAnimating, shorts.length]);

  // Load more videos when approaching the end
  useEffect(() => {
    if (currentIndex >= shorts.length - 2 && !loading && hasMore) {
      loadMoreShorts();
    }
  }, [currentIndex, shorts.length, loading, hasMore]);

  // Open swap dialog for a specific short
  const openSwapDialog = (shortId: string) => {
    setSelectedShortId(shortId);
    setIsSwapDialogOpen(true);
  };

  // Handle video swap
  const handleSwapVideo = (
    shortId: string,
    newVideoUrl: string,
    newThumbnailUrl: string
  ) => {
    setShorts(
      shorts.map((short) =>
        short.id === shortId
          ? { ...short, videoUrl: newVideoUrl, thumbnailUrl: newThumbnailUrl }
          : short
      )
    );
    setIsSwapDialogOpen(false);
  };

  // Refresh the current short
  const refreshCurrentShort = () => {
    // In a real app, you would fetch the latest data for this short
    // For now, we'll just show a loading state briefly
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
    }, 1000);
  };

  if (shorts.length === 0 && loading) {
    return (
      <div className="flex min-h-screen">
        <AppSidebar />
        <div className="flex flex-1 items-center justify-center">
          <Loader2 className="h-12 w-12 animate-spin text-primary" />
        </div>
      </div>
    );
  }

  // Handle scroll wheel events
  const handleWheel = (e: React.WheelEvent) => {
    // Prevent handling wheel events during animation
    if (isAnimating) return;

    // Determine scroll direction
    if (e.deltaY > 0 && currentIndex < shorts.length - 1) {
      // Scrolling down - go to next video
      goToNextVideo();
    } else if (e.deltaY < 0 && currentIndex > 0) {
      // Scrolling up - go to previous video
      goToPreviousVideo();
    }
  };

  // Calculate animation styles for current video
  const getCurrentVideoStyle = () => {
    if (!isAnimating) return {};

    if (animationPhase === "exit") {
      return {
        transform:
          animationDirection === "up"
            ? "translateY(-100%)"
            : "translateY(100%)",
        transition: "transform 300ms ease-in-out",
      };
    }

    return {
      display: "none", // Hide current video during enter phase
    };
  };

  // Calculate animation styles for next/previous video
  const getNextVideoStyle = () => {
    if (!isAnimating || nextIndex === null) return { display: "none" };

    if (animationPhase === "exit") {
      return {
        transform:
          animationDirection === "up"
            ? "translateY(100%)"
            : "translateY(-100%)",
        transition: "none",
        display: "block",
      };
    }

    if (animationPhase === "enter") {
      return {
        transform: "translateY(0)",
        transition: "transform 300ms ease-in-out",
        display: "block",
      };
    }

    return { display: "none" };
  };

  return (
    <div
      className="fixed inset-0 z-50 flex-1 overflow-hidden bg-black"
      onWheel={handleWheel}
    >
      {/* Header controls */}
      <div className="absolute left-0 right-0 top-0 z-10 flex items-center justify-between p-4">
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8 rounded-full text-white"
            onClick={() => router.back()}
          >
            <X />
          </Button>
          <h1 className="text-lg font-bold text-white">Shorts</h1>
        </div>
        <div className="flex items-center gap-2">
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8 rounded-full bg-black/50 text-white hover:bg-black/70"
            onClick={refreshCurrentShort}
          >
            <RefreshCw className="h-4 w-4" />
            <span className="sr-only">Refresh</span>
          </Button>
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="h-8 w-8 rounded-full bg-black/50 text-white hover:bg-black/70"
              >
                <MoreHorizontal className="h-4 w-4" />
                <span className="sr-only">More options</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem>
                <Shield className="mr-2 h-4 w-4" />
                <span>Report content</span>
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Shorts container */}
      <div className="h-full w-full">
        {/* Current video */}
        {shorts.length > 0 && (
          <div
            className="absolute h-screen w-full"
            style={getCurrentVideoStyle()}
          >
            <ShortVideoPlayer
              short={shorts[currentIndex]}
              isActive={isAnimating ? false : true}
              onSwipe={handleSwipe}
            />
          </div>
        )}

        {/* Next/Previous video (for animation) */}
        {nextIndex !== null && shorts[nextIndex] && (
          <div className="absolute h-screen w-full" style={getNextVideoStyle()}>
            <ShortVideoPlayer
              short={shorts[nextIndex]}
              isActive={animationPhase === "enter"}
              onSwipe={handleSwipe}
            />
          </div>
        )}
      </div>

      {loading && shorts.length > 0 && (
        <div className="absolute bottom-20 left-0 right-0 flex justify-center">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      )}

      {/* Scroll indicators */}
      <div className="absolute left-1/2 top-4 -translate-x-1/2 transform text-white opacity-50 pointer-events-none">
        {currentIndex > 0 && !isAnimating && (
          <div className="flex flex-col items-center text-xs">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="animate-bounce"
            >
              <path d="m18 15-6-6-6 6" />
            </svg>
            <span>Scroll up for previous</span>
          </div>
        )}
      </div>

      <div className="absolute bottom-4 left-1/2 -translate-x-1/2 transform text-white opacity-50 pointer-events-none">
        {currentIndex < shorts.length - 1 && !isAnimating && (
          <div className="flex flex-col items-center text-xs">
            <span>Scroll down for next</span>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="animate-bounce"
            >
              <path d="m6 9 6 6 6-6" />
            </svg>
          </div>
        )}
      </div>
    </div>
  );
}
