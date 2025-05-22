import { IsEmail, IsNotEmpty, IsString, MinLength, IsOptional } from "class-validator"
import { ApiProperty } from "@nestjs/swagger"

export class CreateUserDto {
  @ApiProperty({ description: "User email" })
  @IsEmail()
  @IsNotEmpty()
  email: string

  @ApiProperty({ description: "User password" })
  @IsString()
  @MinLength(6)
  @IsNotEmpty()
  password: string

  @ApiProperty({ description: "Username" })
  @IsString()
  @IsNotEmpty()
  username: string

  @ApiProperty({ description: "Full name", required: false })
  @IsString()
  @IsOptional()
  fullName?: string

  @ApiProperty({ description: "Avatar URL", required: false })
  @IsString()
  @IsOptional()
  avatarUrl?: string
}
