import { Module } from "@nestjs/common"
import { SequelizeModule } from "@nestjs/sequelize"
import { CommentsController } from "./comments.controller"
import { CommentsService } from "./comments.service"
import { Comment } from "./models/comment.model"
import { Track } from "../music/models/track.model"
import { User } from "../users/models/user.model"

@Module({
  imports: [SequelizeModule.forFeature([Comment, Track, User])],
  controllers: [CommentsController],
  providers: [CommentsService],
  exports: [CommentsService],
})
export class CommentsModule {}
