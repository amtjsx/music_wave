import { Injectable } from "@nestjs/common"
import { JwtService } from "@nestjs/jwt"
import { UsersService } from "../users/users.service"
import { CreateUserDto } from "../users/dto/create-user.dto"

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(email: string, password: string): Promise<any> {
    try {
      const user = await this.usersService.findByEmail(email)
      const isPasswordValid = await user.validatePassword(password)

      if (isPasswordValid) {
        const { password, ...result } = user.toJSON()
        return result
      }

      return null
    } catch (error) {
      return null
    }
  }

  async login(user: any) {
    const payload = { email: user.email, sub: user.id, roles: user.roles }

    return {
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
        roles: user.roles,
      },
      accessToken: this.jwtService.sign(payload),
    }
  }

  async register(createUserDto: CreateUserDto) {
    const user = await this.usersService.create(createUserDto)

    return {
      message: "User registered successfully",
      user: {
        id: user.id,
        email: user.email,
        username: user.username,
      },
    }
  }
}
