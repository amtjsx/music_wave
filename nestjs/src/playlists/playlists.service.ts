import { Injectable, NotFoundException } from "@nestjs/common";
import { Playlist } from "./models/playlist.model";
import { PlaylistTrack } from "./models/playlist-track.model";
import { Track } from "../music/models/track.model";
import { CreatePlaylistDto } from "./dto/create-playlist.dto";
import { UpdatePlaylistDto } from "./dto/update-playlist.dto";
import { MusicService } from "../music/music.service";
import { InjectModel } from "@nestjs/sequelize";

@Injectable()
export class PlaylistsService {
  constructor(
    @InjectModel(Playlist)
    private playlistModel: typeof Playlist,
    @InjectModel(PlaylistTrack)
    private playlistTrackModel: typeof PlaylistTrack,
    private musicService: MusicService
  ) {}

  async findAllPublic(): Promise<Playlist[]> {
    return this.playlistModel.findAll({
      where: { isPublic: true },
      include: [Track],
      order: [["updatedAt", "DESC"]],
    });
  }

  async findByUserId(userId: string): Promise<Playlist[]> {
    return this.playlistModel.findAll({
      where: { ownerId: userId },
      include: [Track],
      order: [["updatedAt", "DESC"]],
    });
  }

  async findOne(id: string): Promise<Playlist> {
    const playlist = await this.playlistModel.findByPk(id, {
      include: [Track],
    });

    if (!playlist) {
      throw new NotFoundException(`Playlist with ID ${id} not found`);
    }

    return playlist;
  }

  async create(
    createPlaylistDto: CreatePlaylistDto,
    userId: string
  ): Promise<Playlist> {
    // Create the playlist
    const playlist = await this.playlistModel.create({
      ...createPlaylistDto,
      ownerId: userId,
    });

    // Add initial tracks if provided
    if (createPlaylistDto.trackIds && createPlaylistDto.trackIds.length > 0) {
      for (const trackId of createPlaylistDto.trackIds) {
        try {
          await this.musicService.findOne(trackId); // Verify track exists
          await this.playlistTrackModel.create({
            playlistId: playlist.id,
            trackId,
          });
        } catch (error) {
          // Skip tracks that don't exist
          console.warn(`Track with ID ${trackId} not found, skipping`);
        }
      }
    }

    // Return the playlist with tracks
    return this.findOne(playlist.id);
  }

  async update(
    id: string,
    updatePlaylistDto: UpdatePlaylistDto
  ): Promise<Playlist> {
    const playlist = await this.findOne(id);

    // Update basic properties
    if (
      updatePlaylistDto.name !== undefined ||
      updatePlaylistDto.description !== undefined ||
      updatePlaylistDto.coverImage !== undefined ||
      updatePlaylistDto.isPublic !== undefined
    ) {
      await playlist.update({
        name: updatePlaylistDto.name,
        description: updatePlaylistDto.description,
        coverImage: updatePlaylistDto.coverImage,
        isPublic: updatePlaylistDto.isPublic,
      });
    }

    // Update tracks if provided
    if (updatePlaylistDto.trackIds !== undefined) {
      // Remove all existing tracks
      await this.playlistTrackModel.destroy({
        where: { playlistId: id },
      });

      // Add new tracks
      for (const trackId of updatePlaylistDto.trackIds) {
        try {
          await this.musicService.findOne(trackId); // Verify track exists
          await this.playlistTrackModel.create({
            playlistId: id,
            trackId,
          });
        } catch (error) {
          // Skip tracks that don't exist
          console.warn(`Track with ID ${trackId} not found, skipping`);
        }
      }
    }

    // Return updated playlist with tracks
    return this.findOne(id);
  }

  async remove(id: string): Promise<void> {
    const playlist = await this.findOne(id);

    // Remove all playlist-track associations
    await this.playlistTrackModel.destroy({
      where: { playlistId: id },
    });

    // Remove the playlist
    await playlist.destroy();
  }

  async addTrack(playlistId: string, trackId: string): Promise<Playlist> {
    // Verify playlist and track exist
    await this.findOne(playlistId);
    await this.musicService.findOne(trackId);

    // Check if track is already in playlist
    const existing = await this.playlistTrackModel.findOne({
      where: {
        playlistId,
        trackId,
      },
    });

    if (!existing) {
      await this.playlistTrackModel.create({
        playlistId,
        trackId,
      });
    }

    // Return updated playlist
    return this.findOne(playlistId);
  }

  async removeTrack(playlistId: string, trackId: string): Promise<void> {
    // Verify playlist exists
    await this.findOne(playlistId);

    // Remove the track from playlist
    await this.playlistTrackModel.destroy({
      where: {
        playlistId,
        trackId,
      },
    });
  }
}
