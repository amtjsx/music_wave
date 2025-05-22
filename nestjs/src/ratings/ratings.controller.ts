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
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from "@nestjs/swagger";
import { RatingsService } from "./ratings.service";
import { CreateRatingDto } from "./dto/create-rating.dto";
import { UpdateRatingDto } from "./dto/update-rating.dto";
import { QueryRatingsDto } from "./dto/query-ratings.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { RolesGuard } from "../auth/guards/roles.guard";
import { Roles } from "../auth/decorators/roles.decorator";
import { Role } from "../users/enums/role.enum";

@ApiTags("ratings")
@Controller("ratings")
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Get()
  @ApiOperation({ summary: "Get ratings with filtering and pagination" })
  @ApiResponse({ status: 200, description: "Return ratings" })
  async findAll(queryDto: QueryRatingsDto) {
    return this.ratingsService.findAll(queryDto);
  }

  @Get(":id")
  @ApiOperation({ summary: "Get rating by ID" })
  @ApiParam({ name: "id", description: "Rating ID" })
  @ApiResponse({ status: 200, description: "Return the rating" })
  @ApiResponse({ status: 404, description: "Rating not found" })
  async findOne(@Param("id", ParseUUIDPipe) id: string) {
    return this.ratingsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Create a new rating" })
  @ApiResponse({ status: 201, description: "The rating has been created" })
  async create(@Request() req, @Body() createRatingDto: CreateRatingDto) {
    return this.ratingsService.create(req.user.id, createRatingDto);
  }

  @Put(":id")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update a rating" })
  @ApiParam({ name: "id", description: "Rating ID" })
  @ApiResponse({ status: 200, description: "The rating has been updated" })
  @ApiResponse({ status: 404, description: "Rating not found" })
  async update(
    @Request() req,
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateRatingDto: UpdateRatingDto
  ) {
    return this.ratingsService.update(id, req.user.id, updateRatingDto);
  }

  @Delete(":id")
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Delete a rating" })
  @ApiParam({ name: "id", description: "Rating ID" })
  @ApiResponse({ status: 204, description: "The rating has been deleted" })
  @ApiResponse({ status: 404, description: "Rating not found" })
  async remove(@Request() req, @Param("id", ParseUUIDPipe) id: string) {
    const isAdmin = req.user.roles?.includes(Role.ADMIN);
    await this.ratingsService.remove(id, req.user.id, isAdmin);
  }

  @Get("track/:trackId")
  @ApiOperation({ summary: "Get ratings for a track" })
  @ApiParam({ name: "trackId", description: "Track ID" })
  @ApiResponse({ status: 200, description: "Return the track ratings" })
  @ApiResponse({ status: 404, description: "Track not found" })
  async getTrackRatings(
    @Param("trackId", ParseUUIDPipe) trackId: string,
    @Query("page") page: number = 1,
    @Query("limit") limit: number = 20
  ) {
    return this.ratingsService.getTrackRatings(trackId, page, limit);
  }

  @Get("track/:trackId/stats")
  @ApiOperation({ summary: "Get rating statistics for a track" })
  @ApiParam({ name: "trackId", description: "Track ID" })
  @ApiResponse({
    status: 200,
    description: "Return the track rating statistics",
  })
  @ApiResponse({ status: 404, description: "Track not found" })
  async getTrackRatingStats(@Param("trackId", ParseUUIDPipe) trackId: string) {
    return this.ratingsService.getTrackRatingStats(trackId);
  }

  @Get("user/track/:trackId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get current user's rating for a track" })
  @ApiParam({ name: "trackId", description: "Track ID" })
  @ApiResponse({
    status: 200,
    description: "Return the user's rating for the track",
  })
  async getUserRatingForTrack(
    @Request() req,
    @Param("trackId", ParseUUIDPipe) trackId: string
  ) {
    const rating = await this.ratingsService.findUserRatingForTrack(
      req.user.id,
      trackId
    );
    return rating || { exists: false };
  }

  @Delete("admin/:id")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Admin delete a rating" })
  @ApiParam({ name: "id", description: "Rating ID" })
  @ApiResponse({ status: 204, description: "The rating has been deleted" })
  @ApiResponse({ status: 404, description: "Rating not found" })
  async adminRemove(@Param("id", ParseUUIDPipe) id: string) {
    await this.ratingsService.remove(id, null, true);
  }
}
