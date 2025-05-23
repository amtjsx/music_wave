import {
  BelongsTo,
  Column,
  CreatedAt,
  DataType,
  ForeignKey,
  HasMany,
  Model,
  Table,
  UpdatedAt
} from "sequelize-typescript";
import { Track } from "../../music/models/track.model";
import { Playlist } from "../../playlists/models/playlist.model";
import { User } from "../../users/models/user.model";
import { SocialLink } from "./social-link.model";

@Table({ tableName: "artists", timestamps: true, paranoid: true })
export class Artist extends Model {
  @Column({
    type: DataType.UUID,
    primaryKey: true,
    defaultValue: DataType.UUIDV4,
  })
  id: string;

  @Column({ type: DataType.STRING, allowNull: false })
  artistName: string;

  @Column({ allowNull: true, type: DataType.TEXT })
  bio: string;

  @Column({ type: DataType.STRING, allowNull: true })
  profileImageUrl: string;

  @Column({ type: DataType.STRING, allowNull: true })
  coverImageUrl: string;

  @Column({ type: DataType.STRING, allowNull: true })
  primaryGenre: string;

  @Column({ type: DataType.STRING, allowNull: true })
  website: string;

  // Payment information
  @Column({ type: DataType.STRING, allowNull: true })
  paymentMethod: string;

  @Column({ type: DataType.STRING, allowNull: true })
  accountNumber: string;

  @Column({ type: DataType.STRING, allowNull: true })
  routingNumber: string;

  @Column({ type: DataType.STRING, allowNull: true })
  taxId: string;

  // Stats and metrics
  @Column({ type: DataType.INTEGER, allowNull: true })
  totalStreams: number;

  @Column({ type: DataType.INTEGER, allowNull: true })
  monthlyListeners: number;

  @Column({ type: DataType.INTEGER, allowNull: true })
  followers: number;

  // Verification status
  @Column({ type: DataType.BOOLEAN, allowNull: true })
  isVerified: boolean;

  // Featured status
  @Column({ type: DataType.BOOLEAN, allowNull: true })
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
