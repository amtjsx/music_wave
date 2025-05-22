import { IsNumber, IsString, IsOptional, Min, Max } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class UpdateRatingDto {
  @ApiProperty({ description: "Rating value (1-5)", minimum: 1, maximum: 5 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  value?: number;

  @ApiProperty({ description: "Review text", required: false })
  @IsOptional()
  @IsString()
  review?: string;
}
