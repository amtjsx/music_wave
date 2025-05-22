import { IsNotEmpty, IsString, IsNumber, IsOptional, Min, Max } from "class-validator"
import { ApiProperty } from "@nestjs/swagger"

export class CreateTrackDto {
  @ApiProperty({ description: "Track title" })
  @IsNotEmpty()
  @IsString()
  title: string

  @ApiProperty({ description: "Artist name" })
  @IsNotEmpty()
  @IsString()
  artist: string

  @ApiProperty({ description: "Album name", required: false })
  @IsString()
  @IsOptional()
  album?: string

  @ApiProperty({ description: "Music genre", required: false })
  @IsString()
  @IsOptional()
  genre?: string

  @ApiProperty({ description: "Release year", required: false })
  @IsNumber()
  @IsOptional()
  @Min(1900)
  @Max(new Date().getFullYear())
  year?: number

  @ApiProperty({ description: "Track duration in seconds", required: false })
  @IsNumber()
  @IsOptional()
  duration?: number

  @ApiProperty({ description: "Audio file URL or path" })
  @IsNotEmpty()
  @IsString()
  audioSrc: string

  @ApiProperty({ description: "Original filename" })
  @IsNotEmpty()
  @IsString()
  filename: string

  @ApiProperty({ description: "Cover art URL", required: false })
  @IsString()
  @IsOptional()
  coverArt?: string
}
