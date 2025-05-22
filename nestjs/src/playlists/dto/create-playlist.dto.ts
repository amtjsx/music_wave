import { IsNotEmpty, IsString, IsOptional, IsBoolean, IsArray } from "class-validator"
import { ApiProperty } from "@nestjs/swagger"

export class CreatePlaylistDto {
  @ApiProperty({ description: "Playlist name" })
  @IsNotEmpty()
  @IsString()
  name: string

  @ApiProperty({ description: "Playlist description", required: false })
  @IsOptional()
  @IsString()
  description?: string

  @ApiProperty({ description: "Cover image URL", required: false })
  @IsOptional()
  @IsString()
  coverImage?: string

  @ApiProperty({ description: "Is the playlist public", default: false })
  @IsOptional()
  @IsBoolean()
  isPublic?: boolean = false

  @ApiProperty({ description: "Initial track IDs", required: false, type: [String] })
  @IsOptional()
  @IsArray()
  trackIds?: string[]
}
