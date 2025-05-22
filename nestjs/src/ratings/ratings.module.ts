import { Module } from "@nestjs/common"
import { SequelizeModule } from "@nestjs/sequelize"
import { RatingsController } from "./ratings.controller"
import { RatingsService } from "./ratings.service"
import { Rating } from "./models/rating.model"
import { Track } from "../music/models/track.model"
import { User } from "../users/models/user.model"

@Module({
  imports: [SequelizeModule.forFeature([Rating, Track, User])],
  controllers: [RatingsController],
  providers: [RatingsService],
  exports: [RatingsService],
})
export class RatingsModule {}
