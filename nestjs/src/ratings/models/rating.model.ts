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
  Unique,
} from "sequelize-typescript"
import { Track } from "../../music/models/track.model"
import { User } from "../../users/models/user.model"

@Table
export class Rating extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  id: string

  @Column({
    type: DataType.FLOAT,
    allowNull: false,
    validate: {
      min: 1,
      max: 5,
    },
  })
  value: number

  @Column({ type: DataType.TEXT, allowNull: true })
  review: string

  @ForeignKey(() => Track)
  @Column(DataType.UUID)
  trackId: string

  @BelongsTo(() => Track)
  track: Track

  @ForeignKey(() => User)
  @Column(DataType.UUID)
  userId: string

  @BelongsTo(() => User)
  user: User

  @CreatedAt
  createdAt: Date

  @UpdatedAt
  updatedAt: Date

  // Ensure a user can only rate a track once
  @Unique("user_track_unique")
  userTrackIndex: string
}
