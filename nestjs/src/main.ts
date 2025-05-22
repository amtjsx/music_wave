import { NestFactory } from "@nestjs/core";
import { AppModule } from "./app.module";
import { ValidationPipe } from "@nestjs/common";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import { ConfigService } from "@nestjs/config";
import * as fs from "fs";
import * as path from "path";

async function bootstrap() {
  // Create the NestJS application
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Enable CORS
  app.enableCors({
    origin: configService.get<string>("FRONTEND_URL"),
    credentials: true,
  });

  // Ensure upload directories exist
  const uploadsDir = path.join(process.cwd(), "uploads");
  const audioDir = path.join(uploadsDir, "audio");
  const coverDir = path.join(uploadsDir, "covers");
  [uploadsDir, audioDir, coverDir].forEach((dir) => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  });

  // Set up global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    })
  );

  // Set up Swagger documentation
  const config = new DocumentBuilder()
    .setTitle("Music API")
    .setDescription("API for serving and managing music files")
    .setVersion("1.0")
    .addTag("music")
    .addTag("playlists")
    .addTag("users")
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api", app, document);

  // Start the server
  const port = configService.get<number>("PORT", 5001);
  await app.listen(port);
  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();
