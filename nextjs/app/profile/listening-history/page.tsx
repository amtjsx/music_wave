import {
  ChevronLeft,
  Clock,
  Share2,
  Download,
  Calendar,
  BarChart3,
} from "lucide-react";
import Link from "next/link";
import Image from "next/image";

import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

// Mock data - would be fetched from API in a real implementation
const mockListeningData = {
  username: "melodylover",
  displayName: "Melody Lover",
  recentTracks: [
    {
      id: "track1",
      title: "Midnight Serenade",
      artist: "Luna Eclipse",
      artistId: "artist1",
      albumTitle: "Nocturnal Whispers",
      albumId: "album1",
      coverArt: "/track-cover-art.png",
      playedAt: "2023-05-21T14:32:00Z",
      duration: 237, // in seconds
    },
    {
      id: "track2",
      title: "Electric Dreams",
      artist: "Neon Pulse",
      artistId: "artist2",
      albumTitle: "Digital Horizons",
      albumId: "album2",
      coverArt: "/track-cover-2.png",
      playedAt: "2023-05-21T14:28:00Z",
      duration: 194,
    },
    {
      id: "track3",
      title: "Ocean Waves",
      artist: "Coastal Echoes",
      artistId: "artist3",
      albumTitle: "Tidal Memories",
      albumId: "album3",
      coverArt: "/track-cover-3.png",
      playedAt: "2023-05-21T13:45:00Z",
      duration: 312,
    },
    {
      id: "track4",
      title: "Mountain High",
      artist: "Alpine Sounds",
      artistId: "artist4",
      albumTitle: "Peak Experiences",
      albumId: "album4",
      coverArt: "/track-cover-4.png",
      playedAt: "2023-05-21T13:12:00Z",
      duration: 274,
    },
    {
      id: "track5",
      title: "Urban Jungle",
      artist: "City Beats",
      artistId: "artist5",
      albumTitle: "Metropolitan",
      albumId: "album5",
      coverArt: "/track-cover-art.png",
      playedAt: "2023-05-21T12:30:00Z",
      duration: 185,
    },
    {
      id: "track6",
      title: "Desert Wind",
      artist: "Sahara Sounds",
      artistId: "artist6",
      albumTitle: "Oasis Dreams",
      albumId: "album6",
      coverArt: "/track-cover-2.png",
      playedAt: "2023-05-21T11:45:00Z",
      duration: 263,
    },
    {
      id: "track7",
      title: "Rainy Day",
      artist: "Weather Patterns",
      artistId: "artist7",
      albumTitle: "Seasonal Moods",
      albumId: "album7",
      coverArt: "/track-cover-3.png",
      playedAt: "2023-05-21T10:20:00Z",
      duration: 198,
    },
    {
      id: "track8",
      title: "Sunrise Melody",
      artist: "Morning Glory",
      artistId: "artist8",
      albumTitle: "Dawn Chorus",
      albumId: "album8",
      coverArt: "/track-cover-4.png",
      playedAt: "2023-05-21T09:15:00Z",
      duration: 245,
    },
    {
      id: "track9",
      title: "Starlight Sonata",
      artist: "Cosmic Harmony",
      artistId: "artist9",
      albumTitle: "Celestial Bodies",
      albumId: "album9",
      coverArt: "/track-cover-art.png",
      playedAt: "2023-05-20T22:40:00Z",
      duration: 327,
    },
    {
      id: "track10",
      title: "Forest Whispers",
      artist: "Woodland Spirits",
      artistId: "artist10",
      albumTitle: "Ancient Trees",
      albumId: "album10",
      coverArt: "/track-cover-2.png",
      playedAt: "2023-05-20T21:30:00Z",
      duration: 286,
    },
  ],
  topGenres: [
    { name: "Indie Pop", percentage: 32 },
    { name: "Electronic", percentage: 24 },
    { name: "Alternative", percentage: 18 },
    { name: "Ambient", percentage: 14 },
    { name: "Classical", percentage: 12 },
  ],
  listeningPatterns: {
    mornings: 15, // percentage
    afternoons: 25,
    evenings: 45,
    nights: 15,
  },
  weeklyActivity: [
    { day: "Monday", hours: 1.2 },
    { day: "Tuesday", hours: 2.5 },
    { day: "Wednesday", hours: 1.8 },
    { day: "Thursday", hours: 3.2 },
    { day: "Friday", hours: 4.5 },
    { day: "Saturday", hours: 5.7 },
    { day: "Sunday", hours: 3.9 },
  ],
  monthlyListening: [
    { month: "Jan", hours: 42 },
    { month: "Feb", hours: 38 },
    { month: "Mar", hours: 45 },
    { month: "Apr", hours: 52 },
    { month: "May", hours: 48 },
    { month: "Jun", hours: 0 },
    { month: "Jul", hours: 0 },
    { month: "Aug", hours: 0 },
    { month: "Sep", hours: 0 },
    { month: "Oct", hours: 0 },
    { month: "Nov", hours: 0 },
    { month: "Dec", hours: 0 },
  ],
  mostPlayedArtists: [
    { name: "Luna Eclipse", plays: 47, image: "/artist-avatar.png" },
    { name: "Neon Pulse", plays: 35, image: "/artist-avatar.png" },
    { name: "Coastal Echoes", plays: 29, image: "/artist-avatar.png" },
    { name: "Alpine Sounds", plays: 23, image: "/artist-avatar.png" },
    { name: "City Beats", plays: 18, image: "/artist-avatar.png" },
  ],
};

