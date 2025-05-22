import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from "@nestjs/common";
import type { Sequelize } from "sequelize-typescript";
import { Op } from "sequelize";
import * as fs from "fs";
import * as path from "path";
import * as mm from "music-metadata";
import type { Track } from "./models/track.model";
import type { CreateTrackDto } from "./dto/create-track.dto";
import type { UpdateTrackDto } from "./dto/update-track.dto";
import type { QueryTracksDto } from "./dto/query-tracks.dto";
import { withTransaction } from "../common/utils/transaction.util";
import type { Express } from "express";

@Injectable()
export class MusicService {
  constructor(private trackModel: typeof Track, private sequelize: Sequelize) {}

  async findAll(queryDto: QueryTracksDto) {
    const { q, artist, album, genre, page, limit, sortBy, order } = queryDto;

    // Build where conditions
    const where: any = {};

    if (q) {
      where.title = { [Op.like]: `%${q}%` };
    }

    if (artist) {
      where.artist = { [Op.like]: `%${artist}%` };
    }

    if (album) {
      where.album = { [Op.like]: `%${album}%` };
    }

    if (genre) {
      where.genre = { [Op.like]: `%${genre}%` };
    }

    // Calculate pagination
    const offset = (page - 1) * limit;

    // Get tracks with count
    const { rows: tracks, count: total } =
      await this.trackModel.findAndCountAll({
        where,
        order: [[sortBy, order]],
        offset,
        limit,
      });

    // Calculate pagination metadata
    const totalPages = Math.ceil(total / limit);
    const hasNext = page < totalPages;
    const hasPrevious = page > 1;

    return {
      data: tracks,
      meta: {
        total,
        page,
        limit,
        totalPages,
        hasNext,
        hasPrevious,
      },
    };
  }

  async findOne(id: string): Promise<Track> {
    const track = await this.trackModel.findByPk(id);
    if (!track) {
      throw new NotFoundException(`Track with ID ${id} not found`);
    }
    return track;
  }

  async getPopular(limit = 10): Promise<Track[]> {
    return this.trackModel.findAll({
      order: [["playCount", "DESC"]],
      limit,
    });
  }

  async getRecent(limit = 10): Promise<Track[]> {
    return this.trackModel.findAll({
      order: [["createdAt", "DESC"]],
      limit,
    });
  }

  async getTopRated(limit = 10, minRatings = 3): Promise<Track[]> {
    return this.trackModel.findAll({
      where: {
        ratingCount: { [Op.gte]: minRatings },
      },
      order: [["averageRating", "DESC"]],
      limit,
    });
  }

  async create(
    createTrackDto: CreateTrackDto,
    files: { audio?: Express.Multer.File[]; coverArt?: Express.Multer.File[] }
  ): Promise<Track> {
    const audioFile = files.audio?.[0];
    const coverFile = files.coverArt?.[0];

    if (!audioFile && !createTrackDto.audioSrc) {
      throw new BadRequestException(
        "Either audio file or audioSrc is required"
      );
    }

    // Create new track data
    const trackData: any = {
      title: createTrackDto.title,
      artist: createTrackDto.artist,
      album: createTrackDto.album,
      genre: createTrackDto.genre,
      year: createTrackDto.year,
      averageRating: 0,
      ratingCount: 0,
    };

    // Handle audio file
    if (audioFile) {
      trackData.filename = audioFile.filename;
      trackData.audioSrc = `/uploads/audio/${audioFile.filename}`;

      // Extract metadata from audio file
      try {
        const filePath = path.join(
          process.cwd(),
          "uploads",
          "audio",
          audioFile.filename
        );
        const metadata = await mm.parseFile(filePath);

        // Set duration if not provided
        if (!createTrackDto.duration && metadata.format.duration) {
          trackData.duration = Math.round(metadata.format.duration);
        }

        // Set other metadata if not provided
        if (!trackData.album && metadata.common.album) {
          trackData.album = metadata.common.album;
        }

        if (
          !trackData.genre &&
          metadata.common.genre &&
          metadata.common.genre.length > 0
        ) {
          trackData.genre = metadata.common.genre[0];
        }

        if (!trackData.year && metadata.common.year) {
          trackData.year = metadata.common.year;
        }
      } catch (error) {
        console.error("Error extracting metadata:", error);
      }
    } else {
      // Use provided audioSrc
      trackData.audioSrc = createTrackDto.audioSrc;
      trackData.filename =
        createTrackDto.filename || path.basename(createTrackDto.audioSrc);
    }

    // Handle cover art
    if (coverFile) {
      trackData.coverArt = `/uploads/covers/${coverFile.filename}`;
    } else if (createTrackDto.coverArt) {
      trackData.coverArt = createTrackDto.coverArt;
    }

    // Set duration if provided
    if (createTrackDto.duration) {
      trackData.duration = createTrackDto.duration;
    }

    // Save track to database using transaction
    return withTransaction(this.sequelize, async (transaction) => {
      return this.trackModel.create(trackData, { transaction });
    });
  }

