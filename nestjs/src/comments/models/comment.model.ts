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
import { Track } from "../../music/models/track.model"
import { User } from "../../users/models/user.model"

@Table
export class Comment extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  id: string

  @Column(DataType.TEXT)
  content: string

  @Default(false)
  @Column
  isEdited: boolean

  @Default(0)
  @Column
  likes: number

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

  @ForeignKey(() => Comment)
  @Column({ type: DataType.UUID, allowNull: true })
  parentId: string

  @BelongsTo(() => Comment)
  parent: Comment

  @CreatedAt
  createdAt: Date

  @UpdatedAt
  updatedAt: Date
}
