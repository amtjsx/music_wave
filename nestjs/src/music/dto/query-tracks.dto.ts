import { IsOptional, IsString, IsNumber, Min, Max } from "class-validator"
import { Type } from "class-transformer"
import { ApiProperty } from "@nestjs/swagger"

export class QueryTracksDto {
  @ApiProperty({ description: "Search query", required: false })
  @IsOptional()
  @IsString()
  q?: string

  @ApiProperty({ description: "Artist filter", required: false })
  @IsOptional()
  @IsString()
  artist?: string

  @ApiProperty({ description: "Album filter", required: false })
  @IsOptional()
  @IsString()
  album?: string

  @ApiProperty({ description: "Genre filter", required: false })
  @IsOptional()
  @IsString()
  genre?: string

  @ApiProperty({ description: "Page number", required: false, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1

  @ApiProperty({ description: "Items per page", required: false, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20

  @ApiProperty({ description: "Sort field", required: false, default: "createdAt" })
  @IsOptional()
  @IsString()
  sortBy?: string = "createdAt"

  @ApiProperty({ description: "Sort order", required: false, enum: ["ASC", "DESC"], default: "DESC" })
  @IsOptional()
  @IsString()
  order?: "ASC" | "DESC" = "DESC"
}
