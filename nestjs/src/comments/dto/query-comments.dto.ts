import { IsOptional, IsUUID, IsNumber, Min, Max, IsBoolean } from "class-validator"
import { Type } from "class-transformer"
import { ApiProperty } from "@nestjs/swagger"

export class QueryCommentsDto {
  @ApiProperty({ description: "Track ID", required: false })
  @IsOptional()
  @IsUUID(4)
  trackId?: string

  @ApiProperty({ description: "User ID", required: false })
  @IsOptional()
  @IsUUID(4)
  userId?: string

  @ApiProperty({ description: "Parent comment ID (for replies)", required: false })
  @IsOptional()
  @IsUUID(4)
  parentId?: string

  @ApiProperty({ description: "Only fetch top-level comments", required: false, default: false })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  topLevelOnly?: boolean = false

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
}
