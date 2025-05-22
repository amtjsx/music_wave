import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  ParseUUIDPipe,
  HttpStatus,
  HttpCode,
  UseInterceptors,
  UploadedFiles,
} from "@nestjs/common";
import { FileFieldsInterceptor } from "@nestjs/platform-express";
import {
  ApiTags,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiConsumes,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { ArtistsService } from "./artists.service";
import { CreateArtistDto } from "./dto/create-artist.dto";
import { UpdateArtistDto } from "./dto/update-artist.dto";
import { QueryArtistsDto } from "./dto/query-artists.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { RolesGuard } from "../auth/guards/roles.guard";
import { Roles } from "../auth/decorators/roles.decorator";
import { Role } from "../users/enums/role.enum";
import { Express } from "express";

@ApiTags("artists")
@Controller("artists")
export class ArtistsController {
  constructor(private readonly artistsService: ArtistsService) {}

  @Get()
  @ApiOperation({ summary: "Get all artists with pagination and filtering" })
  @ApiResponse({ status: 200, description: "Return all artists" })
  async findAll(@Query() queryDto: QueryArtistsDto) {
    return this.artistsService.findAll(queryDto);
  }

  @Get("featured")
  @ApiOperation({ summary: "Get featured artists" })
  @ApiResponse({ status: 200, description: "Return featured artists" })
  async getFeatured(@Query("limit") limit: number = 10) {
    return this.artistsService.getFeatured(limit);
  }

  @Get("trending")
  @ApiOperation({ summary: "Get trending artists" })
  @ApiResponse({ status: 200, description: "Return trending artists" })
  async getTrending(@Query("limit") limit: number = 10) {
    return this.artistsService.getTrending(limit);
  }

  @Get(":id")
  @ApiOperation({ summary: "Get artist by ID" })
  @ApiParam({ name: "id", description: "Artist ID" })
  @ApiResponse({ status: 200, description: "Return the artist" })
  @ApiResponse({ status: 404, description: "Artist not found" })
  async findOne(@Param("id", ParseUUIDPipe) id: string) {
    return this.artistsService.findOne(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: "Create a new artist profile" })
  @ApiResponse({ status: 201, description: "The artist has been created" })
  @ApiBearerAuth()
  @UseInterceptors(
    FileFieldsInterceptor([
      { name: "profileImage", maxCount: 1 },
      { name: "coverImage", maxCount: 1 },
    ])
  )
  @ApiConsumes("multipart/form-data")
  async create(
    @Body() createArtistDto: CreateArtistDto,
    @UploadedFiles()
    files: {
      profileImage?: Express.Multer.File[];
      coverImage?: Express.Multer.File[];
    }
  ) {
    return this.artistsService.create(createArtistDto, files);
  }

  @Put(":id")
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: "Update an artist profile" })
  @ApiParam({ name: "id", description: "Artist ID" })
  @ApiResponse({ status: 200, description: "The artist has been updated" })
  @ApiResponse({ status: 404, description: "Artist not found" })
  @ApiBearerAuth()
  @UseInterceptors(
    FileFieldsInterceptor([
      { name: "profileImage", maxCount: 1 },
      { name: "coverImage", maxCount: 1 },
    ])
  )
  @ApiConsumes("multipart/form-data")
  async update(
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateArtistDto: UpdateArtistDto,
    @UploadedFiles()
    files: {
      profileImage?: Express.Multer.File[];
      coverImage?: Express.Multer.File[];
    }
  ) {
    return this.artistsService.update(id, updateArtistDto, files);
  }

  @Delete(":id")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Delete an artist profile" })
  @ApiParam({ name: "id", description: "Artist ID" })
  @ApiResponse({ status: 204, description: "The artist has been deleted" })
  @ApiResponse({ status: 404, description: "Artist not found" })
  @ApiBearerAuth()
  async remove(@Param("id", ParseUUIDPipe) id: string) {
    await this.artistsService.remove(id);
  }

  @Get(":id/tracks")
  @ApiOperation({ summary: "Get tracks by artist" })
  @ApiParam({ name: "id", description: "Artist ID" })
  @ApiResponse({ status: 200, description: "Return the artist's tracks" })
  @ApiResponse({ status: 404, description: "Artist not found" })
  async getArtistTracks(
    @Param("id", ParseUUIDPipe) id: string,
    @Query("limit") limit: number = 20,
    @Query("page") page: number = 1
  ) {
    return this.artistsService.getArtistTracks(id, { limit, page });
  }

  @Get(":id/playlists")
  @ApiOperation({ summary: "Get playlists by artist" })
  @ApiParam({ name: "id", description: "Artist ID" })
  @ApiResponse({ status: 200, description: "Return the artist's playlists" })
  @ApiResponse({ status: 404, description: "Artist not found" })
  async getArtistPlaylists(
    @Param("id", ParseUUIDPipe) id: string,
    @Query("limit") limit: number = 20,
    @Query("page") page: number = 1
  ) {
    return this.artistsService.getArtistPlaylists(id, { limit, page });
  }

  @Post(":id/verify")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: "Verify an artist (admin only)" })
  @ApiParam({ name: "id", description: "Artist ID" })
  @ApiResponse({ status: 200, description: "The artist has been verified" })
  @ApiResponse({ status: 404, description: "Artist not found" })
  @ApiBearerAuth()
  async verifyArtist(@Param("id", ParseUUIDPipe) id: string) {
    return this.artistsService.verifyArtist(id);
  }

  @Post(":id/feature")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: "Feature an artist (admin only)" })
  @ApiParam({ name: "id", description: "Artist ID" })
  @ApiResponse({ status: 200, description: "The artist has been featured" })
  @ApiResponse({ status: 404, description: "Artist not found" })
  @ApiBearerAuth()
  async featureArtist(@Param("id", ParseUUIDPipe) id: string) {
    return this.artistsService.featureArtist(id);
  }
}
