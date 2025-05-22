import {
  Table,
  Column,
  Model,
  DataType,
  CreatedAt,
  UpdatedAt,
  Default,
  BelongsToMany,
  ForeignKey,
  BelongsTo,
} from "sequelize-typescript";
import { Track } from "../../music/models/track.model";
import { User } from "../../users/models/user.model";
import { PlaylistTrack } from "./playlist-track.model";
import { Artist } from "src/artists/models/artist.model";

@Table({
  tableName: "playlists",
  timestamps: true,
  paranoid: true,
})
export class Playlist extends Model {
  @Column({
    type: DataType.UUID,
    primaryKey: true,
    defaultValue: DataType.UUIDV4,
  })
  id: string;

  @Column
  name: string;

  @Column({ allowNull: true })
  description: string;

  @Column({ allowNull: true })
  coverImage: string;

  @Default(false)
  @Column
  isPublic: boolean;

  @ForeignKey(() => Artist)
  @Column(DataType.UUID)
  artistId: string;
  @BelongsTo(() => Artist)
  artist: Artist;

  @ForeignKey(() => User)
  @Column(DataType.UUID)
  ownerId: string;
  @BelongsTo(() => User)
  owner: User;

  @BelongsToMany(() => Track, () => PlaylistTrack)
  tracks: Track[];

  @CreatedAt
  createdAt: Date;

  @UpdatedAt
  updatedAt: Date;
}
