import { Module } from "@nestjs/common"
import { SequelizeModule } from "@nestjs/sequelize"
import { UsersController } from "./users.controller"
import { UsersService } from "./users.service"
import { User } from "./models/user.model"
import { SocialLink } from "../artists/models/social-link.model"

@Module({
  imports: [SequelizeModule.forFeature([User, SocialLink])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
