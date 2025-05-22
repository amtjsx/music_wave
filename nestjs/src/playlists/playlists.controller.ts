import { Controller, Get, Post, Put, Delete, UseGuards, ForbiddenException, HttpCode, HttpStatus } from "@nestjs/common"
import { ApiTags, ApiOperation, ApiParam, ApiResponse, ApiBearerAuth } from "@nestjs/swagger"
import { PlaylistsService } from "./playlists.service"
import { CreatePlaylistDto } from "./dto/create-playlist.dto"
import { UpdatePlaylistDto } from "./dto/update-playlist.dto"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"

@ApiTags("playlists")
@Controller("playlists")
export class PlaylistsController {
  constructor(private readonly playlistsService: PlaylistsService) {}

  @Get()
  @ApiOperation({ summary: "Get all public playlists" })
  @ApiResponse({ status: 200, description: "Return all public playlists" })
  async findAllPublic() {
    return this.playlistsService.findAllPublic()
  }

  @Get("my")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get current user's playlists" })
  @ApiResponse({ status: 200, description: "Return user's playlists" })
  async findMyPlaylists(req) {
    return this.playlistsService.findByUserId(req.user.id)
  }

  @Get(":id")
  @ApiOperation({ summary: "Get playlist by ID" })
  @ApiParam({ name: "id", description: "Playlist ID" })
  @ApiResponse({ status: 200, description: "Return the playlist" })
  @ApiResponse({ status: 404, description: "Playlist not found" })
  async findOne(id: string, req) {
    const playlist = await this.playlistsService.findOne(id)

    // Check if user can access this playlist
    if (!playlist.isPublic && (!req.user || req.user.id !== playlist.ownerId)) {
      throw new ForbiddenException("You do not have permission to access this playlist")
    }

    return playlist
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Create a new playlist" })
  @ApiResponse({ status: 201, description: "The playlist has been created" })
  async create(createPlaylistDto: CreatePlaylistDto, req) {
    return this.playlistsService.create(createPlaylistDto, req.user.id)
  }

  @Put(":id")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update a playlist" })
  @ApiParam({ name: "id", description: "Playlist ID" })
  @ApiResponse({ status: 200, description: "The playlist has been updated" })
  @ApiResponse({ status: 404, description: "Playlist not found" })
  async update(id: string, updatePlaylistDto: UpdatePlaylistDto, req) {
    // Check if user owns this playlist
    const playlist = await this.playlistsService.findOne(id)
    if (playlist.ownerId !== req.user.id) {
      throw new ForbiddenException("You do not have permission to update this playlist")
    }

    return this.playlistsService.update(id, updatePlaylistDto)
  }

  @Delete(":id")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Delete a playlist" })
  @ApiParam({ name: "id", description: "Playlist ID" })
  @ApiResponse({ status: 204, description: "The playlist has been deleted" })
  @ApiResponse({ status: 404, description: "Playlist not found" })
  async remove(id: string, req) {
    // Check if user owns this playlist
    const playlist = await this.playlistsService.findOne(id)
    if (playlist.ownerId !== req.user.id) {
      throw new ForbiddenException("You do not have permission to delete this playlist")
    }

    await this.playlistsService.remove(id)
  }

  @Post(":id/tracks/:trackId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Add a track to a playlist" })
  @ApiParam({ name: "id", description: "Playlist ID" })
  @ApiParam({ name: "trackId", description: "Track ID" })
  @ApiResponse({ status: 200, description: "The track has been added to the playlist" })
  async addTrack(id: string, trackId: string, req) {
    // Check if user owns this playlist
    const playlist = await this.playlistsService.findOne(id)
    if (playlist.ownerId !== req.user.id) {
      throw new ForbiddenException("You do not have permission to modify this playlist")
    }

    return this.playlistsService.addTrack(id, trackId)
  }

  @Delete(":id/tracks/:trackId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Remove a track from a playlist" })
  @ApiParam({ name: "id", description: "Playlist ID" })
  @ApiParam({ name: "trackId", description: "Track ID" })
  @ApiResponse({ status: 204, description: "The track has been removed from the playlist" })
  async removeTrack(id: string, trackId: string, req) {
    // Check if user owns this playlist
    const playlist = await this.playlistsService.findOne(id)
    if (playlist.ownerId !== req.user.id) {
      throw new ForbiddenException("You do not have permission to modify this playlist")
    }

    await this.playlistsService.removeTrack(id, trackId)
  }
}
