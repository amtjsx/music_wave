import { IsNotEmpty, IsString, IsOptional, IsEnum } from "class-validator"
import { ApiProperty } from "@nestjs/swagger"
import { SocialPlatform } from "../../artists/models/social-link.model"

export class SocialLinkDto {
  @ApiProperty({ enum: SocialPlatform, description: "Social media platform" })
  @IsEnum(SocialPlatform)
  platform: SocialPlatform

  @ApiProperty({ description: "URL to social media profile" })
  @IsNotEmpty()
  @IsString()
  url: string

  @ApiProperty({ description: "Username on the platform", required: false })
  @IsOptional()
  @IsString()
  username?: string
}

export class CreateSocialLinkDto extends SocialLinkDto {}

export class UpdateSocialLinkDto extends SocialLinkDto {}
