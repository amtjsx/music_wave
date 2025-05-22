import { Module } from "@nestjs/common"
import { SequelizeModule } from "@nestjs/sequelize"
import { MusicController } from "./music.controller"
import { MusicService } from "./music.service"
import { Track } from "./models/track.model"
import { MulterModule } from "@nestjs/platform-express"
import { diskStorage } from "multer"
import { extname } from "path"
import { v4 as uuidv4 } from "uuid"

@Module({
  imports: [
    SequelizeModule.forFeature([Track]),
    MulterModule.register({
      storage: diskStorage({
        destination: (req, file, cb) => {
          if (file.fieldname === "audio") {
            cb(null, "./uploads/audio")
          } else if (file.fieldname === "coverArt") {
            cb(null, "./uploads/covers")
          } else {
            cb(null, "./uploads")
          }
        },
        filename: (req, file, cb) => {
          const uniqueSuffix = uuidv4()
          cb(null, `${uniqueSuffix}${extname(file.originalname)}`)
        },
      }),
      fileFilter: (req, file, cb) => {
        if (file.fieldname === "audio") {
          if (!file.originalname.match(/\.(mp3|wav|ogg|flac)$/)) {
            return cb(new Error("Only audio files are allowed!"), false)
          }
        } else if (file.fieldname === "coverArt") {
          if (!file.originalname.match(/\.(jpg|jpeg|png|gif)$/)) {
            return cb(new Error("Only image files are allowed!"), false)
          }
        }
        cb(null, true)
      },
    }),
  ],
  controllers: [MusicController],
  providers: [MusicService],
  exports: [MusicService],
})
export class MusicModule {}
