import {
  Body,
  Controller,
  Delete,
  Get,
  Header,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Put,
  Query,
  Res,
  StreamableFile,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from "@nestjs/common";
import { FileFieldsInterceptor } from "@nestjs/platform-express";
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { Express, Response } from "express";
import { Roles } from "../auth/decorators/roles.decorator";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { RolesGuard } from "../auth/guards/roles.guard";
import { Role } from "../users/enums/role.enum";
import { QueryTracksDto } from "./dto/query-tracks.dto";
import { UpdateTrackDto } from "./dto/update-track.dto";
import { MusicService } from "./music.service";

@ApiTags("music")
@Controller("music")
export class MusicController {
  constructor(private readonly musicService: MusicService) {}

  @Get()
  @ApiOperation({ summary: "Get all tracks with pagination and filtering" })
  @ApiResponse({ status: 200, description: "Return all tracks" })
  async findAll(@Query() queryDto: QueryTracksDto) {
    return this.musicService.findAll(queryDto);
  }

  @Get("popular")
  @ApiOperation({ summary: "Get most popular tracks" })
  @ApiResponse({ status: 200, description: "Return popular tracks" })
  async getPopular(@Query("limit") limit: number = 10) {
    return this.musicService.getPopular(limit);
  }

  @Get("recent")
  @ApiOperation({ summary: "Get recently added tracks" })
  @ApiResponse({ status: 200, description: "Return recent tracks" })
  async getRecent(@Query("limit") limit: number = 10) {
    return this.musicService.getRecent(limit);
  }

  @Get(":id")
  @ApiOperation({ summary: "Get track by ID" })
  @ApiParam({ name: "id", description: "Track ID" })
  @ApiResponse({ status: 200, description: "Return the track" })
  @ApiResponse({ status: 404, description: "Track not found" })
  async findOne(@Param("id", ParseUUIDPipe) id: string) {
    return this.musicService.findOne(id);
  }

  @Post()
  // @UseGuards(JwtAuthGuard, RolesGuard)
  // @Roles(Role.ADMIN)
  @ApiOperation({ summary: "Create a new track" })
  @ApiResponse({ status: 201, description: "The track has been created" })
  @ApiBearerAuth()
  @UseInterceptors(
    FileFieldsInterceptor([
      { name: "audio", maxCount: 1 },
      { name: "coverArt", maxCount: 1 },
    ])
  )
  @ApiConsumes("multipart/form-data")
  @ApiBody({
    schema: {
      type: "object",
      properties: {
        title: { type: "string" },
        artist: { type: "string" },
        album: { type: "string" },
        genre: { type: "string" },
        year: { type: "number" },
        audio: {
          type: "string",
          format: "binary",
        },
        coverArt: {
          type: "string",
          format: "binary",
        },
      },
      required: ["title", "artist", "audio"],
    },
  })
  async create(
    @Body() createTrackDto: any,
    @UploadedFiles()
    files: { audio?: Express.Multer.File[]; coverArt?: Express.Multer.File[] }
  ) {
    console.log(createTrackDto);
    console.log(files);
    return this.musicService.create(createTrackDto, files);
  }

  @Put(":id")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: "Update a track" })
  @ApiParam({ name: "id", description: "Track ID" })
  @ApiResponse({ status: 200, description: "The track has been updated" })
  @ApiResponse({ status: 404, description: "Track not found" })
  @ApiBearerAuth()
  async update(
    @Param("id", ParseUUIDPipe) id: string,
    @Body() updateTrackDto: UpdateTrackDto
  ) {
    return this.musicService.update(id, updateTrackDto);
  }

  @Delete(":id")
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(Role.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: "Delete a track" })
  @ApiParam({ name: "id", description: "Track ID" })
  @ApiResponse({ status: 204, description: "The track has been deleted" })
  @ApiResponse({ status: 404, description: "Track not found" })
  @ApiBearerAuth()
  async remove(@Param("id", ParseUUIDPipe) id: string) {
    await this.musicService.remove(id);
  }

  @Get("stream/:filename")
  @ApiOperation({ summary: "Stream audio file" })
  @ApiParam({ name: "filename", description: "Audio filename" })
  @ApiResponse({ status: 200, description: "Stream the audio file" })
  @ApiResponse({ status: 404, description: "File not found" })
  @Header("Accept-Ranges", "bytes")
  async streamAudio(
    @Param("filename") filename: string,
    @Res({ passthrough: true }) res: Response
  ): Promise<StreamableFile> {
    // Increment play count for the track
    await this.musicService.incrementPlayCount(filename);

    // For external URLs, redirect to the source
    const track = await this.musicService.findByFilename(filename);
    if (track && track.audioSrc.startsWith("http")) {
      res.redirect(track.audioSrc);
      return;
    }

    // For local files, stream them with range support
    const { stream, fileSize, start, end } =
      await this.musicService.createAudioStream(
        filename,
        res.req.headers.range
      );

    res.set({
      "Content-Type": "audio/mpeg",
      "Content-Disposition": `inline; filename="${filename}"`,
      "Content-Length": end - start + 1,
      "Content-Range": `bytes ${start}-${end}/${fileSize}`,
    });

    if (res.req.headers.range) {
      res.status(206); // Partial Content
    }

    return new StreamableFile(stream);
  }
}
