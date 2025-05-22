import { IsOptional, IsUUID, IsNumber, Min, Max } from "class-validator";
import { Type } from "class-transformer";
import { ApiProperty } from "@nestjs/swagger";

export class QueryRatingsDto {
  @ApiProperty({ description: "Track ID", required: false })
  @IsOptional()
  @IsUUID(4)
  trackId?: string;

  @ApiProperty({ description: "User ID", required: false })
  @IsOptional()
  @IsUUID(4)
  userId?: string;

  @ApiProperty({
    description: "Minimum rating value",
    required: false,
    minimum: 1,
    maximum: 5,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(5)
  minValue?: number;

  @ApiProperty({
    description: "Maximum rating value",
    required: false,
    minimum: 1,
    maximum: 5,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(5)
  maxValue?: number;

  @ApiProperty({ description: "Page number", required: false, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiProperty({ description: "Items per page", required: false, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
