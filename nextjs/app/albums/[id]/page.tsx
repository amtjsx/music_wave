import Image from "next/image";
import Link from "next/link";
import type { Metadata } from "next";
import { AlbumHeader } from "./album-header";
import { TrackList } from "./track-list";
import { AlbumReviews } from "./album-reviews";
import { RelatedAlbums } from "./related-albums";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Separator } from "@/components/ui/separator";

// This would normally come from a database or API
const getAlbumById = (id: string) => {
  // Mock album data
  const album = {
    id,
    title: "Midnight Waves",
    artist: "Luna Echo",
    artistId: "luna-echo",
    coverUrl: "/album-cover-1.png",
    releaseDate: "2023-05-15",
    releaseYear: "2023",
    label: "Purple Records",
    genre: "Electronic",
    trackCount: 12,
    duration: "48:32",
    trustScore: 92,
    isVerified: true,
    description:
      "Midnight Waves is the breakthrough album from electronic artist Luna Echo. Featuring 12 tracks that blend ambient soundscapes with pulsing beats, this album takes listeners on a journey through nocturnal emotions and digital dreams. Produced during late-night sessions in Luna's home studio, the album captures the essence of those quiet hours when creativity peaks and inhibitions fade.",
    tracks: [
      {
        id: "t1",
        number: 1,
        title: "Digital Dawn",
        duration: "3:42",
        plays: 245678,
        isExplicit: false,
      },
      {
        id: "t2",
        number: 2,
        title: "Neon Pulse",
        duration: "4:15",
        plays: 198432,
        isExplicit: false,
      },
      {
        id: "t3",
        number: 3,
        title: "Midnight Synthesis",
        duration: "5:08",
        plays: 312567,
        isExplicit: false,
      },
      {
        id: "t4",
        number: 4,
        title: "Electric Dreams",
        duration: "3:56",
        plays: 176543,
        isExplicit: false,
      },
      {
        id: "t5",
        number: 5,
        title: "Lunar Phase",
        duration: "4:22",
        plays: 203456,
        isExplicit: false,
      },
      {
        id: "t6",
        number: 6,
        title: "Echo Chamber",
        duration: "3:48",
        plays: 167890,
        isExplicit: true,
      },
      {
        id: "t7",
        number: 7,
        title: "Ambient Waves",
        duration: "4:51",
        plays: 189234,
        isExplicit: false,
      },
      {
        id: "t8",
        number: 8,
        title: "Cybernetic",
        duration: "3:37",
        plays: 154321,
        isExplicit: false,
      },
      {
        id: "t9",
        number: 9,
        title: "Twilight Algorithm",
        duration: "4:03",
        plays: 178965,
        isExplicit: false,
      },
      {
        id: "t10",
        number: 10,
        title: "Digital Horizon",
        duration: "3:59",
        plays: 165432,
        isExplicit: false,
      },
      {
        id: "t11",
        number: 11,
        title: "Stellar Synthesis",
        duration: "4:27",
        plays: 187654,
        isExplicit: false,
      },
      {
        id: "t12",
        number: 12,
        title: "Dawn Sequence",
        duration: "2:24",
        plays: 143210,
        isExplicit: false,
      },
    ],
    credits: [
      { role: "Producer", name: "Luna Echo" },
      { role: "Mixing Engineer", name: "Alex Wavefront" },
      { role: "Mastering", name: "Clarity Studios" },
      { role: "Artwork", name: "Digital Visions Design" },
      { role: "Additional Programming", name: "Beat Architect" },
    ],
    reviews: [
      {
        id: "r1",
        user: {
          id: "u1",
          name: "ElectroFan",
          trustScore: 78,
          avatarUrl: "/abstract-geometric-shapes.png",
        },
        rating: 5,
        text: "Absolutely stunning album. The production quality is top-notch and the tracks flow together perfectly. 'Midnight Synthesis' is my favorite track - it's been on repeat for days!",
        date: "2023-05-20",
        likes: 34,
      },
      {
        id: "r2",
        user: {
          id: "u2",
          name: "MusicExplorer",
          trustScore: 85,
          avatarUrl: "/abstract-geometric-shapes.png",
        },
        rating: 4,
        text: "Great album with a cohesive sound throughout. Luna Echo has really found their signature style. Only reason it's not 5 stars is that a couple tracks in the middle feel a bit repetitive.",
        date: "2023-05-18",
        likes: 22,
      },
      {
        id: "r3",
        user: {
          id: "u3",
          name: "NightOwl",
          trustScore: 92,
          avatarUrl: "/abstract-geometric-shapes.png",
        },
        rating: 5,
        text: "Perfect late-night listening. The ambient textures combined with the driving beats create such an immersive experience. This album got me through many late work sessions!",
        date: "2023-05-25",
        likes: 41,
      },
    ],
  };

  return album;
};

