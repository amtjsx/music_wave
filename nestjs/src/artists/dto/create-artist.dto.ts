import { ApiProperty } from "@nestjs/swagger";
import { Type } from "class-transformer";
import {
    IsArray,
    IsEnum,
    IsNotEmpty,
    IsOptional,
    IsString,
    IsUUID,
    ValidateNested,
} from "class-validator";
import { SocialPlatform } from "../models/social-link.model";

class SocialLinkDto {
  @ApiProperty({ enum: SocialPlatform, description: "Social media platform" })
  @IsEnum(SocialPlatform)
  platform: SocialPlatform;

  @ApiProperty({ description: "URL to social media profile" })
  @IsString()
  url: string;

  @ApiProperty({ description: "Username on the platform", required: false })
  @IsOptional()
  @IsString()
  username?: string;
}

export class CreateArtistDto {
  @ApiProperty({ description: "Artist or band name" })
  @IsNotEmpty()
  @IsString()
  artistName: string;

  @ApiProperty({ description: "Artist biography", required: false })
  @IsOptional()
  @IsString()
  bio?: string;

  @ApiProperty({ description: "Primary music genre" })
  @IsNotEmpty()
  @IsString()
  primaryGenre: string;

  @ApiProperty({
    description: "Secondary genres",
    type: [String],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  secondaryGenres?: string[];

  @ApiProperty({ description: "Artist website URL", required: false })
  @IsOptional()
  @IsString()
  website?: string;

  @ApiProperty({ description: "Profile image URL", required: false })
  @IsOptional()
  @IsString()
  profileImageUrl?: string;

  @ApiProperty({ description: "Cover image URL", required: false })
  @IsOptional()
  @IsString()
  coverImageUrl?: string;

  @ApiProperty({
    description: "Social media links",
    type: [SocialLinkDto],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SocialLinkDto)
  socialLinks?: SocialLinkDto[];

  @ApiProperty({ description: "Payment method", required: false })
  @IsOptional()
  @IsString()
  paymentMethod?: string;

  @ApiProperty({ description: "Bank account number", required: false })
  @IsOptional()
  @IsString()
  accountNumber?: string;

  @ApiProperty({ description: "Bank routing number", required: false })
  @IsOptional()
  @IsString()
  routingNumber?: string;

  @ApiProperty({ description: "Tax ID or SSN", required: false })
  @IsOptional()
  @IsString()
  taxId?: string;

  @ApiProperty({ description: "User ID associated with this artist" })
  @IsUUID(4)
  userId: string;
}
