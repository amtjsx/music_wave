import { IsNotEmpty, IsString, MaxLength } from "class-validator"
import { ApiProperty } from "@nestjs/swagger"

export class UpdateCommentDto {
  @ApiProperty({ description: "Updated comment content" })
  @IsNotEmpty()
  @IsString()
  @MaxLength(1000)
  content: string
}
