import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from "@nestjs/common"
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from "@nestjs/swagger"
import { CommentsService } from "./comments.service"
import { CreateCommentDto } from "./dto/create-comment.dto"
import { UpdateCommentDto } from "./dto/update-comment.dto"
import { QueryCommentsDto } from "./dto/query-comments.dto"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import { RolesGuard } from "../auth/guards/roles.guard"
import { Roles } from "../auth/decorators/roles.decorator"
import { Role } from "../users/enums/role.enum"

@ApiTags("comments")
@Controller("comments")
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Get()
  @ApiOperation({ summary: "Get comments with filtering and pagination" })
  @ApiResponse({ status: 200, description: "Return comments" })
  async findAll(queryDto: QueryCommentsDto) {
    return this.commentsService.findAll(queryDto)
  }

  @Get(":id")
  @ApiOperation({ summary: "Get comment by ID" })
  @ApiParam({ name: "id", description: "Comment ID" })
  @ApiResponse({ status: 200, description: "Return the comment" })
  @ApiResponse({ status: 404, description: "Comment not found" })
  async findOne(@Param("id", ParseUUIDPipe) id: string) {
    return this.commentsService.findOne(id)
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Create a new comment" })
  @ApiResponse({ status: 201, description: "The comment has been created" })
  async create(@Request() req, @Body() createCommentDto: CreateCommentDto) {
    return this.commentsService.create(req.user.id, createCommentDto)
  }

  @Put(":id")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update a comment" })
  @ApiParam({ name: "id", description: "Comment ID" })
  @ApiResponse({ status: 200, description: "The comment has been updated" })
  @ApiResponse({ status: 404, description: "Comment not found" })
  async update(@Request() req, @Param("id", ParseUUIDPipe) id: string, @Body() updateCommentDto: UpdateCommentDto) {
    return this.commentsService.update(id, req.user.id, updateCommentDto)
  }

  @Delete(":id")
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Delete a comment" })
  @ApiParam({ name: "id", description: "Comment ID" })
  @ApiResponse({ status: 204, description: "The comment has been deleted" })
  @ApiResponse({ status: 404, description: "Comment not found" })
  async remove(@Request() req, @Param("id", ParseUUIDPipe) id: string) {
    const isAdmin = req.user.roles?.includes(Role.ADMIN)
    await this.commentsService.remove(id, req.user.id, isAdmin)
  }

  @Post(":id/like")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Like a comment" })
  @ApiParam({ name: "id", description: "Comment ID" })
  @ApiResponse({ status: 200, description: "The comment has been liked" })
  @ApiResponse({ status: 404, description: "Comment not found" })
  async likeComment(@Param("id", ParseUUIDPipe) id: string) {
    return this.commentsService.likeComment(id)
  }

  @Get(":id/replies")
  @ApiOperation({ summary: "Get replies to a comment" })
  @ApiParam({ name: "id", description: "Comment ID" })
  @ApiResponse({ status: 200, description: "Return the comment replies" })
  @ApiResponse({ status: 404, description: "Comment not found" })
  async getCommentReplies(
    @Param("id", ParseUUIDPipe) id: string,
    @Query("page") page: number = 1,
    @Query("limit") limit: number = 20,
  ) {
    return this.commentsService.getCommentReplies(id, page, limit)
  }

  @Get("track/:trackId")
  @ApiOperation({ summary: "Get comments for a track" })
  @ApiParam({ name: "trackId", description: "Track ID" })
  @ApiResponse({ status: 200, description: "Return the track comments" })
  @ApiResponse({ status: 404, description: "Track not found" })
  async getTrackComments(
    @Param("trackId", ParseUUIDPipe) trackId: string,
    @Query("page") page: number = 1,
    @Query("limit") limit: number = 20,
  ) {
    return this.commentsService.getTrackComments(trackId, page, limit)
  }

  @Delete("admin/:id")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Admin delete a comment" })
  @ApiParam({ name: "id", description: "Comment ID" })
  @ApiResponse({ status: 204, description: "The comment has been deleted" })
  @ApiResponse({ status: 404, description: "Comment not found" })
  async adminRemove(@Request() req, @Param("id", ParseUUIDPipe) id: string) {
    await this.commentsService.remove(id, req.user.id, true)
  }
}
