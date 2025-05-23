import {
  BelongsTo,
  Column,
  CreatedAt,
  DataType,
  ForeignKey,
  Model,
  Table,
  UpdatedAt
} from "sequelize-typescript";
import { Track } from "../../music/models/track.model";
import { User } from "../../users/models/user.model";

@Table({ tableName: "ratings", timestamps: true, paranoid: true })
export class Rating extends Model {
  @Column({
    type: DataType.UUID,
    primaryKey: true,
    defaultValue: DataType.UUIDV4,
  })
  id: string;

  @Column({ type: DataType.FLOAT, allowNull: false })
  value: number;

  @Column({ type: DataType.TEXT, allowNull: true })
  review: string;

  @ForeignKey(() => Track)
  @Column(DataType.UUID)
  trackId: string;

  @BelongsTo(() => Track)
  track: Track;

  @ForeignKey(() => User)
  @Column(DataType.UUID)
  userId: string;

  @BelongsTo(() => User)
  user: User;

  @CreatedAt
  createdAt: Date;

  @UpdatedAt
  updatedAt: Date;
}
