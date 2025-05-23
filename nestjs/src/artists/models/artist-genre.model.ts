import {
  Column,
  DataType,
  Default,
  ForeignKey,
  Model,
  PrimaryKey,
  Table,
} from "sequelize-typescript";
import { Artist } from "./artist.model";

@Table({ tableName: "artist_genres", timestamps: true, paranoid: true })
export class ArtistGenre extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  id: string;

  @ForeignKey(() => Artist)
  @Column(DataType.UUID)
  artistId: string;

  @Column({ type: DataType.STRING, allowNull: true })
  genre: string;

  @Default(false)
  @Column({ type: DataType.BOOLEAN, allowNull: true })
  isPrimary: boolean;
}
