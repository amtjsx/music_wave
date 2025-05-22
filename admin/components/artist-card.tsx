import Link from "next/link";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { VerifiedBadge } from "@/components/verified-badge";

interface ArtistCardProps {
  artist: {
    id: string;
    name: string;
    slug: string;
    imageUrl?: string;
    followers: number;
    isVerified: boolean;
    primaryGenre: string;
  };
}

export function ArtistCard({ artist }: ArtistCardProps) {
  const formatNumber = (num: number) => {
    if (num >= 1000000) {
      return (num / 1000000).toFixed(1) + "M";
    }
    if (num >= 1000) {
      return (num / 1000).toFixed(1) + "K";
    }
    return num.toString();
  };

  return (
    <Link href={`/artist/${artist.slug}`}>
      <Card className="overflow-hidden transition-all hover:shadow-md">
        <CardContent className="p-4">
          <div className="flex flex-col items-center text-center">
            <Avatar className="h-24 w-24">
              <AvatarImage
                src={artist.imageUrl || "/placeholder.svg"}
                alt={artist.name}
              />
              <AvatarFallback>{artist.name.charAt(0)}</AvatarFallback>
            </Avatar>

            <div className="mt-3 flex items-center gap-1.5">
              <h3 className="font-semibold">{artist.name}</h3>
              {artist.isVerified && (
                <VerifiedBadge size="sm" variant="default" />
              )}
            </div>

            <Badge variant="secondary" className="mt-2">
              {artist.primaryGenre}
            </Badge>

            <p className="mt-2 text-sm text-muted-foreground">
              {formatNumber(artist.followers)} followers
            </p>
          </div>
        </CardContent>
      </Card>
    </Link>
  );
}
