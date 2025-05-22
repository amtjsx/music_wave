import { Injectable } from "@nestjs/common"

@Injectable()
export class AppService {
  getHello(): { message: string; docs: string } {
    return {
      message: "Welcome to the Music API!",
      docs: "Go to /api for Swagger documentation.",
    }
  }
}
