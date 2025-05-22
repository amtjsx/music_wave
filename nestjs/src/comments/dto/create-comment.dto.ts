import { IsNotEmpty, IsString, IsUUID, IsOptional, MaxLength } from "class-validator"
import { ApiProperty } from "@nestjs/swagger"

export class CreateCommentDto {
  @ApiProperty({ description: "Comment content" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(1000)
  content: string

  @ApiProperty({ description: "Track ID" })
  @IsUUID(4)
  trackId: string

  @ApiProperty({ description: "Parent comment ID (for replies)", required: false })
  @IsOptional()
  @IsUUID(4)
  parentId?: string
}

