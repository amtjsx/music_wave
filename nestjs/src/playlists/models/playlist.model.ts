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

  @Column({ type: DataType.STRING, allowNull: false })
  name: string;

  @Column({ type: DataType.STRING, allowNull: true })
  description: string;

  @Column({ type: DataType.STRING, allowNull: true })
  coverImage: string;

  @Column({ type: DataType.BOOLEAN, allowNull: true, defaultValue: false })
  isPublic: boolean;

  @Column({ type: DataType.BOOLEAN, allowNull: true, defaultValue: false })
  isFeatured: boolean;

  @ForeignKey(() => Artist)
  @Column({ type: DataType.UUID, allowNull: true })
  artistId: string;
  @BelongsTo(() => Artist)
  artist: Artist;

  @ForeignKey(() => User)
  @Column({ type: DataType.UUID, allowNull: true })
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
