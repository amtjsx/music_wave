import { Module } from "@nestjs/common"
import { SequelizeModule } from "@nestjs/sequelize"
import { ArtistsController } from "./artists.controller"
import { ArtistsService } from "./artists.service"
import { Artist } from "./models/artist.model"
import { SocialLink } from "./models/social-link.model"
import { ArtistGenre } from "./models/artist-genre.model"

@Module({
  imports: [SequelizeModule.forFeature([Artist, SocialLink, ArtistGenre])],
  controllers: [ArtistsController],
  providers: [ArtistsService],
  exports: [ArtistsService],
})
export class ArtistsModule {}
