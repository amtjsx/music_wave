import { Module } from "@nestjs/common"
import { SequelizeModule } from "@nestjs/sequelize"
import { PlaylistsController } from "./playlists.controller"
import { PlaylistsService } from "./playlists.service"
import { Playlist } from "./models/playlist.model"
import { PlaylistTrack } from "./models/playlist-track.model"
import { MusicModule } from "../music/music.module"

@Module({
  imports: [SequelizeModule.forFeature([Playlist, PlaylistTrack]), MusicModule],
  controllers: [PlaylistsController],
  providers: [PlaylistsService],
  exports: [PlaylistsService],
})
export class PlaylistsModule {}
