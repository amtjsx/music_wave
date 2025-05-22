import { Injectable, NotFoundException } from "@nestjs/common";
import { InjectModel } from "@nestjs/sequelize";
import { Express } from "express";
import * as fs from "fs";
import * as path from "path";
import { Op } from "sequelize";
import { v4 as uuidv4 } from "uuid";
import { Track } from "../music/models/track.model";
import { Playlist } from "../playlists/models/playlist.model";
import { User } from "../users/models/user.model";
import { CreateArtistDto } from "./dto/create-artist.dto";
import { QueryArtistsDto } from "./dto/query-artists.dto";
import { UpdateArtistDto } from "./dto/update-artist.dto";
import { ArtistGenre } from "./models/artist-genre.model";
import { Artist } from "./models/artist.model";
import { SocialLink } from "./models/social-link.model";

@Injectable()
export class ArtistsService {
  constructor(
    @InjectModel(Artist)
    private readonly artistModel: typeof Artist,
    @InjectModel(SocialLink)
    private readonly socialLinkModel: typeof SocialLink,
    @InjectModel(ArtistGenre)
    private readonly artistGenreModel: typeof ArtistGenre
  ) {}

  async findAll(queryDto: QueryArtistsDto) {
    const { q, genre, verified, featured, page, limit, sortBy, order } =
      queryDto;

    // Build where conditions
    const where: any = {};

    if (q) {
      where.artistName = { [Op.like]: `%${q}%` };
    }

    if (verified !== undefined) {
      where.isVerified = verified;
    }

    if (featured !== undefined) {
      where.isFeatured = featured;
    }

    // Calculate pagination
    const offset = (page - 1) * limit;

    // Get artists with count
    const { rows: artists, count: total } =
      await this.artistModel.findAndCountAll({
        where,
        include: [
          {
            model: SocialLink,
            where: { artistId: { [Op.not]: null } }, // Only include social links associated with artists
          },
          {
            model: ArtistGenre,
            where: genre ? { genre } : undefined,
          },
          {
            model: User,
            attributes: ["id", "username", "email"],
          },
        ],
        order: [[sortBy, order]],
        offset,
        limit,
        distinct: true,
      });

    // Calculate pagination metadata
    const totalPages = Math.ceil(total / limit);
    const hasNext = page < totalPages;
    const hasPrevious = page > 1;

    return {
      data: artists,
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

  async findOne(id: string): Promise<Artist> {
    const artist = await this.artistModel.findByPk(id, {
      include: [
        {
          model: SocialLink,
        },
        {
          model: ArtistGenre,
        },
        {
          model: User,
          attributes: ["id", "username", "email"],
        },
      ],
    });

    if (!artist) {
      throw new NotFoundException(`Artist with ID ${id} not found`);
    }

    return artist;
  }

  async getFeatured(limit = 10): Promise<Artist[]> {
    return this.artistModel.findAll({
      where: { isFeatured: true },
      include: [
        {
          model: SocialLink,
        },
      ],
      limit,
    });
  }

  async getTrending(limit = 10): Promise<Artist[]> {
    return this.artistModel.findAll({
      order: [["monthlyListeners", "DESC"]],
      include: [
        {
          model: SocialLink,
        },
      ],
      limit,
    });
  }

  async create(
    createArtistDto: CreateArtistDto,
    files?: {
      profileImage?: Express.Multer.File[];
      coverImage?: Express.Multer.File[];
    }
  ): Promise<Artist> {
    // Handle file uploads
    let profileImageUrl = createArtistDto.profileImageUrl;
    let coverImageUrl = createArtistDto.coverImageUrl;

    if (files) {
      if (files.profileImage && files.profileImage[0]) {
        profileImageUrl = await this.saveFile(
          files.profileImage[0],
          "artists/profiles"
        );
      }

      if (files.coverImage && files.coverImage[0]) {
        coverImageUrl = await this.saveFile(
          files.coverImage[0],
          "artists/covers"
        );
      }
    }

    // Create artist
    const artist = await this.artistModel.create({
      ...createArtistDto,
      profileImageUrl,
      coverImageUrl,
    });

    // Add social links if provided
    if (createArtistDto.socialLinks && createArtistDto.socialLinks.length > 0) {
      const socialLinks = createArtistDto.socialLinks.map((link) => ({
        ...link,
        artistId: artist.id,
        userId: null, // Explicitly set userId to null for artist social links
      }));

      await this.socialLinkModel.bulkCreate(socialLinks);
    }

    // Add genres if provided
    if (
      createArtistDto.secondaryGenres &&
      createArtistDto.secondaryGenres.length > 0
    ) {
      const genres = [
        {
          artistId: artist.id,
          genre: createArtistDto.primaryGenre,
          isPrimary: true,
        },
        ...createArtistDto.secondaryGenres.map((genre) => ({
          artistId: artist.id,
          genre,
          isPrimary: false,
        })),
      ];

      await this.artistGenreModel.bulkCreate(genres);
    } else {
      // Just add primary genre
      await this.artistGenreModel.create({
        artistId: artist.id,
        genre: createArtistDto.primaryGenre,
        isPrimary: true,
      });
    }

    // Return the created artist with relations
    return this.findOne(artist.id);
  }

  async update(
    id: string,
    updateArtistDto: UpdateArtistDto,
    files?: {
      profileImage?: Express.Multer.File[];
      coverImage?: Express.Multer.File[];
    }
  ): Promise<Artist> {
    const artist = await this.findOne(id);

    // Handle file uploads
    let profileImageUrl = updateArtistDto.profileImageUrl;
    let coverImageUrl = updateArtistDto.coverImageUrl;

    if (files) {
      if (files.profileImage && files.profileImage[0]) {
        // Delete old profile image if exists
        if (
          artist.profileImageUrl &&
          artist.profileImageUrl.startsWith("/uploads/")
        ) {
          this.deleteFile(artist.profileImageUrl);
        }
        profileImageUrl = await this.saveFile(
          files.profileImage[0],
          "artists/profiles"
        );
      }

      if (files.coverImage && files.coverImage[0]) {
        // Delete old cover image if exists
        if (
          artist.coverImageUrl &&
          artist.coverImageUrl.startsWith("/uploads/")
        ) {
          this.deleteFile(artist.coverImageUrl);
        }
        coverImageUrl = await this.saveFile(
          files.coverImage[0],
          "artists/covers"
        );
      }
    }

    // Update artist
    await artist.update({
      ...updateArtistDto,
      profileImageUrl: profileImageUrl || artist.profileImageUrl,
      coverImageUrl: coverImageUrl || artist.coverImageUrl,
    });

    // Update social links if provided
    if (updateArtistDto.socialLinks) {
      // Delete existing social links
      await this.socialLinkModel.destroy({
        where: { artistId: id },
      });

      // Create new social links
      if (updateArtistDto.socialLinks.length > 0) {
        const socialLinks = updateArtistDto.socialLinks.map((link) => ({
          ...link,
          artistId: id,
          userId: null, // Explicitly set userId to null for artist social links
        }));

        await this.socialLinkModel.bulkCreate(socialLinks);
      }
    }

    // Update genres if provided
    if (updateArtistDto.primaryGenre || updateArtistDto.secondaryGenres) {
      // Delete existing genres
      await this.artistGenreModel.destroy({
        where: { artistId: id },
      });

      // Create new genres
      const genres = [];

      if (updateArtistDto.primaryGenre) {
        genres.push({
          artistId: id,
          genre: updateArtistDto.primaryGenre,
          isPrimary: true,
        });
      }

      if (
        updateArtistDto.secondaryGenres &&
        updateArtistDto.secondaryGenres.length > 0
      ) {
        genres.push(
          ...updateArtistDto.secondaryGenres.map((genre) => ({
            artistId: id,
            genre,
            isPrimary: false,
          }))
        );
      }

      if (genres.length > 0) {
        await this.artistGenreModel.bulkCreate(genres);
      }
    }

    // Return the updated artist with relations
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    const artist = await this.findOne(id);

    // Delete profile and cover images if they exist
    if (
      artist.profileImageUrl &&
      artist.profileImageUrl.startsWith("/uploads/")
    ) {
      this.deleteFile(artist.profileImageUrl);
    }

    if (artist.coverImageUrl && artist.coverImageUrl.startsWith("/uploads/")) {
      this.deleteFile(artist.coverImageUrl);
    }

    // Delete social links
    await this.socialLinkModel.destroy({
      where: { artistId: id },
    });

    // Delete genres
    await this.artistGenreModel.destroy({
      where: { artistId: id },
    });

    // Delete artist
    await artist.destroy();
  }

  async getArtistTracks(id: string, options: { limit: number; page: number }) {
    const { limit, page } = options;
    const offset = (page - 1) * limit;

    // Verify artist exists
    await this.findOne(id);

    // Get tracks with pagination
    const { rows: tracks, count: total } = await Track.findAndCountAll({
      where: { artistId: id },
      offset,
      limit,
      order: [["createdAt", "DESC"]],
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

  async getArtistPlaylists(
    id: string,
    options: { limit: number; page: number }
  ) {
    const { limit, page } = options;
    const offset = (page - 1) * limit;

    // Verify artist exists
    await this.findOne(id);

    // Get playlists with pagination
    const { rows: playlists, count: total } = await Playlist.findAndCountAll({
      where: { artistId: id },
      offset,
      limit,
      order: [["createdAt", "DESC"]],
    });

    // Calculate pagination metadata
    const totalPages = Math.ceil(total / limit);
    const hasNext = page < totalPages;
    const hasPrevious = page > 1;

    return {
      data: playlists,
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

  async verifyArtist(id: string): Promise<Artist> {
    const artist = await this.findOne(id);
    await artist.update({ isVerified: true });
    return artist;
  }

  async featureArtist(id: string): Promise<Artist> {
    const artist = await this.findOne(id);
    await artist.update({ isFeatured: true });
    return artist;
  }

  // Helper methods for file handling
  private async saveFile(
    file: Express.Multer.File,
    subDirectory: string
  ): Promise<string> {
    const uploadsDir = path.join(process.cwd(), "uploads");
    const targetDir = path.join(uploadsDir, subDirectory);

    // Ensure directories exist
    if (!fs.existsSync(targetDir)) {
      fs.mkdirSync(targetDir, { recursive: true });
    }

    // Generate unique filename
    const fileExt = path.extname(file.originalname);
    const fileName = `${uuidv4()}${fileExt}`;
    const filePath = path.join(targetDir, fileName);

    // Write file
    fs.writeFileSync(filePath, file.buffer);

    // Return relative path for storage in DB
    return `/uploads/${subDirectory}/${fileName}`;
  }

  private deleteFile(filePath: string): void {
    try {
      const fullPath = path.join(process.cwd(), filePath);
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
      }
    } catch (error) {
      console.error(`Error deleting file ${filePath}:`, error);
    }
  }
}
