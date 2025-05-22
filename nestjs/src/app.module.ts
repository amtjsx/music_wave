import { Module } from "@nestjs/common";
import { ConfigModule, ConfigService } from "@nestjs/config";
import { ServeStaticModule } from "@nestjs/serve-static";
import { join } from "path";
import { SequelizeModule } from "@nestjs/sequelize";
import { AppController } from "./app.controller";
import { AppService } from "./app.service";
import { MusicModule } from "./music/music.module";
import { PlaylistsModule } from "./playlists/playlists.module";
import { UsersModule } from "./users/users.module";
import { AuthModule } from "./auth/auth.module";
import { ArtistsModule } from './artists/artists.module';
import { CommentsModule } from './comments/comments.module';
import { RatingsModule } from './ratings/ratings.module';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
    }),

    // Database with Sequelize
    SequelizeModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        dialect: "mysql",
        host: configService.get<string>("DATABASE_HOST", "localhost"),
        port: configService.get<number>("DATABASE_PORT", 3306),
        username: configService.get<string>("DATABASE_USER", "root"),
        password: configService.get<string>("DATABASE_PASSWORD", ""),
        database: configService.get<string>("DATABASE_NAME", "music-api"),
        autoLoadModels: true,
        synchronize: configService.get<boolean>("DATABASE_SYNC", true),
        logging: configService.get<string>("NODE_ENV") !== "production",
        define: {
          timestamps: true,
          underscored: true,
        },
      }),
    }),

    // Static file serving
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, "..", "uploads"),
      serveRoot: "/uploads",
    }),

    // Feature modules
    MusicModule,
    PlaylistsModule,
    UsersModule,
    AuthModule,
    ArtistsModule,
    CommentsModule,
    RatingsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