// This would be used to generate metadata for the page
export async function generateMetadata({
  params,
}: {
  params: { id: string };
}): Promise<Metadata> {
  const album = getAlbumById(params.id);

  return {
    title: `${album.title} by ${album.artist} | MusicWave`,
    description: album.description.substring(0, 160),
  };
}

export default function AlbumPage({ params }: { params: { id: string } }) {
  const album = getAlbumById(params.id);

  return (
    <main className="container mx-auto px-4 py-6">
      <AlbumHeader album={album} />

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mt-8">
        <div className="lg:col-span-2">
          <Tabs defaultValue="tracks" className="w-full">
            <TabsList className="mb-4">
              <TabsTrigger value="tracks">Tracks</TabsTrigger>
              <TabsTrigger value="about">About</TabsTrigger>
              <TabsTrigger value="reviews">Reviews</TabsTrigger>
            </TabsList>
            <TabsContent value="tracks" className="mt-0">
              <TrackList tracks={album.tracks} />
            </TabsContent>
            <TabsContent value="about" className="mt-0">
              <div className="space-y-6">
                <div>
                  <h3 className="text-xl font-semibold mb-2">
                    About this album
                  </h3>
                  <p className="text-muted-foreground">{album.description}</p>
                </div>
                <div>
                  <h3 className="text-xl font-semibold mb-2">Credits</h3>
                  <ul className="space-y-2">
                    {album.credits.map((credit, index) => (
                      <li key={index} className="flex justify-between">
                        <span className="text-muted-foreground">
                          {credit.role}
                        </span>
                        <span className="font-medium">{credit.name}</span>
                      </li>
                    ))}
                  </ul>
                </div>
                <div>
                  <h3 className="text-xl font-semibold mb-2">Album Info</h3>
                  <ul className="space-y-2">
                    <li className="flex justify-between">
                      <span className="text-muted-foreground">
                        Release Date
                      </span>
                      <span className="font-medium">{album.releaseDate}</span>
                    </li>
                    <li className="flex justify-between">
                      <span className="text-muted-foreground">Label</span>
                      <span className="font-medium">{album.label}</span>
                    </li>
                    <li className="flex justify-between">
                      <span className="text-muted-foreground">Genre</span>
                      <span className="font-medium">{album.genre}</span>
                    </li>
                    <li className="flex justify-between">
                      <span className="text-muted-foreground">Duration</span>
                      <span className="font-medium">{album.duration}</span>
                    </li>
                  </ul>
                </div>
              </div>
            </TabsContent>
            <TabsContent value="reviews" className="mt-0">
              <AlbumReviews reviews={album.reviews} albumId={album.id} />
            </TabsContent>
          </Tabs>
        </div>

        <div className="space-y-8">
          <div>
            <h3 className="text-xl font-semibold mb-4">
              More from {album.artist}
            </h3>
            <div className="grid grid-cols-2 gap-4">
              {[2, 3].map((id) => (
                <Link
                  key={id}
                  href={`/albums/${id}`}
                  className="group space-y-2"
                >
                  <div className="relative aspect-square overflow-hidden rounded-md">
                    <Image
                      src={`/album-cover-${id}.png`}
                      alt={`Album by ${album.artist}`}
                      fill
                      className="object-cover transition-transform group-hover:scale-105"
                    />
                  </div>
                  <div>
                    <h4 className="font-medium truncate group-hover:text-primary transition-colors">
                      {id === 2 ? "Purple Haze" : "Digital Pulse"}
                    </h4>
                    <p className="text-sm text-muted-foreground">
                      {album.artist}
                    </p>
                  </div>
                </Link>
              ))}
            </div>
          </div>

          <Separator />

          <RelatedAlbums />
        </div>
      </div>
    </main>
  );
}
