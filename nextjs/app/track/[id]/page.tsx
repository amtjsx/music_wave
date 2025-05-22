"use client";

import type React from "react";

import {
  AlertTriangle,
  Calendar,
  Download,
  Flag,
  Heart,
  ListMusic,
  MessageSquare,
  MoreHorizontal,
  Music,
  Pause,
  Play,
  Repeat,
  Share2,
  Shuffle,
  SkipBack,
  SkipForward,
  Volume2,
  VolumeX,
  X,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useRef, useState } from "react";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Separator } from "@/components/ui/separator";
import { Slider } from "@/components/ui/slider";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { VerifiedBadge } from "@/components/verified-badge";
import { useParams } from "next/navigation";
import { toast } from "sonner";
import { WaveformVisualizer } from "./waveform-visualizer";

export default function TrackDetailPage() {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(80);
  const [isMuted, setIsMuted] = useState(false);
  const [isLiked, setIsLiked] = useState(false);
  const [activeTab, setActiveTab] = useState("lyrics");
  const [showAllLyrics, setShowAllLyrics] = useState(false);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  const params = useParams();
  // Comment interaction states
  const [replyingTo, setReplyingTo] = useState<string | null>(null);
  const [reportingComment, setReportingComment] = useState<{
    id: string;
    type: "comment" | "reply";
    parentId?: string;
  } | null>(null);
  const [reportReason, setReportReason] = useState<string>("inappropriate");
  const [reportDetails, setReportDetails] = useState<string>("");
  const [reportSubmitted, setReportSubmitted] = useState(false);

  // This would come from your API in a real implementation
  const track = {
    id: params.id,
    title: "Midnight Dreams",
    artist: {
      name: "Jane Doe",
      id: "1",
      slug: "jane-doe",
      isVerified: true,
    },
    album: {
      title: "Echoes",
      id: "1",
      releaseDate: "2025-03-15",
    },
    coverArt: "/track-cover-art.png",
    audioUrl: "/audio-sample.mp3",
    duration: 225, // in seconds
    plays: 845200,
    likes: 32400,
    releaseDate: "March 15, 2025",
    genre: "Electronic",
    bpm: 128,
    key: "A Minor",
    tags: ["Ambient", "Downtempo", "Melodic"],
    description:
      "A journey through ambient soundscapes and driving beats, 'Midnight Dreams' captures the essence of late-night inspiration and creative flow.",
    lyrics: `[Verse 1]
Midnight shadows dance across the wall
Thoughts are racing, I can't make them stop
City lights flicker through the blinds
Another sleepless night, losing track of time

[Chorus]
In my midnight dreams
Nothing's what it seems
Colors brighter than they've ever been
In my midnight dreams
Breaking at the seams
Finding pieces of a different me

[Verse 2]
Silence speaks in volumes now
Creativity flows, I don't question how
Melodies emerge from the dark
Guiding me through visions like a spark

[Chorus]
In my midnight dreams
Nothing's what it seems
Colors brighter than they've ever been
In my midnight dreams
Breaking at the seams
Finding pieces of a different me

[Bridge]
The world is quiet
My mind is loud
Building universes
When no one's around

[Chorus]
In my midnight dreams
Nothing's what it seems
Colors brighter than they've ever been
In my midnight dreams
Breaking at the seams
Finding pieces of a different me

[Outro]
Midnight dreams...
Midnight dreams...`,
  };

  // Updated comments data structure to include moderation status
  const comments = [
    {
      id: "1",
      user: {
        name: "Alex Johnson",
        avatar: "/diverse-musician-ensemble.png",
      },
      text: "This track is absolutely incredible! The ambient textures combined with that driving beat create such a unique atmosphere. Been listening to it on repeat all week.",
      timestamp: "2 days ago",
      likes: 24,
      moderationStatus: "approved", // approved, reported, under_review, removed
      reportCount: 0,
      replies: [
        {
          id: "1-1",
          user: {
            name: "Jane Doe",
            avatar: "/artist-profile.png",
          },
          text: "Thank you so much, Alex! I spent a lot of time layering those textures. So glad you're enjoying it!",
          timestamp: "1 day ago",
          likes: 12,
          isArtist: true,
          moderationStatus: "approved",
          reportCount: 0,
        },
        {
          id: "1-2",
          user: {
            name: "Michael Chen",
            avatar: "/guitarist.png",
          },
          text: "I agree! The production quality is top-notch. What synths did you use for this?",
          timestamp: "1 day ago",
          likes: 5,
          moderationStatus: "approved",
          reportCount: 0,
        },
      ],
      showReplies: true,
    },
    {
      id: "2",
      user: {
        name: "Sarah Williams",
        avatar: "/powerful-vocalist.png",
      },
      text: "The melody in the bridge section gives me chills every time. Masterful production!",
      timestamp: "5 days ago",
      likes: 18,
      moderationStatus: "approved",
      reportCount: 0,
      replies: [],
      showReplies: true,
    },
    {
      id: "3",
      user: {
        name: "Michael Chen",
        avatar: "/guitarist.png",
      },
      text: "I've been following Jane's work for years, and this might be her best track yet. The progression from her earlier sound to this more refined style is impressive.",
      timestamp: "1 week ago",
      likes: 32,
      moderationStatus: "reported",
      reportCount: 2,
      reportReasons: ["spam", "harassment"],
      replies: [
        {
          id: "3-1",
          user: {
            name: "Sarah Williams",
            avatar: "/powerful-vocalist.png",
          },
          text: "Totally agree! Her sound has evolved so much since her first EP.",
          timestamp: "6 days ago",
          likes: 8,
          moderationStatus: "approved",
          reportCount: 0,
        },
      ],
      showReplies: true,
    },
    {
      id: "4",
      user: {
        name: "TrollUser123",
        avatar: "/placeholder.svg",
      },
      text: "This is terrible music. Everyone who likes this has no taste. [offensive content removed]",
      timestamp: "3 days ago",
      likes: 0,
      moderationStatus: "under_review",
      reportCount: 5,
      reportReasons: ["harassment", "hate_speech", "inappropriate"],
      replies: [],
      showReplies: true,
    },
    {
      id: "5",
      user: {
        name: "RemovedUser",
        avatar: "/placeholder.svg",
      },
      text: "[This comment has been removed for violating community guidelines]",
      timestamp: "4 days ago",
      likes: 0,
      moderationStatus: "removed",
      reportCount: 8,
      replies: [],
      showReplies: false,
    },
  ];

  // Sample related tracks
  const relatedTracks = [
    {
      id: "2",
      title: "Ocean Waves",
      artist: "Jane Doe",
      album: "Echoes",
      coverArt: "/track-cover-2.png",
      duration: "4:12",
    },
    {
      id: "3",
      title: "Starlight",
      artist: "Jane Doe",
      album: "Cosmos",
      coverArt: "/track-cover-3.png",
      duration: "5:30",
    },
    {
      id: "4",
      title: "Electric Soul",
      artist: "Jane Doe",
      album: "Voltage",
      coverArt: "/track-cover-4.png",
      duration: "3:58",
    },
  ];

  useEffect(() => {
    if (audioRef.current) {
      const audio = audioRef.current;

      const handleTimeUpdate = () => {
        setCurrentTime(audio.currentTime);
      };

      const handleLoadedMetadata = () => {
        setDuration(audio.duration);
      };

      const handleEnded = () => {
        setIsPlaying(false);
        setCurrentTime(0);
      };

      audio.addEventListener("timeupdate", handleTimeUpdate);
      audio.addEventListener("loadedmetadata", handleLoadedMetadata);
      audio.addEventListener("ended", handleEnded);

      return () => {
        audio.removeEventListener("timeupdate", handleTimeUpdate);
        audio.removeEventListener("loadedmetadata", handleLoadedMetadata);
        audio.removeEventListener("ended", handleEnded);
      };
    }
  }, []);

  useEffect(() => {
    if (audioRef.current) {
      if (isPlaying) {
        audioRef.current.play().catch((error) => {
          console.error("Error playing audio:", error);
          setIsPlaying(false);
        });
      } else {
        audioRef.current.pause();
      }
    }
  }, [isPlaying]);

  useEffect(() => {
    if (audioRef.current) {
      audioRef.current.volume = isMuted ? 0 : volume / 100;
    }
  }, [volume, isMuted]);

  const togglePlay = () => {
    setIsPlaying(!isPlaying);
  };

  const toggleMute = () => {
    setIsMuted(!isMuted);
  };

  const handleVolumeChange = (value: number[]) => {
    setVolume(value[0]);
    if (value[0] > 0 && isMuted) {
      setIsMuted(false);
    }
  };

  const handleProgressChange = (value: number[]) => {
    if (audioRef.current) {
      const newTime = (value[0] / 100) * duration;
      setCurrentTime(newTime);
      audioRef.current.currentTime = newTime;
    }
  };

  const formatTime = (time: number) => {
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, "0")}`;
  };

  const formatNumber = (num: number) => {
    if (num >= 1000000) {
      return (num / 1000000).toFixed(1) + "M";
    }
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + "K";
    }
    return num.toString();
  };

  const handleReportComment = () => {
    if (!reportingComment) return;

    // In a real app, this would be an API call
    console.log("Reporting comment:", {
      commentId: reportingComment.id,
      commentType: reportingComment.type,
      parentId: reportingComment.parentId,
      reason: reportReason,
      details: reportDetails,
    });

    setReportSubmitted(true);

    // Reset after a delay to show success state
    setTimeout(() => {
      setReportingComment(null);
      setReportReason("inappropriate");
      setReportDetails("");
      setReportSubmitted(false);

      // Show toast notification
      toast("Report submitted", {
        description:
          "Thank you for helping keep our community safe. Our team will review this content.",
      });
    }, 1500);
  };

  // Helper function to render comment moderation status
  const renderModerationStatus = (status: string) => {
    switch (status) {
      case "reported":
        return (
          <Badge
            variant="outline"
            className="gap-1 text-amber-500 border-amber-200 bg-amber-50 dark:border-amber-800 dark:bg-amber-950/20"
          >
            <AlertTriangle className="h-3 w-3" /> Reported
          </Badge>
        );
      case "under_review":
        return (
          <Badge
            variant="outline"
            className="gap-1 text-blue-500 border-blue-200 bg-blue-50 dark:border-blue-800 dark:bg-blue-950/20"
          >
            <AlertTriangle className="h-3 w-3" /> Under Review
          </Badge>
        );
      case "removed":
        return (
          <Badge
            variant="outline"
            className="gap-1 text-red-500 border-red-200 bg-red-50 dark:border-red-800 dark:bg-red-950/20"
          >
            <X className="h-3 w-3" /> Removed
          </Badge>
        );
      default:
        return null;
    }
  };

  return (
    <>
      <div className="flex flex-col gap-6 p-4">
        {/* Hidden audio element */}
        <audio ref={audioRef} src={track.audioUrl} preload="metadata" />

        {/* Track Header */}
        <div className="flex flex-col gap-6 md:flex-row md:items-center">
          <div className="relative h-48 w-48 flex-shrink-0 overflow-hidden rounded-md md:h-64 md:w-64">
            <Image
              src={track.coverArt || "/placeholder.svg"}
              alt={track.title}
              fill
              className="object-cover"
              priority
            />
          </div>

          <div className="flex flex-1 flex-col gap-4">
            <div>
              <h1 className="text-3xl font-bold">{track.title}</h1>
              <div className="mt-1 flex items-center gap-2">
                <Link
                  href={`/artist/${track.artist.slug}`}
                  className="text-xl text-purple-600 hover:underline"
                >
                  {track.artist.name}
                </Link>
                {track.artist.isVerified && <VerifiedBadge size="sm" />}
              </div>
              <p className="mt-1 text-muted-foreground">
                Album:{" "}
                <Link href={`/album/${track.album.id}`}>
                  {track.album.title}
                </Link>
              </p>
            </div>

            <div className="flex flex-wrap gap-2">
              <Badge variant="secondary">{track.genre}</Badge>
              {track.tags.map((tag) => (
                <Badge key={tag} variant="outline">
                  {tag}
                </Badge>
              ))}
            </div>

            <div className="flex items-center gap-4 text-sm text-muted-foreground">
              <div className="flex items-center gap-1">
                <Music className="h-4 w-4" />
                <span>{formatNumber(track.plays)} plays</span>
              </div>
              <div className="flex items-center gap-1">
                <Heart className="h-4 w-4" />
                <span>{formatNumber(track.likes)} likes</span>
              </div>
              <div className="flex items-center gap-1">
                <Calendar className="h-4 w-4" />
                <span>Released {track.releaseDate}</span>
              </div>
            </div>

            <div className="flex flex-wrap gap-2">
              <Button
                className={`gap-2 ${
                  isPlaying ? "bg-purple-700" : "bg-purple-600"
                } hover:bg-purple-700`}
                onClick={togglePlay}
              >
                {isPlaying ? (
                  <Pause className="h-4 w-4" />
                ) : (
                  <Play className="h-4 w-4" />
                )}
                {isPlaying ? "Pause" : "Play"}
              </Button>
              <Button
                variant="outline"
                className={`gap-2 ${
                  isLiked ? "bg-pink-100 text-pink-600 dark:bg-pink-900/20" : ""
                }`}
                onClick={() => setIsLiked(!isLiked)}
              >
                <Heart className={`h-4 w-4 ${isLiked ? "fill-current" : ""}`} />
                {isLiked ? "Liked" : "Like"}
              </Button>
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="outline" className="gap-2">
                    <ListMusic className="h-4 w-4" />
                    Add to Playlist
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent>
                  <DropdownMenuLabel>Your Playlists</DropdownMenuLabel>
                  <DropdownMenuItem>Favorites</DropdownMenuItem>
                  <DropdownMenuItem>Chill Vibes</DropdownMenuItem>
                  <DropdownMenuItem>Workout Mix</DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem>Create New Playlist</DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
              <Button variant="outline" className="gap-2">
                <Share2 className="h-4 w-4" />
                Share
              </Button>
              <Button variant="outline" className="gap-2">
                <Download className="h-4 w-4" />
                Download
              </Button>
              <Button variant="outline" size="icon">
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </div>

        {/* Audio Player with Waveform */}
        <div className="rounded-md border bg-card p-4">
          <div className="mb-4 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Button variant="outline" size="icon" className="h-8 w-8">
                <SkipBack className="h-4 w-4" />
              </Button>
              <Button
                className={`h-10 w-10 rounded-full ${
                  isPlaying ? "bg-purple-700" : "bg-purple-600"
                } hover:bg-purple-700`}
                onClick={togglePlay}
              >
                {isPlaying ? (
                  <Pause className="h-5 w-5" />
                ) : (
                  <Play className="h-5 w-5 pl-0.5" />
                )}
              </Button>
              <Button variant="outline" size="icon" className="h-8 w-8">
                <SkipForward className="h-4 w-4" />
              </Button>
            </div>

            <div className="flex items-center gap-2">
              <Button variant="ghost" size="icon" className="h-8 w-8">
                <Shuffle className="h-4 w-4" />
              </Button>
              <Button variant="ghost" size="icon" className="h-8 w-8">
                <Repeat className="h-4 w-4" />
              </Button>
              <div className="flex items-center gap-2">
                <Button
                  variant="ghost"
                  size="icon"
                  className="h-8 w-8"
                  onClick={toggleMute}
                >
                  {isMuted || volume === 0 ? (
                    <VolumeX className="h-4 w-4" />
                  ) : (
                    <Volume2 className="h-4 w-4" />
                  )}
                </Button>
                <Slider
                  className="w-24"
                  value={[isMuted ? 0 : volume]}
                  max={100}
                  step={1}
                  onValueChange={handleVolumeChange}
                />
              </div>
            </div>
          </div>

          <div className="mb-2 h-24">
            <WaveformVisualizer
              isPlaying={isPlaying}
              progress={duration > 0 ? (currentTime / duration) * 100 : 0}
              onProgressChange={handleProgressChange}
            />
          </div>

          <div className="flex items-center justify-between text-xs text-muted-foreground">
            <span>{formatTime(currentTime)}</span>
            <span>{formatTime(duration)}</span>
          </div>
        </div>

        {/* Track Details Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList>
            <TabsTrigger value="lyrics">Lyrics</TabsTrigger>
            <TabsTrigger value="details">Details</TabsTrigger>
            <TabsTrigger value="comments">
              Comments{" "}
              <Badge variant="secondary" className="ml-1">
                {comments.length}
              </Badge>
            </TabsTrigger>
            <TabsTrigger value="related">Related Tracks</TabsTrigger>
          </TabsList>

          {/* Lyrics Tab */}
          <TabsContent value="lyrics" className="mt-6">
            <div className="rounded-md border bg-card p-6">
              {track.lyrics ? (
                <>
                  <pre
                    className={`whitespace-pre-wrap font-sans text-sm leading-relaxed ${
                      !showAllLyrics && "max-h-96 overflow-hidden"
                    }`}
                  >
                    {track.lyrics}
                  </pre>
                  {!showAllLyrics && (
                    <div className="relative mt-4">
                      <div className="absolute inset-x-0 -top-16 h-16 bg-gradient-to-t from-card to-transparent"></div>
                      <Button
                        variant="outline"
                        onClick={() => setShowAllLyrics(true)}
                      >
                        Show All Lyrics
                      </Button>
                    </div>
                  )}
                </>
              ) : (
                <p className="text-center text-muted-foreground">
                  Lyrics are not available for this track.
                </p>
              )}
            </div>
          </TabsContent>

          {/* Details Tab */}
          <TabsContent value="details" className="mt-6">
            <div className="rounded-md border bg-card p-6">
              <div className="grid gap-6 md:grid-cols-2">
                <div>
                  <h3 className="mb-4 text-lg font-semibold">
                    Track Information
                  </h3>
                  <dl className="space-y-3">
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">
                        Title
                      </dt>
                      <dd>{track.title}</dd>
                    </div>
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">
                        Artist
                      </dt>
                      <dd className="flex items-center gap-1">
                        <Link
                          href={`/artist/${track.artist.slug}`}
                          className="text-purple-600 hover:underline"
                        >
                          {track.artist.name}
                        </Link>
                        {track.artist.isVerified && <VerifiedBadge size="sm" />}
                      </dd>
                    </div>
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">
                        Album
                      </dt>
                      <dd>
                        <Link
                          href={`/album/${track.album.id}`}
                          className="text-purple-600 hover:underline"
                        >
                          {track.album.title}
                        </Link>
                      </dd>
                    </div>
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">
                        Release Date
                      </dt>
                      <dd>{track.releaseDate}</dd>
                    </div>
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">
                        Duration
                      </dt>
                      <dd>{formatTime(track.duration)}</dd>
                    </div>
                  </dl>
                </div>

                <div>
                  <h3 className="mb-4 text-lg font-semibold">
                    Technical Details
                  </h3>
                  <dl className="space-y-3">
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">
                        Genre
                      </dt>
                      <dd>
                        <Badge variant="secondary">{track.genre}</Badge>
                      </dd>
                    </div>
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">BPM</dt>
                      <dd>{track.bpm}</dd>
                    </div>
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">Key</dt>
                      <dd>{track.key}</dd>
                    </div>
                    <div className="flex justify-between">
                      <dt className="font-medium text-muted-foreground">
                        Tags
                      </dt>
                      <dd className="flex flex-wrap justify-end gap-1">
                        {track.tags.map((tag) => (
                          <Badge key={tag} variant="outline">
                            {tag}
                          </Badge>
                        ))}
                      </dd>
                    </div>
                  </dl>
                </div>
              </div>

              <Separator className="my-6" />

              <div>
                <h3 className="mb-4 text-lg font-semibold">Description</h3>
                <p className="text-muted-foreground">{track.description}</p>
              </div>
            </div>
          </TabsContent>

          {/* Comments Tab */}
          <TabsContent value="comments" className="mt-6">
            <div className="rounded-md border bg-card p-6">
              <div className="mb-6">
                <h3 className="mb-4 text-lg font-semibold">Add a Comment</h3>
                <div className="flex gap-4">
                  <Avatar className="h-10 w-10">
                    <AvatarFallback>YO</AvatarFallback>
                  </Avatar>
                  <div className="flex-1">
                    <textarea
                      className="min-h-[100px] w-full rounded-md border bg-background p-3"
                      placeholder="Share your thoughts about this track..."
                    ></textarea>
                    <div className="mt-2 flex justify-end">
                      <Button className="bg-purple-600 hover:bg-purple-700">
                        Post Comment
                      </Button>
                    </div>
                  </div>
                </div>
              </div>

              <Separator className="my-6" />

              <div className="space-y-6">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-semibold">
                    Comments ({comments.length})
                  </h3>
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-muted-foreground">
                      Community Guidelines
                    </span>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="outline" size="sm">
                          Sort by: Newest
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem>Newest</DropdownMenuItem>
                        <DropdownMenuItem>Oldest</DropdownMenuItem>
                        <DropdownMenuItem>Most Liked</DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </div>
                </div>

                {comments.map((comment) => (
                  <div key={comment.id} className="space-y-4">
                    <div
                      className={`flex gap-4 ${
                        comment.moderationStatus === "removed"
                          ? "opacity-60"
                          : ""
                      }`}
                    >
                      <Avatar className="h-10 w-10">
                        <AvatarImage
                          src={comment.user.avatar || "/placeholder.svg"}
                          alt={comment.user.name}
                        />
                        <AvatarFallback>
                          {comment.user.name.charAt(0)}
                        </AvatarFallback>
                      </Avatar>
                      <div className="flex-1">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <h4 className="font-medium">{comment.user.name}</h4>
                            {renderModerationStatus(comment.moderationStatus)}
                          </div>
                          <span className="text-xs text-muted-foreground">
                            {comment.timestamp}
                          </span>
                        </div>
                        <p className="mt-1 text-sm">{comment.text}</p>

                        {comment.moderationStatus !== "removed" && (
                          <div className="mt-2 flex items-center gap-4">
                            <Button
                              variant="ghost"
                              size="sm"
                              className="h-8 gap-1 text-xs"
                            >
                              <Heart className="h-3.5 w-3.5" />
                              {comment.likes}
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              className="h-8 gap-1 text-xs"
                              onClick={() =>
                                setReplyingTo(
                                  replyingTo === comment.id ? null : comment.id
                                )
                              }
                            >
                              <MessageSquare className="h-3.5 w-3.5" />
                              Reply
                            </Button>
                            <DropdownMenu>
                              <DropdownMenuTrigger asChild>
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  className="h-8 gap-1 text-xs"
                                >
                                  <MoreHorizontal className="h-3.5 w-3.5" />
                                </Button>
                              </DropdownMenuTrigger>
                              <DropdownMenuContent align="end">
                                <DropdownMenuItem
                                  className="text-red-600 focus:text-red-600 dark:text-red-400 dark:focus:text-red-400"
                                  onClick={() =>
                                    setReportingComment({
                                      id: comment.id,
                                      type: "comment",
                                    })
                                  }
                                >
                                  <Flag className="mr-2 h-4 w-4" />
                                  Report Comment
                                </DropdownMenuItem>
                              </DropdownMenuContent>
                            </DropdownMenu>
                          </div>
                        )}

                        {/* Reply Form */}
                        {replyingTo === comment.id && (
                          <div className="mt-4 flex gap-3">
                            <div className="ml-6 w-5 border-l-2 border-muted"></div>
                            <Avatar className="h-8 w-8">
                              <AvatarFallback>YO</AvatarFallback>
                            </Avatar>
                            <div className="flex-1">
                              <textarea
                                className="min-h-[80px] w-full rounded-md border bg-background p-3 text-sm"
                                placeholder={`Reply to ${comment.user.name}...`}
                                autoFocus
                              ></textarea>
                              <div className="mt-2 flex justify-end gap-2">
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => setReplyingTo(null)}
                                >
                                  Cancel
                                </Button>
                                <Button
                                  size="sm"
                                  className="bg-purple-600 hover:bg-purple-700"
                                >
                                  Post Reply
                                </Button>
                              </div>
                            </div>
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Replies Section */}
                    {comment.replies &&
                      comment.replies.length > 0 &&
                      comment.moderationStatus !== "removed" && (
                        <div className="ml-14 space-y-4">
                          <div className="flex items-center gap-2">
                            <Button
                              variant="ghost"
                              size="sm"
                              className="h-6 gap-1 p-0 text-xs"
                              onClick={() => {
                                // In a real app, you would update the comment's showReplies property
                                console.log(
                                  `Toggle replies for comment ${comment.id}`
                                );
                              }}
                            >
                              {comment.showReplies ? (
                                <>Hide {comment.replies.length} replies</>
                              ) : (
                                <>Show {comment.replies.length} replies</>
                              )}
                            </Button>
                            <div className="h-px flex-1 bg-border"></div>
                          </div>

                          {comment.showReplies && (
                            <div className="space-y-4">
                              {comment.replies.map((reply) => (
                                <div key={reply.id} className="flex gap-3">
                                  <div className="w-5 border-l-2 border-muted"></div>
                                  <Avatar className="h-8 w-8">
                                    <AvatarImage
                                      src={
                                        reply.user.avatar || "/placeholder.svg"
                                      }
                                      alt={reply.user.name}
                                    />
                                    <AvatarFallback>
                                      {reply.user.name.charAt(0)}
                                    </AvatarFallback>
                                  </Avatar>
                                  <div className="flex-1">
                                    <div className="flex items-center gap-2">
                                      <h4 className="text-sm font-medium">
                                        {reply.user.name}
                                      </h4>
                                      {reply.isArtist && (
                                        <Badge
                                          variant="outline"
                                          className="text-xs text-purple-600 border-purple-200 bg-purple-50 dark:border-purple-800 dark:bg-purple-900/20"
                                        >
                                          Artist
                                        </Badge>
                                      )}
                                      {renderModerationStatus(
                                        reply.moderationStatus
                                      )}
                                      <span className="text-xs text-muted-foreground">
                                        {reply.timestamp}
                                      </span>
                                    </div>
                                    <p className="mt-1 text-sm">{reply.text}</p>
                                    <div className="mt-1 flex items-center gap-4">
                                      <Button
                                        variant="ghost"
                                        size="sm"
                                        className="h-6 gap-1 text-xs"
                                      >
                                        <Heart className="h-3 w-3" />
                                        {reply.likes}
                                      </Button>
                                      <Button
                                        variant="ghost"
                                        size="sm"
                                        className="h-6 gap-1 text-xs"
                                        onClick={() =>
                                          setReplyingTo(
                                            replyingTo === reply.id
                                              ? null
                                              : reply.id
                                          )
                                        }
                                      >
                                        <MessageSquare className="h-3 w-3" />
                                        Reply
                                      </Button>
                                      <DropdownMenu>
                                        <DropdownMenuTrigger asChild>
                                          <Button
                                            variant="ghost"
                                            size="sm"
                                            className="h-6 gap-1 text-xs"
                                          >
                                            <MoreHorizontal className="h-3 w-3" />
                                          </Button>
                                        </DropdownMenuTrigger>
                                        <DropdownMenuContent align="end">
                                          <DropdownMenuItem
                                            className="text-red-600 focus:text-red-600 dark:text-red-400 dark:focus:text-red-400"
                                            onClick={() =>
                                              setReportingComment({
                                                id: reply.id,
                                                type: "reply",
                                                parentId: comment.id,
                                              })
                                            }
                                          >
                                            <Flag className="mr-2 h-4 w-4" />
                                            Report Reply
                                          </DropdownMenuItem>
                                        </DropdownMenuContent>
                                      </DropdownMenu>
                                    </div>

                                    {/* Nested Reply Form */}
                                    {replyingTo === reply.id && (
                                      <div className="mt-3 flex gap-3">
                                        <div className="w-5 border-l-2 border-muted"></div>
                                        <Avatar className="h-8 w-8">
                                          <AvatarFallback>YO</AvatarFallback>
                                        </Avatar>
                                        <div className="flex-1">
                                          <textarea
                                            className="min-h-[80px] w-full rounded-md border bg-background p-3 text-sm"
                                            placeholder={`Reply to ${reply.user.name}...`}
                                            autoFocus
                                          ></textarea>
                                          <div className="mt-2 flex justify-end gap-2">
                                            <Button
                                              variant="outline"
                                              size="sm"
                                              onClick={() =>
                                                setReplyingTo(null)
                                              }
                                            >
                                              Cancel
                                            </Button>
                                            <Button
                                              size="sm"
                                              className="bg-purple-600 hover:bg-purple-700"
                                            >
                                              Post Reply
                                            </Button>
                                          </div>
                                        </div>
                                      </div>
                                    )}
                                  </div>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      )}
                  </div>
                ))}
              </div>
            </div>
          </TabsContent>

          {/* Related Tracks Tab */}
          <TabsContent value="related" className="mt-6">
            <div className="rounded-md border bg-card p-6">
              <h3 className="mb-4 text-lg font-semibold">
                More from {track.artist.name}
              </h3>
              <div className="space-y-4">
                {relatedTracks.map((relatedTrack) => (
                  <Link
                    key={relatedTrack.id}
                    href={`/track/${relatedTrack.id}`}
                    className="flex items-center gap-4 rounded-md p-2 transition-colors hover:bg-muted"
                  >
                    <div className="relative h-16 w-16 overflow-hidden rounded-md">
                      <Image
                        src={relatedTrack.coverArt || "/placeholder.svg"}
                        alt={relatedTrack.title}
                        fill
                        className="object-cover"
                        sizes="64px"
                      />
                    </div>
                    <div className="flex-1">
                      <h4 className="font-medium">{relatedTrack.title}</h4>
                      <p className="text-sm text-muted-foreground">
                        Album: {relatedTrack.album} • {relatedTrack.duration}
                      </p>
                    </div>
                    <Button variant="ghost" size="icon" className="h-8 w-8">
                      <Play className="h-4 w-4" />
                    </Button>
                  </Link>
                ))}
              </div>
            </div>
          </TabsContent>
        </Tabs>
      </div>

      {/* Report Comment Dialog */}
      <Dialog
        open={reportingComment !== null}
        onOpenChange={(open) => !open && setReportingComment(null)}
      >
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>
              {reportSubmitted
                ? "Report Submitted"
                : `Report ${
                    reportingComment?.type === "reply" ? "Reply" : "Comment"
                  }`}
            </DialogTitle>
            <DialogDescription>
              {reportSubmitted
                ? "Thank you for helping keep our community safe. Our team will review this content."
                : "Please let us know why you're reporting this content. Your report will be reviewed by our moderation team."}
            </DialogDescription>
          </DialogHeader>

          {reportSubmitted ? (
            <div className="flex flex-col items-center justify-center py-4">
              <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-green-100 dark:bg-green-900">
                <CheckIcon className="h-6 w-6 text-green-600" />
              </div>
              <p className="text-center text-sm">
                Your report has been submitted successfully.
              </p>
            </div>
          ) : (
            <>
              <div className="space-y-4 py-4">
                <RadioGroup
                  value={reportReason}
                  onValueChange={setReportReason}
                  className="space-y-2"
                >
                  <div className="flex items-start space-x-2">
                    <RadioGroupItem value="inappropriate" id="inappropriate" />
                    <Label htmlFor="inappropriate" className="cursor-pointer">
                      <div className="font-medium">Inappropriate Content</div>
                      <p className="text-xs text-muted-foreground">
                        Content that contains offensive language, explicit
                        material, or violates our community guidelines.
                      </p>
                    </Label>
                  </div>
                  <div className="flex items-start space-x-2">
                    <RadioGroupItem value="harassment" id="harassment" />
                    <Label htmlFor="harassment" className="cursor-pointer">
                      <div className="font-medium">Harassment or Bullying</div>
                      <p className="text-xs text-muted-foreground">
                        Content that targets, threatens, or intimidates an
                        individual or group.
                      </p>
                    </Label>
                  </div>
                  <div className="flex items-start space-x-2">
                    <RadioGroupItem value="hate_speech" id="hate_speech" />
                    <Label htmlFor="hate_speech" className="cursor-pointer">
                      <div className="font-medium">Hate Speech</div>
                      <p className="text-xs text-muted-foreground">
                        Content that promotes discrimination, bigotry, or hatred
                        against protected groups.
                      </p>
                    </Label>
                  </div>
                  <div className="flex items-start space-x-2">
                    <RadioGroupItem value="spam" id="spam" />
                    <Label htmlFor="spam" className="cursor-pointer">
                      <div className="font-medium">Spam or Misleading</div>
                      <p className="text-xs text-muted-foreground">
                        Content that is repetitive, unwanted, or contains
                        misleading information.
                      </p>
                    </Label>
                  </div>
                  <div className="flex items-start space-x-2">
                    <RadioGroupItem value="other" id="other" />
                    <Label htmlFor="other" className="cursor-pointer">
                      <div className="font-medium">Other</div>
                      <p className="text-xs text-muted-foreground">
                        Another reason not listed above.
                      </p>
                    </Label>
                  </div>
                </RadioGroup>

                <div className="space-y-2">
                  <Label htmlFor="report-details">
                    Additional Details (Optional)
                  </Label>
                  <Textarea
                    id="report-details"
                    placeholder="Please provide any additional information that might help our moderation team."
                    value={reportDetails}
                    onChange={(e) => setReportDetails(e.target.value)}
                  />
                </div>
              </div>

              <DialogFooter className="sm:justify-between">
                <div className="text-xs text-muted-foreground">
                  Your report will be kept anonymous.
                </div>
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    onClick={() => setReportingComment(null)}
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={handleReportComment}
                    className="bg-red-600 hover:bg-red-700"
                  >
                    Submit Report
                  </Button>
                </div>
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
}

// CheckIcon component for the success state
function CheckIcon(props: React.SVGProps<SVGSVGElement>) {
  return (
    <svg
      {...props}
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
    >
      <path d="M20 6L9 17l-5-5" />
    </svg>
  );
}
