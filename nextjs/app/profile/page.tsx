"use client";

import { TrustScoreBadge } from "@/components/trust-score-badge";
import { TrustScoreCard } from "@/components/trust-score-card";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
    BarChart3,
    Camera,
    Clock,
    Edit,
    Headphones,
    Heart,
    History,
    ListMusic,
    Mail,
    Settings,
    Star,
    Users,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import React, { Suspense, useState } from "react";
import { ChangePhotoDialog } from "./change-photo-dialog";
import { CoverPhotoEditor } from "./cover-photo-editor";

// Mock data for demonstration - Regular user profile
const mockUserData = {
  sarahmusic: {
    userId: "user789",
    username: "sarahmusic",
    displayName: "Sarah Johnson",
    bio: "Music enthusiast and playlist curator. Always discovering new sounds and sharing great music.",
    avatarUrl: "/smiling-woman-headphones.png",
    coverUrl: "/abstract-music-purple.png",
    isArtist: false,
    isCurrentUser: true,
    joinDate: "August 2022",
    location: "Chicago, IL",
    website: "https://playlist-curator.com",
    stats: {
      followers: 128,
      following: 342,
      playlists: 18,
      likes: 876,
      listenTime: 1240, // in hours
    },
    score: 62,
    accountAge: 245,
    factors: {
      comments: {
        count: 87,
        likes: 156,
        reports: 0,
      },
      content: {
        tracks: 0,
        playlists: 18,
      },
      community: {
        followers: 128,
        following: 342,
        shares: 45,
      },
      moderation: {
        validReports: 12,
        warnings: 0,
      },
    },
    history: [
      { date: "2022-08-15", score: 20, change: 0, reason: "Initial score" },
      { date: "2022-09-20", score: 25, change: 5, reason: "Regular activity" },
      {
        date: "2022-11-05",
        score: 35,
        change: 10,
        reason: "Created popular playlists",
      },
      {
        date: "2023-01-12",
        score: 45,
        change: 10,
        reason: "Helpful community engagement",
      },
      {
        date: "2023-03-08",
        score: 55,
        change: 10,
        reason: "Consistent positive interactions",
      },
      {
        date: "2023-05-22",
        score: 62,
        change: 7,
        reason: "Accurate content reporting",
      },
    ],
    topGenres: [
      { name: "Indie Pop", percentage: 35 },
      { name: "Alternative R&B", percentage: 25 },
      { name: "Electronic", percentage: 20 },
      { name: "Hip Hop", percentage: 15 },
      { name: "Jazz", percentage: 5 },
    ],
    recentlyPlayed: [
      {
        id: "track1",
        title: "Midnight City",
        artist: "M83",
        coverUrl: "/track-cover-art.png",
        playedAt: "2 hours ago",
      },
      {
        id: "track2",
        title: "Redbone",
        artist: "Childish Gambino",
        coverUrl: "/track-cover-2.png",
        playedAt: "Yesterday",
      },
      {
        id: "track3",
        title: "Motion",
        artist: "Electronic Artist",
        coverUrl: "/track-cover-3.png",
        playedAt: "2 days ago",
      },
    ],
    playlists: [
      {
        id: "playlist1",
        title: "Chill Vibes 2023",
        coverUrl: "/track-cover-4.png",
        trackCount: 32,
        plays: 2450,
        likes: 187,
        date: "2 weeks ago",
      },
      {
        id: "playlist2",
        title: "Morning Commute",
        coverUrl: "/track-cover-2.png",
        trackCount: 24,
        plays: 1870,
        likes: 124,
        date: "1 month ago",
      },
      {
        id: "playlist3",
        title: "Weekend Party Mix",
        coverUrl: "/track-cover-3.png",
        trackCount: 18,
        plays: 3240,
        likes: 256,
        date: "2 months ago",
      },
    ],
    followedArtists: [
      {
        id: "artist1",
        name: "Electronic Producer",
        avatarUrl: "/artist-avatar.png",
        isVerified: true,
      },
      {
        id: "artist2",
        name: "Indie Band",
        avatarUrl: "/artist-profile.png",
        isVerified: true,
      },
      {
        id: "artist3",
        name: "Hip Hop Artist",
        avatarUrl: "/hip-hop-artist.png",
        isVerified: false,
      },
    ],
    recentActivity: [
      {
        type: "playlist",
        content: "Created a new playlist: Chill Vibes 2023",
        date: "2 weeks ago",
      },
      {
        type: "like",
        content: "Liked 8 tracks from Electronic Producer",
        date: "3 weeks ago",
      },
      {
        type: "follow",
        content: "Started following Hip Hop Artist",
        date: "1 month ago",
      },
      {
        type: "comment",
        content: "Commented on Midnight City by M83",
        date: "1 month ago",
      },
    ],
  },
  musicfan42: {
    userId: "user456",
    username: "musicfan42",
    displayName: "Alex Thompson",
    bio: "Passionate about discovering new music and sharing great finds. Always on the lookout for hidden gems across all genres.",
    avatarUrl: "/young-man-headphones.png",
    coverUrl: "/colorful-sound-waves.png",
    isArtist: false,
    isCurrentUser: false,
    joinDate: "March 2021",
    location: "Seattle, WA",
    website: "",
    stats: {
      followers: 87,
      following: 215,
      playlists: 24,
      likes: 1243,
      listenTime: 2180, // in hours
    },
    score: 78,
    accountAge: 420,
    factors: {
      comments: {
        count: 156,
        likes: 287,
        reports: 1,
      },
      content: {
        tracks: 0,
        playlists: 24,
      },
      community: {
        followers: 87,
        following: 215,
        shares: 68,
      },
      moderation: {
        validReports: 23,
        warnings: 0,
      },
    },
    history: [
      { date: "2021-03-10", score: 20, change: 0, reason: "Initial score" },
      { date: "2021-05-15", score: 30, change: 10, reason: "Regular activity" },
      {
        date: "2021-08-22",
        score: 45,
        change: 15,
        reason: "Created popular playlists",
      },
      {
        date: "2021-12-30",
        score: 55,
        change: 10,
        reason: "Consistent positive engagement",
      },
      {
        date: "2022-04-12",
        score: 65,
        change: 10,
        reason: "Helpful community reports",
      },
      {
        date: "2022-09-25",
        score: 75,
        change: 10,
        reason: "Reached 1000+ likes",
      },
      {
        date: "2023-01-18",
        score: 78,
        change: 3,
        reason: "Continued positive contributions",
      },
    ],
    topGenres: [
      { name: "Alternative Rock", percentage: 30 },
      { name: "Indie Folk", percentage: 25 },
      { name: "Classic Hip Hop", percentage: 20 },
      { name: "Jazz Fusion", percentage: 15 },
      { name: "Ambient", percentage: 10 },
    ],
    recentlyPlayed: [
      {
        id: "track1",
        title: "Everlong",
        artist: "Foo Fighters",
        coverUrl: "/track-cover-3.png",
        playedAt: "5 hours ago",
      },
      {
        id: "track2",
        title: "Skinny Love",
        artist: "Bon Iver",
        coverUrl: "/track-cover-2.png",
        playedAt: "Yesterday",
      },
      {
        id: "track3",
        title: "Alright",
        artist: "Kendrick Lamar",
        coverUrl: "/track-cover-art.png",
        playedAt: "3 days ago",
      },
    ],
    playlists: [
      {
        id: "playlist1",
        title: "Indie Discoveries 2023",
        coverUrl: "/track-cover-2.png",
        trackCount: 45,
        plays: 5240,
        likes: 342,
        date: "1 month ago",
      },
      {
        id: "playlist2",
        title: "Rainy Day Acoustics",
        coverUrl: "/track-cover-4.png",
        trackCount: 28,
        plays: 3870,
        likes: 256,
        date: "3 months ago",
      },
      {
        id: "playlist3",
        title: "Classic Hip Hop Essentials",
        coverUrl: "/track-cover-art.png",
        trackCount: 32,
        plays: 4120,
        likes: 287,
        date: "4 months ago",
      },
    ],
    followedArtists: [
      {
        id: "artist1",
        name: "Indie Band",
        avatarUrl: "/artist-profile.png",
        isVerified: true,
      },
      {
        id: "artist2",
        name: "Folk Singer",
        avatarUrl: "/folk-singer-guitar.png",
        isVerified: false,
      },
      {
        id: "artist3",
        name: "Hip Hop Producer",
        avatarUrl: "/hip-hop-producer.png",
        isVerified: true,
      },
    ],
    recentActivity: [
      {
        type: "playlist",
        content: "Updated playlist: Indie Discoveries 2023",
        date: "1 week ago",
      },
      {
        type: "like",
        content: "Liked 12 tracks from Indie Band",
        date: "2 weeks ago",
      },
      {
        type: "follow",
        content: "Started following Folk Singer",
        date: "3 weeks ago",
      },
      {
        type: "comment",
        content: "Commented on Skinny Love by Bon Iver",
        date: "1 month ago",
      },
    ],
  },
};

