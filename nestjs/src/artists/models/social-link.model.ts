import {
  BelongsTo,
  Column,
  DataType,
  Default,
  ForeignKey,
  Model,
  PrimaryKey,
  Table,
} from "sequelize-typescript";
import { User } from "../../users/models/user.model";
import { Artist } from "./artist.model";

export enum SocialPlatform {
  INSTAGRAM = "instagram",
  TWITTER = "twitter",
  YOUTUBE = "youtube",
  SPOTIFY = "spotify",
  SOUNDCLOUD = "soundcloud",
  TIKTOK = "tiktok",
  FACEBOOK = "facebook",
  BANDCAMP = "bandcamp",
  APPLE_MUSIC = "apple_music",
  OTHER = "other",
}

@Table({
  tableName: "social_links",
  timestamps: true,
  paranoid: true,
})
export class SocialLink extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  id: string;

  @Column({
    type: DataType.ENUM(...Object.values(SocialPlatform)),
  })
  platform: SocialPlatform;

  @Column({ type: DataType.STRING, allowNull: false })
  url: string;

  @Column({ type: DataType.STRING, allowNull: true })
  username: string;

  @ForeignKey(() => Artist)
  @Column({ type: DataType.UUID, allowNull: true })
  artistId: string;

  @BelongsTo(() => Artist)
  artist: Artist;

  @ForeignKey(() => User)
  @Column({ type: DataType.UUID, allowNull: true })
  userId: string;

  @BelongsTo(() => User)
  user: User;

  @Column({
    type: DataType.DATE,
    allowNull: false,
    defaultValue: DataType.NOW,
  })
  createdAt: Date;

  @Column({
    type: DataType.DATE,
    allowNull: false,
    defaultValue: DataType.NOW,
  })
  updatedAt: Date;
}
