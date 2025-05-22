import { ApiProperty } from "@nestjs/swagger";

export class TrackDto {
  @ApiProperty({ description: "Track ID" })
  id: string;

  @ApiProperty({ description: "Track title" })
  title: string;

  @ApiProperty({ description: "Artist name" })
  artist: string;

  @ApiProperty({ description: "Album name", required: false })
  album?: string;

  @ApiProperty({ description: "Music genre", required: false })
  genre?: string;

  @ApiProperty({ description: "Release year", required: false })
  year?: number;

  @ApiProperty({ description: "Track duration in seconds", required: false })
  duration?: number;

  @ApiProperty({ description: "Audio file URL or path" })
  audioSrc: string;

  @ApiProperty({ description: "Cover art URL", required: false })
  coverArt?: string;

  @ApiProperty({ description: "Play count" })
  playCount: number;

  @ApiProperty({ description: "Average rating (1-5)" })
  averageRating: number;

  @ApiProperty({ description: "Number of ratings" })
  ratingCount: number;

  @ApiProperty({ description: "Creation date" })
  createdAt: Date;

  @ApiProperty({ description: "Last update date" })
  updatedAt: Date;
}
