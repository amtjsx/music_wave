import {
  Controller,
  Get,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  ForbiddenException,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
  Post,
} from "@nestjs/common"
import { ApiTags, ApiOperation, ApiParam, ApiResponse, ApiBearerAuth } from "@nestjs/swagger"
import { UsersService } from "./users.service"
import { UpdateUserDto } from "./dto/update-user.dto"
import { Role } from "./enums/role.enum"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import { RolesGuard } from "../auth/guards/roles.guard"
import { Roles } from "../auth/decorators/roles.decorator"
import { CreateSocialLinkDto, UpdateSocialLinkDto } from "./dto/social-link.dto"
import { Request } from "express"

@ApiTags("users")
@Controller("users")
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get("profile")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get current user profile" })
  @ApiResponse({ status: 200, description: "Return the user profile" })
  async getProfile(req: Request) {
    return this.usersService.findOne(req.user.id)
  }

  @Put("profile")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update current user profile" })
  @ApiResponse({ status: 200, description: "The profile has been updated" })
  async updateProfile(req: Request, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(req.user.id, updateUserDto)
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get all users (admin only)" })
  @ApiResponse({ status: 200, description: "Return all users" })
  async findAll() {
    return this.usersService.findAll()
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user by ID (admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'Return the user' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.findOne(id);
  }

  @Put(":id")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update a user (admin only)" })
  @ApiParam({ name: "id", description: "User ID" })
  @ApiResponse({ status: 200, description: "The user has been updated" })
  @ApiResponse({ status: 404, description: "User not found" })
  async update(@Param('id', ParseUUIDPipe) id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(id, updateUserDto)
  }

  @Delete(":id")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Delete a user (admin only)" })
  @ApiParam({ name: "id", description: "User ID" })
  @ApiResponse({ status: 204, description: "The user has been deleted" })
  @ApiResponse({ status: 404, description: "User not found" })
  async remove(@Param('id', ParseUUIDPipe) id: string, req: Request) {
    // Prevent self-deletion
    if (id === req.user.id) {
      throw new ForbiddenException("You cannot delete your own account")
    }

    await this.usersService.remove(id)
  }

  // Social Links Endpoints
  @Get("profile/social-links")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get current user's social links" })
  @ApiResponse({ status: 200, description: "Return the user's social links" })
  async getUserSocialLinks(req: Request) {
    return this.usersService.getUserSocialLinks(req.user.id)
  }

  @Post("profile/social-links")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Add a social link to current user" })
  @ApiResponse({ status: 201, description: "The social link has been added" })
  async addUserSocialLink(req: Request, @Body() createSocialLinkDto: CreateSocialLinkDto) {
    return this.usersService.addUserSocialLink(req.user.id, createSocialLinkDto)
  }

  @Put("profile/social-links/:linkId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update a social link" })
  @ApiParam({ name: "linkId", description: "Social Link ID" })
  @ApiResponse({ status: 200, description: "The social link has been updated" })
  @ApiResponse({ status: 404, description: "Social link not found" })
  async updateUserSocialLink(
    req: Request,
    @Param("linkId", ParseUUIDPipe) linkId: string,
    @Body() updateSocialLinkDto: UpdateSocialLinkDto,
  ) {
    return this.usersService.updateUserSocialLink(req.user.id, linkId, updateSocialLinkDto)
  }

  @Delete("profile/social-links/:linkId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Delete a social link" })
  @ApiParam({ name: "linkId", description: "Social Link ID" })
  @ApiResponse({ status: 204, description: "The social link has been deleted" })
  @ApiResponse({ status: 404, description: "Social link not found" })
  async removeUserSocialLink(req: Request, @Param("linkId", ParseUUIDPipe) linkId: string) {
    await this.usersService.removeUserSocialLink(req.user.id, linkId)
  }
}
