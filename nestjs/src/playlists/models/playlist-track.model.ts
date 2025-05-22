import {
  Table,
  Column,
  Model,
  ForeignKey,
  DataType,
} from "sequelize-typescript";
import { Playlist } from "./playlist.model";
import { Track } from "../../music/models/track.model";

@Table({
  tableName: "playlist_tracks",
  timestamps: false,
  paranoid: true,
})
export class PlaylistTrack extends Model {
  @ForeignKey(() => Playlist)
  @Column(DataType.UUID)
  playlistId: string;

  @ForeignKey(() => Track)
  @Column(DataType.UUID)
  trackId: string;
}
