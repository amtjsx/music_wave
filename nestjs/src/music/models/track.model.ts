import {
  Table,
  Column,
  Model,
  PrimaryKey,
  DataType,
  CreatedAt,
  UpdatedAt,
  Default,
  BelongsToMany,
  ForeignKey,
  BelongsTo,
  HasMany,
} from "sequelize-typescript";
import { Playlist } from "../../playlists/models/playlist.model";
import { PlaylistTrack } from "../../playlists/models/playlist-track.model";
import { Artist } from "../../artists/models/artist.model";
import { Comment } from "../../comments/models/comment.model";
import { Rating } from "../../ratings/models/rating.model";

@Table
export class Track extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  id: string;

  @Column
  title: string;

  @Column({ allowNull: true })
  album: string;

  @Column({ allowNull: true })
  genre: string;

  @Column({ allowNull: true })
  year: number;

  @Column({ allowNull: true })
  duration: number;

  @Column
  filename: string;

  @Column
  audioSrc: string;

  @Column({ allowNull: true })
  coverArt: string;

  @Default(0)
  @Column
  playCount: number;

  @Default(0)
  @Column(DataType.FLOAT)
  averageRating: number;

  @Default(0)
  @Column
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
