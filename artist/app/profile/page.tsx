import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { VerifiedBadge } from "@/components/verified-badge";
import {
  Clock,
  Edit,
  Heart,
  ListMusic,
  Mail,
  MessageSquare,
  Music,
  Settings,
  Share2,
  Users,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import type React from "react";
import { Suspense } from "react";
import { TrustScoreBadge } from "../track/[id]/trust-score-badge";
import { TrustScoreCard } from "@/components/trust-score-card";

// Mock data for demonstration
const mockUserData = {
  johndoe: {
    userId: "user123",
    username: "johndoe",
    displayName: "John Doe",
    bio: "Music producer and DJ based in Los Angeles. Creating electronic music since 2015.",
    avatarUrl: "/artist-avatar.png",
    coverUrl: "/abstract-music-waves.png",
    isVerified: false,
    isCurrentUser: true,
    joinDate: "May 2021",
    location: "Los Angeles, CA",
    website: "https://johndoe-music.com",
    stats: {
      followers: 1243,
      following: 385,
      tracks: 28,
      playlists: 12,
      likes: 456,
    },
    score: 45,
    accountAge: 120,
    factors: {
      comments: {
        count: 45,
        likes: 78,
        reports: 1,
      },
      content: {
        tracks: 8,
        playlists: 3,
      },
      community: {
        followers: 32,
        following: 64,
        shares: 12,
      },
      moderation: {
        validReports: 4,
        warnings: 0,
      },
    },
    history: [
      { date: "2023-05-01", score: 35, change: 0, reason: "Initial score" },
      {
        date: "2023-05-15",
        score: 38,
        change: 3,
        reason: "Uploaded new track",
      },
      { date: "2023-06-02", score: 40, change: 2, reason: "Gained followers" },
      {
        date: "2023-06-18",
        score: 42,
        change: 2,
        reason: "Positive comment engagement",
      },
      { date: "2023-07-05", score: 41, change: -1, reason: "Comment reported" },
      {
        date: "2023-07-20",
        score: 45,
        change: 4,
        reason: "Created popular playlist",
      },
    ],
    tracks: [
      {
        id: "track1",
        title: "Summer Vibes",
        coverUrl: "/track-cover-art.png",
        duration: "3:45",
        plays: 12500,
        likes: 843,
        comments: 56,
        date: "2 months ago",
      },
      {
        id: "track2",
        title: "Midnight Dreams",
        coverUrl: "/track-cover-2.png",
        duration: "4:12",
        plays: 8700,
        likes: 621,
        comments: 42,
        date: "3 months ago",
      },
      {
        id: "track3",
        title: "Urban Echoes",
        coverUrl: "/track-cover-3.png",
        duration: "3:28",
        plays: 6300,
        likes: 412,
        comments: 28,
        date: "5 months ago",
      },
    ],
    playlists: [
      {
        id: "playlist1",
        title: "Workout Mix 2023",
        coverUrl: "/track-cover-4.png",
        trackCount: 15,
        plays: 4500,
        likes: 320,
        date: "1 month ago",
      },
      {
        id: "playlist2",
        title: "Chill Evening",
        coverUrl: "/track-cover-2.png",
        trackCount: 8,
        plays: 3200,
        likes: 245,
        date: "2 months ago",
      },
    ],
    recentActivity: [
      {
        type: "upload",
        content: "Uploaded a new track: Summer Vibes",
        date: "2 weeks ago",
      },
      {
        type: "playlist",
        content: "Created a new playlist: Workout Mix 2023",
        date: "1 month ago",
      },
      {
        type: "like",
        content: "Liked 5 tracks from Electronic Essentials",
        date: "1 month ago",
      },
      {
        type: "comment",
        content: "Commented on Bass Drops by DJ Maximus",
        date: "2 months ago",
      },
    ],
  },
  musicmaster: {
    userId: "user456",
    username: "musicmaster",
    displayName: "Music Master",
    bio: "Professional music producer with 10+ years of experience. Grammy-nominated artist specializing in electronic and hip-hop production.",
    avatarUrl: "/artist-profile.png",
    coverUrl: "/abstract-music-waves.png",
    isVerified: true,
    isCurrentUser: false,
    joinDate: "January 2019",
    location: "New York, NY",
    website: "https://musicmaster.com",
    stats: {
      followers: 24500,
      following: 1250,
      tracks: 87,
      playlists: 35,
      likes: 12400,
    },
    score: 82,
    accountAge: 365,
    factors: {
      comments: {
        count: 156,
        likes: 423,
        reports: 0,
      },
      content: {
        tracks: 25,
        playlists: 12,
      },
      community: {
        followers: 245,
        following: 187,
        shares: 78,
      },
      moderation: {
        validReports: 10,
        warnings: 0,
      },
    },
    history: [
      { date: "2022-05-10", score: 30, change: 0, reason: "Initial score" },
      { date: "2022-06-15", score: 35, change: 5, reason: "Regular activity" },
      {
        date: "2022-08-22",
        score: 45,
        change: 10,
        reason: "Track featured in editorial",
      },
      {
        date: "2022-10-30",
        score: 55,
        change: 10,
        reason: "Consistent positive engagement",
      },
      {
        date: "2023-01-12",
        score: 65,
        change: 10,
        reason: "Helpful community reports",
      },
      {
        date: "2023-03-25",
        score: 75,
        change: 10,
        reason: "Reached 200 followers",
      },
      {
        date: "2023-05-18",
        score: 82,
        change: 7,
        reason: "High-quality content creation",
      },
    ],
    tracks: [
      {
        id: "track1",
        title: "Neon Lights",
        coverUrl: "/track-cover-art.png",
        duration: "4:15",
        plays: 145000,
        likes: 12400,
        comments: 876,
        date: "1 month ago",
      },
      {
        id: "track2",
        title: "Urban Jungle",
        coverUrl: "/track-cover-3.png",
        duration: "3:52",
        plays: 98700,
        likes: 8621,
        comments: 542,
        date: "2 months ago",
      },
      {
        id: "track3",
        title: "Digital Dreams",
        coverUrl: "/track-cover-2.png",
        duration: "5:08",
        plays: 76300,
        likes: 6412,
        comments: 428,
        date: "3 months ago",
      },
    ],
    playlists: [
      {
        id: "playlist1",
        title: "Production Masterclass",
        coverUrl: "/track-cover-4.png",
        trackCount: 25,
        plays: 45000,
        likes: 3200,
        date: "2 weeks ago",
      },
      {
        id: "playlist2",
        title: "Studio Essentials",
        coverUrl: "/track-cover-2.png",
        trackCount: 18,
        plays: 32000,
        likes: 2450,
        date: "1 month ago",
      },
    ],
    recentActivity: [
      {
        type: "upload",
        content: "Uploaded a new track: Neon Lights",
        date: "1 month ago",
      },
      {
        type: "playlist",
        content: "Created a new playlist: Production Masterclass",
        date: "2 weeks ago",
      },
      {
        type: "like",
        content: "Liked 12 tracks from Top Producers 2023",
        date: "3 weeks ago",
      },
      {
        type: "comment",
        content: "Commented on Future Beats by Producer X",
        date: "1 month ago",
      },
    ],
  },
};

export default function UserProfilePage() {
  const userData = mockUserData["johndoe"]; // Fallback to default user

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Cover Image */}
      <div className="relative h-64 w-full bg-gradient-to-r from-purple-700 to-purple-900">
        {userData.coverUrl && (
          <Image
            src={userData.coverUrl || "/placeholder.svg"}
            alt={`${userData.displayName}'s cover`}
            fill
            className="object-cover opacity-60"
            priority
          />
        )}
      </div>

      {/* Profile Header */}
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="relative -mt-24 mb-8 flex flex-col items-center sm:flex-row sm:items-end">
          {/* Avatar */}
          <div className="relative h-36 w-36 overflow-hidden rounded-full border-4 border-white bg-white shadow-lg">
            <Image
              src={userData.avatarUrl || "/placeholder.svg"}
              alt={userData.displayName}
              fill
              className="object-cover"
            />
          </div>

          {/* Profile Info */}
          <div className="mt-4 flex flex-1 flex-col items-center text-center sm:ml-6 sm:items-start sm:text-left">
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold text-gray-900">
                {userData.displayName}
              </h1>
              {userData.isVerified && <VerifiedBadge size="md" />}
              <TrustScoreBadge
                score={userData.score}
                size="md"
                showLabel={false}
              />
            </div>
            <p className="text-gray-500">@{userData.username}</p>
            <p className="mt-2 max-w-2xl text-gray-700">{userData.bio}</p>

            {/* Profile Meta */}
            <div className="mt-3 flex flex-wrap items-center gap-4 text-sm text-gray-500">
              <div className="flex items-center gap-1">
                <Clock className="h-4 w-4" />
                <span>Joined {userData.joinDate}</span>
              </div>
              {userData.location && (
                <div className="flex items-center gap-1">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-4 w-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                    />
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                    />
                  </svg>
                  <span>{userData.location}</span>
                </div>
              )}
              {userData.website && (
                <div className="flex items-center gap-1">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    className="h-4 w-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
                    />
                  </svg>
                  <a
                    href={userData.website}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-purple-600 hover:underline"
                  >
                    {userData.website.replace(/^https?:\/\//, "")}
                  </a>
                </div>
              )}
            </div>
          </div>

          {/* Action Buttons */}
          <div className="mt-4 flex gap-2 sm:mt-0">
            {userData.isCurrentUser ? (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  className="flex items-center gap-1"
                >
                  <Edit className="h-4 w-4" />
                  <span>Edit Profile</span>
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  className="flex items-center gap-1"
                >
                  <Settings className="h-4 w-4" />
                  <span>Settings</span>
                </Button>
              </>
            ) : (
              <>
                <Button
                  variant="default"
                  size="sm"
                  className="bg-purple-600 hover:bg-purple-700"
                >
                  Follow
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  className="flex items-center gap-1"
                >
                  <Mail className="h-4 w-4" />
                  <span>Message</span>
                </Button>
              </>
            )}
          </div>
        </div>

        {/* Stats Bar */}
        <div className="mb-8 grid grid-cols-2 gap-4 sm:grid-cols-5">
          <StatCard
            icon={<Users className="h-5 w-5 text-purple-500" />}
            label="Followers"
            value={userData.stats.followers.toLocaleString()}
          />
          <StatCard
            icon={<Users className="h-5 w-5 text-purple-500" />}
            label="Following"
            value={userData.stats.following.toLocaleString()}
          />
          <StatCard
            icon={<Music className="h-5 w-5 text-purple-500" />}
            label="Tracks"
            value={userData.stats.tracks.toLocaleString()}
          />
          <StatCard
            icon={<ListMusic className="h-5 w-5 text-purple-500" />}
            label="Playlists"
            value={userData.stats.playlists.toLocaleString()}
          />
          <StatCard
            icon={<Heart className="h-5 w-5 text-purple-500" />}
            label="Likes"
            value={userData.stats.likes.toLocaleString()}
          />
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
          {/* Left Column - Trust Score */}
          <div className="order-2 lg:order-1 lg:col-span-1">
            <TrustScoreCard
              userId={userData.userId}
              username={userData.username}
              score={userData.score}
              accountAge={userData.accountAge}
              factors={userData.factors}
              history={userData.history}
            />

            {/* Recent Activity */}
            <Card className="mt-8">
              <CardContent className="pt-6">
                <h3 className="mb-4 flex items-center gap-2 text-lg font-semibold">
                  <Clock className="h-5 w-5 text-purple-500" />
                  Recent Activity
                </h3>
                <div className="space-y-4">
                  {userData.recentActivity.map((activity, index) => (
                    <div
                      key={index}
                      className="border-b border-gray-100 pb-3 last:border-0"
                    >
                      <p className="text-sm text-gray-800">
                        {activity.content}
                      </p>
                      <p className="text-xs text-gray-500">{activity.date}</p>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Right Column - Content Tabs */}
          <div className="order-1 lg:order-2 lg:col-span-2">
            <Tabs defaultValue="tracks" className="w-full">
              <TabsList className="mb-6 grid w-full grid-cols-3">
                <TabsTrigger value="tracks" className="flex items-center gap-1">
                  <Music className="h-4 w-4" />
                  <span>Tracks</span>
                </TabsTrigger>
                <TabsTrigger
                  value="playlists"
                  className="flex items-center gap-1"
                >
                  <ListMusic className="h-4 w-4" />
                  <span>Playlists</span>
                </TabsTrigger>
                <TabsTrigger
                  value="comments"
                  className="flex items-center gap-1"
                >
                  <MessageSquare className="h-4 w-4" />
                  <span>Comments</span>
                </TabsTrigger>
              </TabsList>

              <TabsContent value="tracks" className="space-y-4">
                <Suspense fallback={<div>Loading tracks...</div>}>
                  {userData.tracks.map((track) => (
                    <TrackItem key={track.id} track={track} />
                  ))}
                </Suspense>
              </TabsContent>

              <TabsContent value="playlists" className="space-y-4">
                <Suspense fallback={<div>Loading playlists...</div>}>
                  {userData.playlists.map((playlist) => (
                    <PlaylistItem key={playlist.id} playlist={playlist} />
                  ))}
                </Suspense>
              </TabsContent>

              <TabsContent value="comments" className="space-y-4">
                <div className="rounded-lg border border-gray-200 bg-gray-50 p-8 text-center">
                  <MessageSquare className="mx-auto h-10 w-10 text-gray-400" />
                  <h3 className="mt-2 text-lg font-medium">No comments yet</h3>
                  <p className="mt-1 text-gray-500">
                    Comments you make on tracks will appear here.
                  </p>
                </div>
              </TabsContent>
            </Tabs>
          </div>
        </div>
      </div>
    </div>
  );
}

interface StatCardProps {
  icon: React.ReactNode;
  label: string;
  value: string;
}

function StatCard({ icon, label, value }: StatCardProps) {
  return (
    <Card className="flex flex-col items-center justify-center p-4 text-center">
      <div className="mb-1">{icon}</div>
      <p className="text-lg font-bold">{value}</p>
      <p className="text-xs text-gray-500">{label}</p>
    </Card>
  );
}

interface TrackItemProps {
  track: {
    id: string;
    title: string;
    coverUrl: string;
    duration: string;
    plays: number;
    likes: number;
    comments: number;
    date: string;
  };
}

function TrackItem({ track }: TrackItemProps) {
  return (
    <div className="flex items-center gap-4 rounded-lg border border-gray-200 p-3 transition-colors hover:bg-gray-50">
      <div className="relative h-16 w-16 flex-shrink-0 overflow-hidden rounded-md">
        <Image
          src={track.coverUrl || "/placeholder.svg"}
          alt={track.title}
          fill
          className="object-cover"
        />
      </div>
      <div className="flex-1 min-w-0">
        <Link
          href={`/track/${track.id}`}
          className="font-medium hover:text-purple-600"
        >
          {track.title}
        </Link>
        <div className="mt-1 flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-gray-500">
          <span>{track.duration}</span>
          <span>{formatNumber(track.plays)} plays</span>
          <span className="flex items-center gap-1">
            <Heart className="h-3 w-3" /> {formatNumber(track.likes)}
          </span>
          <span className="flex items-center gap-1">
            <MessageSquare className="h-3 w-3" /> {track.comments}
          </span>
          <span>{track.date}</span>
        </div>
      </div>
      <div className="flex gap-2">
        <Button variant="ghost" size="icon" className="h-8 w-8 rounded-full">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-4 w-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
            />
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
        </Button>
        <Button variant="ghost" size="icon" className="h-8 w-8 rounded-full">
          <Share2 className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}

interface PlaylistItemProps {
  playlist: {
    id: string;
    title: string;
    coverUrl: string;
    trackCount: number;
    plays: number;
    likes: number;
    date: string;
  };
}

function PlaylistItem({ playlist }: PlaylistItemProps) {
  return (
    <div className="flex items-center gap-4 rounded-lg border border-gray-200 p-3 transition-colors hover:bg-gray-50">
      <div className="relative h-16 w-16 flex-shrink-0 overflow-hidden rounded-md">
        <Image
          src={playlist.coverUrl || "/placeholder.svg"}
          alt={playlist.title}
          fill
          className="object-cover"
        />
      </div>
      <div className="flex-1 min-w-0">
        <Link
          href={`/playlist/${playlist.id}`}
          className="font-medium hover:text-purple-600"
        >
          {playlist.title}
        </Link>
        <div className="mt-1 flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-gray-500">
          <span>{playlist.trackCount} tracks</span>
          <span>{formatNumber(playlist.plays)} plays</span>
          <span className="flex items-center gap-1">
            <Heart className="h-3 w-3" /> {formatNumber(playlist.likes)}
          </span>
          <span>{playlist.date}</span>
        </div>
      </div>
      <div className="flex gap-2">
        <Button variant="ghost" size="icon" className="h-8 w-8 rounded-full">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            className="h-4 w-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"
            />
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
        </Button>
        <Button variant="ghost" size="icon" className="h-8 w-8 rounded-full">
          <Share2 className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}

// Helper function to format numbers (e.g., 1200 -> 1.2K)
function formatNumber(num: number): string {
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + "M";
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + "K";
  }
  return num.toString();
}
