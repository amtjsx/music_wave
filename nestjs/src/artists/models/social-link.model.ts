import {
  Table,
  Column,
  Model,
  PrimaryKey,
  DataType,
  CreatedAt,
  UpdatedAt,
  Default,
  ForeignKey,
  BelongsTo,
} from "sequelize-typescript"
import { Artist } from "./artist.model"
import { User } from "../../users/models/user.model"

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
  id: string

  @Column({
    type: DataType.ENUM(...Object.values(SocialPlatform)),
  })
  platform: SocialPlatform

  @Column
  url: string

  @Column({ allowNull: true })
  username: string

  @ForeignKey(() => Artist)
  @Column({ type: DataType.UUID, allowNull: true })
  artistId: string

  @BelongsTo(() => Artist)
  artist: Artist

  @ForeignKey(() => User)
  @Column({ type: DataType.UUID, allowNull: true })
  userId: string

  @BelongsTo(() => User)
  user: User

  @CreatedAt
  createdAt: Date

  @UpdatedAt
  updatedAt: Date
}
