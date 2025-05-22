"use client";

import { useState } from "react";
import { Search } from "lucide-react";

import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ArtistCard } from "@/components/artist-card";

export default function SearchPage() {
  const [searchQuery, setSearchQuery] = useState("");
  const [activeTab, setActiveTab] = useState("artists");

  // Sample artists data
  const artists = [
    {
      id: "1",
      name: "Jane Doe",
      slug: "jane-doe",
      imageUrl: "/artist-profile.png",
      followers: 24500,
      isVerified: true,
      primaryGenre: "Electronic",
    },
    {
      id: "2",
      name: "John Smith",
      slug: "john-smith",
      imageUrl: "/diverse-musician-ensemble.png",
      followers: 18300,
      isVerified: true,
      primaryGenre: "Rock",
    },
    {
      id: "3",
      name: "Alex Johnson",
      slug: "alex-johnson",
      imageUrl: "/dj-at-turntables.png",
      followers: 32700,
      isVerified: false,
      primaryGenre: "Hip Hop",
    },
    {
      id: "4",
      name: "Maria Garcia",
      slug: "maria-garcia",
      imageUrl: "/singer-on-stage.png",
      followers: 15600,
      isVerified: true,
      primaryGenre: "Pop",
    },
    {
      id: "5",
      name: "David Kim",
      slug: "david-kim",
      imageUrl: "/guitarist.png",
      followers: 9800,
      isVerified: false,
      primaryGenre: "Jazz",
    },
    {
      id: "6",
      name: "Sarah Williams",
      slug: "sarah-williams",
      imageUrl: "/powerful-vocalist.png",
      followers: 28400,
      isVerified: true,
      primaryGenre: "R&B",
    },
  ];

  // Filter artists based on search query
  const filteredArtists = artists.filter(
    (artist) =>
      artist.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      artist.primaryGenre.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="flex flex-col gap-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Discover</h1>
        <p className="text-muted-foreground">
          Find new artists, tracks, and playlists
        </p>
      </div>

      <div className="relative">
        <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
        <Input
          type="search"
          placeholder="Search for artists, tracks, or genres..."
          className="pl-10"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList>
          <TabsTrigger value="artists">Artists</TabsTrigger>
          <TabsTrigger value="tracks">Tracks</TabsTrigger>
          <TabsTrigger value="playlists">Playlists</TabsTrigger>
          <TabsTrigger value="genres">Genres</TabsTrigger>
        </TabsList>

        <TabsContent value="artists" className="mt-6">
          <div className="grid gap-6 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-6">
            {filteredArtists.map((artist) => (
              <ArtistCard key={artist.id} artist={artist} />
            ))}
          </div>

          {filteredArtists.length === 0 && (
            <div className="flex h-40 items-center justify-center rounded-md border">
              <p className="text-muted-foreground">
                No artists found matching your search.
              </p>
            </div>
          )}
        </TabsContent>

        {/* Other tab contents would go here */}
        <TabsContent value="tracks">
          <div className="flex h-40 items-center justify-center rounded-md border">
            <p className="text-muted-foreground">
              Track search results would appear here.
            </p>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
