import {
  BelongsTo,
  Column,
  CreatedAt,
  DataType,
  Default,
  ForeignKey,
  HasMany,
  Model,
  PrimaryKey,
  Table,
  UpdatedAt
} from "sequelize-typescript";
import { Track } from "../../music/models/track.model";
import { Playlist } from "../../playlists/models/playlist.model";
import { User } from "../../users/models/user.model";
import { SocialLink } from "./social-link.model";

@Table({ tableName: "artists", timestamps: true, paranoid: true })
export class Artist extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  id: string;

  @Column
  artistName: string;

  @Column({ allowNull: true, type: DataType.TEXT })
  bio: string;

  @Column({ allowNull: true })
  profileImageUrl: string;

  @Column({ allowNull: true })
  coverImageUrl: string;

  @Column
  primaryGenre: string;

  @Column({ allowNull: true })
  website: string;

  // Payment information
  @Column({ allowNull: true })
  paymentMethod: string;

  @Column({ allowNull: true })
  accountNumber: string;

  @Column({ allowNull: true })
  routingNumber: string;

  @Column({ allowNull: true })
  taxId: string;

  // Stats and metrics
  @Default(0)
  @Column
  totalStreams: number;

  @Default(0)
  @Column
  monthlyListeners: number;

  @Default(0)
  @Column
  followers: number;

  // Verification status
  @Default(false)
  @Column
  isVerified: boolean;

  // Featured status
  @Default(false)
  @Column
  isFeatured: boolean;

  // Relations
  @ForeignKey(() => User)
  @Column(DataType.UUID)
  userId: string;

  @BelongsTo(() => User)
  user: User;

  @HasMany(() => Track)
  tracks: Track[];

  @HasMany(() => SocialLink)
  socialLinks: SocialLink[];

  // @BelongsToMany(() => Playlist, () => ArtistGenre)
  // genres: ArtistGenre[];

  @HasMany(() => Playlist)
  playlists: Playlist[];

  @CreatedAt
  createdAt: Date;

  @UpdatedAt
  updatedAt: Date;
}