export default function UserProfilePage() {
  const userData = mockUserData["sarahmusic"]; // Fallback to default user
  const [isPhotoDialogOpen, setIsPhotoDialogOpen] = useState(false);
  const [profilePhoto, setProfilePhoto] = useState(userData.avatarUrl);
  const [isEditingCover, setIsEditingCover] = useState(false);
  const [coverPosition, setCoverPosition] = useState(50); // Default center position
  const [coverPhoto, setCoverPhoto] = useState(userData.coverUrl);
  const [isHoveringCover, setIsHoveringCover] = useState(false);

  const handleUpdateProfilePhoto = (newPhotoUrl: string) => {
    setProfilePhoto(newPhotoUrl);
    // In a real app, you would save this to your backend
    console.log("Profile photo updated:", newPhotoUrl);
  };

  const handleUpdateCover = (position: number, newImageUrl?: string) => {
    setCoverPosition(position);

    if (newImageUrl) {
      setCoverPhoto(newImageUrl);
      console.log("New cover photo uploaded and position updated:", position);
    } else {
      console.log("Cover position updated:", position);
    }

    setIsEditingCover(false);
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Cover Image */}
      {isEditingCover ? (
        <CoverPhotoEditor
          coverUrl={coverPhoto}
          onSave={handleUpdateCover}
          onCancel={() => setIsEditingCover(false)}
        />
      ) : (
        <div
          className="relative h-64 w-full bg-gradient-to-r from-purple-700 to-purple-900 cursor-default"
          onMouseEnter={() =>
            userData.isCurrentUser && setIsHoveringCover(true)
          }
          onMouseLeave={() => setIsHoveringCover(false)}
          onClick={() => userData.isCurrentUser && setIsEditingCover(true)}
        >
          {coverPhoto && (
            <>
              <Image
                src={coverPhoto || "/placeholder.svg"}
                alt={`${userData.displayName}'s cover`}
                fill
                className="object-cover opacity-60"
                style={{ objectPosition: `center ${coverPosition}%` }}
                priority
              />

              {/* Hover overlay for cover photo */}
              {userData.isCurrentUser && (
                <div
                  className={`absolute inset-0 bg-black bg-opacity-40 flex items-center justify-center transition-opacity duration-200 ${
                    isHoveringCover ? "opacity-100" : "opacity-0"
                  }`}
                >
                  <div className="text-white text-center">
                    <Edit className="h-10 w-10 mx-auto mb-2" />
                    <p className="text-lg font-medium">Edit Cover Photo</p>
                  </div>
                </div>
              )}

              {/* Edit button (still keeping this for non-hover interaction) */}
              {userData.isCurrentUser && (
                <div className="absolute inset-0 flex items-end justify-end p-4 z-10">
                  <button
                    onClick={(e) => {
                      e.stopPropagation(); // Prevent triggering the parent onClick
                      setIsEditingCover(true);
                    }}
                    className="flex items-center gap-1 rounded-md bg-black bg-opacity-50 px-3 py-2 text-sm text-white transition-colors hover:bg-opacity-70 focus:outline-none focus:ring-2 focus:ring-white focus:ring-opacity-50"
                    aria-label="Edit cover photo"
                  >
                    <Edit className="h-4 w-4" />
                    <span>Edit Cover</span>
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      )}

      {/* Profile Header */}
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="relative -mt-24 mb-8 flex flex-col items-center sm:flex-row sm:items-end">
          {/* Avatar with Camera Icon */}
          <div className="relative h-36 w-36 group">
            <div className="relative h-full w-full overflow-hidden rounded-full border-4 border-white bg-white shadow-lg">
              <Image
                src={profilePhoto || "/placeholder.svg"}
                alt={userData.displayName}
                fill
                className="object-cover"
              />
            </div>

            {userData.isCurrentUser && (
              <Button
                onClick={() => setIsPhotoDialogOpen(true)}
                className="absolute bottom-2 right-2 h-8 w-8 rounded-full shadow-md flex items-center justify-center cursor-pointer transition-transform hover:scale-110 focus:outline-none focus:ring-2 focus:ring-purple-500"
                aria-label="Change profile photo"
                variant={"outline"}
                size={"icon"}
              >
                <Camera className="h-5 w-5 text-gray-700" />
              </Button>
            )}
          </div>

          {/* Profile Info */}
          <div className="mt-4 flex flex-1 flex-col items-center text-center sm:ml-6 sm:items-start sm:text-left">
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold text-gray-900">
                {userData.displayName}
              </h1>
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
            icon={<ListMusic className="h-5 w-5 text-purple-500" />}
            label="Playlists"
            value={userData.stats.playlists.toLocaleString()}
          />
          <StatCard
            icon={<Heart className="h-5 w-5 text-purple-500" />}
            label="Likes"
            value={userData.stats.likes.toLocaleString()}
          />
          <StatCard
            icon={<Headphones className="h-5 w-5 text-purple-500" />}
            label="Listen Time"
            value={formatListenTime(userData.stats.listenTime)}
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

            {/* Top Genres */}
            <Card className="mt-8">
              <CardContent className="pt-6">
                <h3 className="mb-4 flex items-center gap-2 text-lg font-semibold">
                  <BarChart3 className="h-5 w-5 text-purple-500" />
                  Top Genres
                </h3>
                <div className="space-y-4">
                  {userData.topGenres.map((genre, index) => (
                    <div key={index} className="space-y-1">
                      <div className="flex items-center justify-between">
                        <span className="text-sm font-medium">
                          {genre.name}
                        </span>
                        <span className="text-xs text-gray-500">
                          {genre.percentage}%
                        </span>
                      </div>
                      <div className="h-2 w-full overflow-hidden rounded-full bg-gray-100">
                        <div
                          className="h-full rounded-full bg-purple-500"
                          style={{ width: `${genre.percentage}%` }}
                        ></div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

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
            <Tabs defaultValue="playlists" className="w-full">
              <TabsList className="mb-6 grid w-full grid-cols-4">
                <TabsTrigger
                  value="playlists"
                  className="flex items-center gap-1"
                >
                  <ListMusic className="h-4 w-4" />
                  <span>Playlists</span>
                </TabsTrigger>
                <TabsTrigger value="recent" className="flex items-center gap-1">
                  <History className="h-4 w-4" />
                  <span>Recently Played</span>
                </TabsTrigger>
                <TabsTrigger
                  value="artists"
                  className="flex items-center gap-1"
                >
                  <Star className="h-4 w-4" />
                  <span>Followed Artists</span>
                </TabsTrigger>
                <TabsTrigger value="likes" className="flex items-center gap-1">
                  <Heart className="h-4 w-4" />
                  <span>Liked Tracks</span>
                </TabsTrigger>
              </TabsList>

              <TabsContent value="playlists" className="space-y-4">
                <Suspense fallback={<div>Loading playlists...</div>}>
                  {userData.playlists.map((playlist) => (
                    <PlaylistItem key={playlist.id} playlist={playlist} />
                  ))}
                </Suspense>
              </TabsContent>

              <TabsContent value="recent" className="space-y-4">
                <Suspense fallback={<div>Loading recently played...</div>}>
                  {userData.recentlyPlayed.map((track, index) => (
                    <RecentlyPlayedItem key={index} track={track} />
                  ))}
                </Suspense>
              </TabsContent>

              <TabsContent value="artists" className="space-y-4">
                <Suspense fallback={<div>Loading artists...</div>}>
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-3">
                    {userData.followedArtists.map((artist, index) => (
                      <ArtistCard key={index} artist={artist} />
                    ))}
                  </div>
                </Suspense>
              </TabsContent>

              <TabsContent value="likes" className="space-y-4">
                <div className="rounded-lg border border-gray-200 bg-gray-50 p-8 text-center">
                  <Heart className="mx-auto h-10 w-10 text-gray-400" />
                  <h3 className="mt-2 text-lg font-medium">
                    Liked tracks will appear here
                  </h3>
                  <p className="mt-1 text-gray-500">
                    When you like tracks, they'll be saved here for easy access.
                  </p>
                </div>
              </TabsContent>
            </Tabs>
          </div>
        </div>
      </div>
      {/* Photo Change Dialog */}
      {userData.isCurrentUser && (
        <ChangePhotoDialog
          isOpen={isPhotoDialogOpen}
          onClose={() => setIsPhotoDialogOpen(false)}
          onSave={handleUpdateProfilePhoto}
          currentImage={profilePhoto}
        />
      )}
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
      </div>
    </div>
  );
}

interface RecentlyPlayedItemProps {
  track: {
    id: string;
    title: string;
    artist: string;
    coverUrl: string;
    playedAt: string;
  };
}

function RecentlyPlayedItem({ track }: RecentlyPlayedItemProps) {
  return (
    <div className="flex items-center gap-4 rounded-lg border border-gray-200 p-3 transition-colors hover:bg-gray-50">
      <div className="relative h-12 w-12 flex-shrink-0 overflow-hidden rounded-md">
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
        <p className="text-sm text-gray-500">{track.artist}</p>
      </div>
      <div className="text-xs text-gray-400">{track.playedAt}</div>
    </div>
  );
}

interface ArtistCardProps {
  artist: {
    id: string;
    name: string;
    avatarUrl: string;
    isVerified: boolean;
  };
}

function ArtistCard({ artist }: ArtistCardProps) {
  return (
    <Link
      href={`/artist/${artist.id}`}
      className="flex flex-col items-center rounded-lg border border-gray-200 p-4 text-center transition-colors hover:bg-gray-50"
    >
      <div className="relative h-24 w-24 overflow-hidden rounded-full">
        <Image
          src={artist.avatarUrl || "/placeholder.svg"}
          alt={artist.name}
          fill
          className="object-cover"
        />
      </div>
      <div className="mt-3">
        <p className="font-medium">{artist.name}</p>
        {artist.isVerified && (
          <div className="mt-1 inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800">
            <svg
              className="-ml-0.5 mr-1.5 h-3 w-3 text-blue-500"
              fill="currentColor"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clipRule="evenodd"
              ></path>
            </svg>
            Verified
          </div>
        )}
      </div>
    </Link>
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

// Helper function to format listen time (e.g., 1240 hours -> 51 days)
function formatListenTime(hours: number): string {
  if (hours >= 24) {
    const days = Math.floor(hours / 24);
    return `${days} day${days !== 1 ? "s" : ""}`;
  }
  return `${hours} hr${hours !== 1 ? "s" : ""}`;
}
