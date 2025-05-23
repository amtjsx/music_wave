import {
  BelongsTo,
  BelongsToMany,
  Column,
  CreatedAt,
  DataType,
  ForeignKey,
  HasMany,
  Model,
  Table,
  UpdatedAt
} from "sequelize-typescript";
import { Artist } from "../../artists/models/artist.model";
import { Comment } from "../../comments/models/comment.model";
import { PlaylistTrack } from "../../playlists/models/playlist-track.model";
import { Playlist } from "../../playlists/models/playlist.model";
import { Rating } from "../../ratings/models/rating.model";

@Table({ tableName: "tracks", timestamps: true, paranoid: true })
export class Track extends Model {
  @Column({
    type: DataType.UUID,
    primaryKey: true,
    defaultValue: DataType.UUIDV4,
  })
  id: string;

  @Column({ type: DataType.STRING, allowNull: false })
  title: string;

  @Column({ type: DataType.STRING, allowNull: true })
  album: string;

  @Column({ type: DataType.STRING, allowNull: true })
  genre: string;

  @Column({ type: DataType.INTEGER, allowNull: true })
  year: number;

  @Column({ type: DataType.INTEGER, allowNull: true })
  duration: number;

  @Column({ type: DataType.STRING, allowNull: true })
  filename: string;

  @Column({ type: DataType.STRING, allowNull: true })
  audioSrc: string;

  @Column({ type: DataType.STRING, allowNull: true })
  coverArt: string;

  @Column({ type: DataType.INTEGER, allowNull: true })
  playCount: number;

  @Column({ type: DataType.FLOAT, allowNull: true })
  averageRating: number;

  @Column({ type: DataType.INTEGER, allowNull: true })
  ratingCount: number;

  @BelongsToMany(() => Playlist, () => PlaylistTrack)
  playlists: Playlist[];

  @ForeignKey(() => Artist)
  @Column(DataType.UUID)
  artistId: string;

  @BelongsTo(() => Artist)
  artist: Artist;

  @HasMany(() => Comment)
  comments: Comment[];

  @HasMany(() => Rating)
  ratings: Rating[];

  @CreatedAt
  createdAt: Date;

  @UpdatedAt
  updatedAt: Date;
}
