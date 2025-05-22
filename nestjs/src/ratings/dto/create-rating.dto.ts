import { IsNotEmpty, IsNumber, IsUUID, IsString, IsOptional, Min, Max } from "class-validator"
import { ApiProperty } from "@nestjs/swagger"

export class CreateRatingDto {
  @ApiProperty({ description: "Rating value (1-5)", minimum: 1, maximum: 5 })
  @IsNotEmpty()
  @IsNumber()
  @Min(1)
  @Max(5)
  value: number

  @ApiProperty({ description: "Optional review text", required: false })
  @IsOptional()
  @IsString()
  review?: string

  @ApiProperty({ description: "Track ID" })
  @IsNotEmpty()
  @IsUUID(4)
  trackId: string
}