  async update(id: string, updateTrackDto: UpdateTrackDto): Promise<Track> {
    const track = await this.findOne(id);

    // Update track properties using transaction
    return withTransaction(this.sequelize, async (transaction) => {
      await track.update(updateTrackDto, { transaction });
      return track;
    });
  }

  async remove(id: string): Promise<void> {
    const track = await this.findOne(id);

    // Delete local files if they exist (outside transaction)
    if (track.audioSrc.startsWith("/uploads/")) {
      const audioPath = path.join(process.cwd(), track.audioSrc);
      if (fs.existsSync(audioPath)) {
        fs.unlinkSync(audioPath);
      }
    }

    if (track.coverArt && track.coverArt.startsWith("/uploads/")) {
      const coverPath = path.join(process.cwd(), track.coverArt);
      if (fs.existsSync(coverPath)) {
        fs.unlinkSync(coverPath);
      }
    }

    // Delete from database using transaction
    await withTransaction(this.sequelize, async (transaction) => {
      await track.destroy({ transaction });
    });
  }

  async findByFilename(filename: string): Promise<Track | null> {
    // Try to find by exact filename
    let track = await this.trackModel.findOne({
      where: { filename },
    });

    // If not found, try to find by audioSrc ending with filename
    if (!track) {
      const tracks = await this.trackModel.findAll();
      track = tracks.find((t) => {
        const trackFilename = t.audioSrc.split("/").pop();
        return trackFilename === filename;
      });
    }

    return track || null;
  }

  async incrementPlayCount(filename: string): Promise<void> {
    const track = await this.findByFilename(filename);
    if (track) {
      track.playCount += 1;
      await track.save();
    }
  }

  async createAudioStream(filename: string, rangeHeader?: string) {
    const filePath = path.join(process.cwd(), "uploads", "audio", filename);

    if (!fs.existsSync(filePath)) {
      throw new NotFoundException(`File ${filename} not found`);
    }

    const fileSize = fs.statSync(filePath).size;

    // Handle range request
    let start = 0;
    let end = fileSize - 1;

    if (rangeHeader) {
      const parts = rangeHeader.replace(/bytes=/, "").split("-");
      start = Number.parseInt(parts[0], 10);
      end = parts[1] ? Number.parseInt(parts[1], 10) : fileSize - 1;
    }

    // Create read stream with range
    const stream = fs.createReadStream(filePath, { start, end });

    return { stream, fileSize, start, end };
  }

  // Batch create tracks in a single transaction
  async batchCreateTracks(tracks: CreateTrackDto[]): Promise<Track[]> {
    return withTransaction(this.sequelize, async (transaction) => {
      const createdTracks = await Promise.all(
        tracks.map((trackDto) => {
          const { filename, ...rest } = trackDto;
          return this.trackModel.create(rest, { transaction });
        })
      );

      return createdTracks;
    });
  }
}