// Helper function to format date
function formatDate(dateString: string) {
  const date = new Date(dateString);
  return new Intl.DateTimeFormat("en-US", {
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    hour12: true,
  }).format(date);
}

// Helper function to format duration
function formatDuration(seconds: number) {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, "0")}`;
}

export default function ListeningHistoryPage({
  params,
}: {
  params: { username: string };
}) {
  // In a real implementation, we would fetch the user's listening history based on the username
  const userData = mockListeningData;

  return (
    <div className="container mx-auto px-4 py-6">
      <div className="flex items-center mb-6">
        <Link href={`/profile/${params.username}`} className="mr-2">
          <Button variant="ghost" size="sm">
            <ChevronLeft className="h-4 w-4 mr-1" />
            Back to Profile
          </Button>
        </Link>
        <h1 className="text-2xl font-bold flex-1">Listening History</h1>
        <div className="flex space-x-2">
          <Button variant="outline" size="sm">
            <Share2 className="h-4 w-4 mr-1" />
            Share
          </Button>
          <Button variant="outline" size="sm">
            <Download className="h-4 w-4 mr-1" />
            Export
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium">Total Listening Time</h3>
              <Clock className="h-5 w-5 text-purple-500" />
            </div>
            <div className="text-3xl font-bold text-purple-600">225 hours</div>
            <p className="text-sm text-gray-500 mt-1">Last 6 months</p>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium">Tracks Played</h3>
              <BarChart3 className="h-5 w-5 text-purple-500" />
            </div>
            <div className="text-3xl font-bold text-purple-600">1,842</div>
            <p className="text-sm text-gray-500 mt-1">Last 6 months</p>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-medium">Unique Artists</h3>
              <Calendar className="h-5 w-5 text-purple-500" />
            </div>
            <div className="text-3xl font-bold text-purple-600">247</div>
            <p className="text-sm text-gray-500 mt-1">Last 6 months</p>
          </CardContent>
        </Card>
      </div>

      <div className="flex justify-between items-center mb-4">
        <h2 className="text-xl font-semibold">Timeline View</h2>
        <div className="flex items-center space-x-4">
          <Select defaultValue="week">
            <SelectTrigger className="w-[150px]">
              <SelectValue placeholder="Select period" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="day">Last 24 Hours</SelectItem>
              <SelectItem value="week">Last 7 Days</SelectItem>
              <SelectItem value="month">Last 30 Days</SelectItem>
              <SelectItem value="year">Last 12 Months</SelectItem>
              <SelectItem value="all">All Time</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <Tabs defaultValue="timeline" className="mb-8">
        <TabsList className="mb-4">
          <TabsTrigger value="timeline">Timeline</TabsTrigger>
          <TabsTrigger value="patterns">Listening Patterns</TabsTrigger>
          <TabsTrigger value="artists">Top Artists</TabsTrigger>
          <TabsTrigger value="genres">Genre Breakdown</TabsTrigger>
        </TabsList>

        <TabsContent value="timeline">
          <Card>
            <CardContent className="pt-6">
              {/* Timeline visualization */}
              <div className="relative">
                {/* Date markers */}
                <div className="flex justify-between mb-2 text-sm text-gray-500">
                  <div>May 20</div>
                  <div>May 21</div>
                </div>

                {/* Timeline line */}
                <div className="h-1 bg-gray-200 w-full mb-6 rounded-full">
                  <div className="h-1 bg-purple-500 w-[75%] rounded-full"></div>
                </div>

                {/* Timeline events */}
                <div className="space-y-6">
                  {userData.recentTracks.map((track, index) => (
                    <div key={track.id} className="flex items-start">
                      <div className="relative mr-4 flex-shrink-0">
                        <Image
                          src={track.coverArt || "/placeholder.svg"}
                          alt={track.title}
                          width={60}
                          height={60}
                          className="rounded-md"
                        />
                        <div className="absolute -top-2 -right-2 bg-purple-600 text-white text-xs rounded-full w-6 h-6 flex items-center justify-center">
                          {index + 1}
                        </div>
                      </div>
                      <div className="flex-1">
                        <div className="flex justify-between">
                          <div>
                            <h4 className="font-medium">{track.title}</h4>
                            <p className="text-sm text-gray-600">
                              {track.artist} • {track.albumTitle}
                            </p>
                          </div>
                          <div className="text-right">
                            <span className="text-sm text-gray-500">
                              {formatDate(track.playedAt)}
                            </span>
                            <p className="text-xs text-gray-400">
                              {formatDuration(track.duration)}
                            </p>
                          </div>
                        </div>
                        <div className="mt-1 flex items-center">
                          <div className="h-1 bg-gray-200 flex-1 rounded-full">
                            <div
                              className="h-1 bg-purple-500 rounded-full"
                              style={{ width: `${Math.random() * 100}%` }}
                            ></div>
                          </div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Load more button */}
                <div className="mt-6 text-center">
                  <Button variant="outline">Load More History</Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="patterns">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardContent className="pt-6">
                <h3 className="text-lg font-medium mb-4">Time of Day</h3>
                <div className="space-y-4">
                  <div>
                    <div className="flex justify-between mb-1">
                      <span className="text-sm">Mornings (6am-12pm)</span>
                      <span className="text-sm font-medium">
                        {userData.listeningPatterns.mornings}%
                      </span>
                    </div>
                    <div className="h-2 bg-gray-200 rounded-full">
                      <div
                        className="h-2 bg-purple-300 rounded-full"
                        style={{
                          width: `${userData.listeningPatterns.mornings}%`,
                        }}
                      ></div>
                    </div>
                  </div>
                  <div>
                    <div className="flex justify-between mb-1">
                      <span className="text-sm">Afternoons (12pm-6pm)</span>
                      <span className="text-sm font-medium">
                        {userData.listeningPatterns.afternoons}%
                      </span>
                    </div>
                    <div className="h-2 bg-gray-200 rounded-full">
                      <div
                        className="h-2 bg-purple-400 rounded-full"
                        style={{
                          width: `${userData.listeningPatterns.afternoons}%`,
                        }}
                      ></div>
                    </div>
                  </div>
                  <div>
                    <div className="flex justify-between mb-1">
                      <span className="text-sm">Evenings (6pm-12am)</span>
                      <span className="text-sm font-medium">
                        {userData.listeningPatterns.evenings}%
                      </span>
                    </div>
                    <div className="h-2 bg-gray-200 rounded-full">
                      <div
                        className="h-2 bg-purple-600 rounded-full"
                        style={{
                          width: `${userData.listeningPatterns.evenings}%`,
                        }}
                      ></div>
                    </div>
                  </div>
                  <div>
                    <div className="flex justify-between mb-1">
                      <span className="text-sm">Nights (12am-6am)</span>
                      <span className="text-sm font-medium">
                        {userData.listeningPatterns.nights}%
                      </span>
                    </div>
                    <div className="h-2 bg-gray-200 rounded-full">
                      <div
                        className="h-2 bg-purple-800 rounded-full"
                        style={{
                          width: `${userData.listeningPatterns.nights}%`,
                        }}
                      ></div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <h3 className="text-lg font-medium mb-4">Weekly Activity</h3>
                <div className="h-48 flex items-end justify-between">
                  {userData.weeklyActivity.map((day) => (
                    <div key={day.day} className="flex flex-col items-center">
                      <div
                        className="bg-purple-500 w-8 rounded-t-md"
                        style={{ height: `${day.hours * 12}px` }}
                      ></div>
                      <span className="text-xs mt-2">
                        {day.day.substring(0, 3)}
                      </span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card className="md:col-span-2">
              <CardContent className="pt-6">
                <h3 className="text-lg font-medium mb-4">Monthly Listening</h3>
                <div className="h-48 flex items-end justify-between">
                  {userData.monthlyListening.map((month) => (
                    <div
                      key={month.month}
                      className="flex flex-col items-center"
                    >
                      <div
                        className="bg-purple-500 w-6 rounded-t-md"
                        style={{ height: `${month.hours * 0.8}px` }}
                      ></div>
                      <span className="text-xs mt-2">{month.month}</span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="artists">
          <Card>
            <CardContent className="pt-6">
              <h3 className="text-lg font-medium mb-4">Most Played Artists</h3>
              <div className="space-y-4">
                {userData.mostPlayedArtists.map((artist, index) => (
                  <div key={artist.name} className="flex items-center">
                    <div className="mr-4 text-lg font-bold text-gray-400 w-6 text-center">
                      {index + 1}
                    </div>
                    <Image
                      src={artist.image || "/placeholder.svg"}
                      alt={artist.name}
                      width={50}
                      height={50}
                      className="rounded-full mr-4"
                    />
                    <div className="flex-1">
                      <h4 className="font-medium">{artist.name}</h4>
                      <div className="flex items-center">
                        <div className="h-1 bg-gray-200 flex-1 rounded-full mr-2">
                          <div
                            className="h-1 bg-purple-500 rounded-full"
                            style={{
                              width: `${
                                (artist.plays /
                                  userData.mostPlayedArtists[0].plays) *
                                100
                              }%`,
                            }}
                          ></div>
                        </div>
                        <span className="text-sm text-gray-600">
                          {artist.plays} plays
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="genres">
          <Card>
            <CardContent className="pt-6">
              <h3 className="text-lg font-medium mb-4">Genre Breakdown</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="relative h-64">
                  {/* This would be a pie chart in a real implementation */}
                  <div className="absolute inset-0 flex items-center justify-center">
                    <div className="w-48 h-48 rounded-full bg-gray-200 flex items-center justify-center">
                      <div className="w-36 h-36 rounded-full bg-white flex items-center justify-center">
                        <span className="text-sm font-medium">
                          Top 5 Genres
                        </span>
                      </div>
                    </div>
                    {/* Pie chart segments would go here */}
                    <div className="absolute top-0 left-1/2 -translate-x-1/2 w-24 h-24 bg-purple-600 rounded-tl-full rounded-tr-full transform origin-bottom rotate-0"></div>
                    <div className="absolute top-0 left-1/2 -translate-x-1/2 w-24 h-24 bg-purple-400 rounded-tl-full rounded-tr-full transform origin-bottom rotate-[115deg]"></div>
                    <div className="absolute top-0 left-1/2 -translate-x-1/2 w-24 h-24 bg-purple-300 rounded-tl-full rounded-tr-full transform origin-bottom rotate-[180deg]"></div>
                    <div className="absolute top-0 left-1/2 -translate-x-1/2 w-24 h-24 bg-purple-200 rounded-tl-full rounded-tr-full transform origin-bottom rotate-[245deg]"></div>
                    <div className="absolute top-0 left-1/2 -translate-x-1/2 w-24 h-24 bg-purple-100 rounded-tl-full rounded-tr-full transform origin-bottom rotate-[295deg]"></div>
                  </div>
                </div>

                <div className="space-y-4">
                  {userData.topGenres.map((genre) => (
                    <div key={genre.name}>
                      <div className="flex justify-between mb-1">
                        <span className="text-sm">{genre.name}</span>
                        <span className="text-sm font-medium">
                          {genre.percentage}%
                        </span>
                      </div>
                      <div className="h-2 bg-gray-200 rounded-full">
                        <div
                          className={`h-2 rounded-full bg-purple-${
                            600 -
                            (genre.percentage > 30
                              ? 0
                              : genre.percentage > 20
                              ? 200
                              : genre.percentage > 15
                              ? 300
                              : 400)
                          }`}
                          style={{ width: `${genre.percentage}%` }}
                        ></div>
                      </div>
                    </div>
                  ))}
                  <div className="pt-4">
                    <Badge variant="outline" className="mr-2 mb-2">
                      Indie Rock
                    </Badge>
                    <Badge variant="outline" className="mr-2 mb-2">
                      Jazz
                    </Badge>
                    <Badge variant="outline" className="mr-2 mb-2">
                      Hip Hop
                    </Badge>
                    <Badge variant="outline" className="mr-2 mb-2">
                      R&B
                    </Badge>
                    <Badge variant="outline" className="mr-2 mb-2">
                      Folk
                    </Badge>
                    <Badge variant="outline" className="mr-2 mb-2">
                      +12 more
                    </Badge>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <div className="mb-8">
        <h2 className="text-xl font-semibold mb-4">Listening Insights</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Card>
            <CardContent className="pt-6">
              <h3 className="text-lg font-medium mb-2">
                Your Listening Personality
              </h3>
              <p className="text-gray-600 mb-4">
                Based on your listening patterns, you're an:
              </p>
              <div className="text-2xl font-bold text-purple-600 mb-2">
                Evening Explorer
              </div>
              <p className="text-gray-600">
                You discover new music regularly and tend to listen most during
                evening hours. Your diverse taste spans multiple genres with a
                focus on indie and electronic music.
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <h3 className="text-lg font-medium mb-2">Listening Streak</h3>
              <div className="flex items-center mb-4">
                <div className="text-3xl font-bold text-purple-600 mr-2">
                  42
                </div>
                <div className="text-gray-600">
                  days of consecutive listening
                </div>
              </div>
              <div className="flex space-x-1">
                {Array.from({ length: 14 }).map((_, i) => (
                  <div
                    key={i}
                    className={`h-6 w-2 rounded-sm ${
                      i < 12 ? "bg-purple-500" : "bg-gray-200"
                    }`}
                  ></div>
                ))}
              </div>
              <p className="text-sm text-gray-500 mt-2">
                Last two weeks (most recent on right)
              </p>
            </CardContent>
          </Card>
        </div>
      </div>

      <div>
        <h2 className="text-xl font-semibold mb-4">
          Recommendations Based on History
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="group">
              <div className="relative aspect-square mb-2 overflow-hidden rounded-md">
                <Image
                  src={`/track-cover-${
                    i % 2 === 0
                      ? "2"
                      : i % 3 === 0
                      ? "3"
                      : i % 4 === 0
                      ? "4"
                      : "art"
                  }.png`}
                  alt="Album cover"
                  fill
                  className="object-cover transition-transform group-hover:scale-105"
                />
                <div className="absolute inset-0 bg-black bg-opacity-40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                  <Button
                    size="sm"
                    variant="secondary"
                    className="rounded-full w-10 h-10 p-0"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                      className="w-5 h-5"
                    >
                      <path
                        fillRule="evenodd"
                        d="M4.5 5.653c0-1.426 1.529-2.33 2.779-1.643l11.54 6.348c1.295.712 1.295 2.573 0 3.285L7.28 19.991c-1.25.687-2.779-.217-2.779-1.643V5.653z"
                        clipRule="evenodd"
                      />
                    </svg>
                  </Button>
                </div>
              </div>
              <h4 className="font-medium text-sm truncate">
                Recommended Track {i}
              </h4>
              <p className="text-xs text-gray-500 truncate">
                Based on your history
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
