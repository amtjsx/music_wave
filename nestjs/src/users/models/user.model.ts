import {
  Table,
  Column,
  Model,
  PrimaryKey,
  DataType,
  CreatedAt,
  UpdatedAt,
  Default,
  HasMany,
  BeforeCreate,
  BeforeBulkCreate,
  BeforeUpdate,
} from "sequelize-typescript";
import * as bcrypt from "bcrypt";
import { Playlist } from "../../playlists/models/playlist.model";
import { SocialLink } from "../../artists/models/social-link.model";
import { Comment } from "../../comments/models/comment.model";
import { Rating } from "../../ratings/models/rating.model";
import { Role } from "../enums/role.enum";

@Table({ tableName: "users", timestamps: true, paranoid: true })
export class User extends Model {
  @Column({
    type: DataType.UUID,
    primaryKey: true,
    defaultValue: DataType.UUIDV4,
  })
  id: string;

  @Column({ unique: true })
  email: string;

  @Column({ type: DataType.STRING, allowNull: false })
  password: string;

  @Column({ type: DataType.STRING, allowNull: false })
  username: string;

  @Column({ type: DataType.STRING, allowNull: true })
  fullName: string;

  @Column({ type: DataType.STRING, allowNull: true })
  avatarUrl: string;

  @Column(DataType.ARRAY(DataType.STRING))
  roles: Role[];

  @HasMany(() => Playlist)
  playlists: Playlist[];

  @HasMany(() => SocialLink)
  socialLinks: SocialLink[];

  @HasMany(() => Comment)
  comments: Comment[];

  @HasMany(() => Rating)
  ratings: Rating[];

  @CreatedAt
  createdAt: Date;

  @UpdatedAt
  updatedAt: Date;

  @BeforeCreate
  @BeforeBulkCreate
  static async hashPasswordBeforeCreate(instance: User | User[]) {
    if (Array.isArray(instance)) {
      for (const user of instance) {
        user.password = await bcrypt.hash(user.password, 10);
      }
    } else {
      instance.password = await bcrypt.hash(instance.password, 10);
    }
  }

  @BeforeUpdate
  static async hashPasswordBeforeUpdate(instance: User) {
    // Only hash the password if it has been changed
    if (instance.changed("password")) {
      instance.password = await bcrypt.hash(instance.password, 10);
    }
  }

  async validatePassword(password: string): Promise<boolean> {
    return bcrypt.compare(password, this.password);
  }
}
