import { IsEmail, IsString, MinLength, IsOptional } from "class-validator"
import { ApiProperty } from "@nestjs/swagger"

export class UpdateUserDto {
  @ApiProperty({ description: "User email", required: false })
  @IsEmail()
  @IsOptional()
  email?: string

  @ApiProperty({ description: "User password", required: false })
  @IsString()
  @MinLength(6)
  @IsOptional()
  password?: string

  @ApiProperty({ description: "Username", required: false })
  @IsString()
  @IsOptional()
  username?: string

  @ApiProperty({ description: "Full name", required: false })
  @IsString()
  @IsOptional()
  fullName?: string

  @ApiProperty({ description: "Avatar URL", required: false })
  @IsString()
  @IsOptional()
  avatarUrl?: string
}
