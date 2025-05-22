import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from "@nestjs/common";
import { User } from "./models/user.model";
import { CreateUserDto } from "./dto/create-user.dto";
import { UpdateUserDto } from "./dto/update-user.dto";
import { Role } from "./enums/role.enum";
import { SocialLink } from "../artists/models/social-link.model";
import {
  CreateSocialLinkDto,
  UpdateSocialLinkDto,
} from "./dto/social-link.dto";
import { InjectModel } from "@nestjs/sequelize";

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User)
    private userModel: typeof User,
    @InjectModel(SocialLink)
    private socialLinkModel: typeof SocialLink
  ) {}

  async findAll(): Promise<User[]> {
    return this.userModel.findAll({
      attributes: { exclude: ["password"] },
      include: [SocialLink],
    });
  }

  async findOne(id: string): Promise<User> {
    const user = await this.userModel.findByPk(id, {
      attributes: { exclude: ["password"] },
      include: [SocialLink],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return user;
  }

  async findByEmail(email: string): Promise<User> {
    const user = await this.userModel.findOne({
      where: { email },
      include: [SocialLink],
    });

    if (!user) {
      throw new NotFoundException(`User with email ${email} not found`);
    }

    return user;
  }

  async create(createUserDto: CreateUserDto): Promise<User> {
    // Check if email already exists
    const existingEmail = await this.userModel.findOne({
      where: { email: createUserDto.email },
    });

    if (existingEmail) {
      throw new ConflictException("Email already exists");
    }

    // Check if username already exists
    const existingUsername = await this.userModel.findOne({
      where: { username: createUserDto.username },
    });

    if (existingUsername) {
      throw new ConflictException("Username already exists");
    }

    // Create user with default role
    const user = await this.userModel.create({
      ...createUserDto,
      roles: [Role.USER],
    });

    // Return user without password
    const { password, ...result } = user.toJSON();
    return result as User;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id);

    // Check if email is being changed and already exists
    if (updateUserDto.email && updateUserDto.email !== user.email) {
      const existingUser = await this.userModel.findOne({
        where: { email: updateUserDto.email },
      });

      if (existingUser) {
        throw new ConflictException("Email already exists");
      }
    }

    // Check if username is being changed and already exists
    if (updateUserDto.username && updateUserDto.username !== user.username) {
      const existingUsername = await this.userModel.findOne({
        where: { username: updateUserDto.username },
      });

      if (existingUsername) {
        throw new ConflictException("Username already exists");
      }
    }

    // Update user
    await user.update(updateUserDto);

    // Return updated user without password
    const { password, ...result } = user.toJSON();
    return result as User;
  }

  async remove(id: string): Promise<void> {
    const user = await this.findOne(id);

    // Delete user's social links
    await this.socialLinkModel.destroy({
      where: { userId: id },
    });

    await user.destroy();
  }

  // Social Links Methods
  async getUserSocialLinks(userId: string): Promise<SocialLink[]> {
    // Verify user exists
    await this.findOne(userId);

    return this.socialLinkModel.findAll({
      where: { userId },
    });
  }

  async addUserSocialLink(
    userId: string,
    createSocialLinkDto: CreateSocialLinkDto
  ): Promise<SocialLink> {
    // Verify user exists
    await this.findOne(userId);

    // Create social link
    const socialLink = await this.socialLinkModel.create({
      ...createSocialLinkDto,
      userId,
    });

    return socialLink;
  }

  async updateUserSocialLink(
    userId: string,
    linkId: string,
    updateSocialLinkDto: UpdateSocialLinkDto
  ): Promise<SocialLink> {
    // Find the social link
    const socialLink = await this.socialLinkModel.findByPk(linkId);

    if (!socialLink) {
      throw new NotFoundException(`Social link with ID ${linkId} not found`);
    }

    // Verify ownership
    if (socialLink.userId !== userId) {
      throw new ForbiddenException(
        "You do not have permission to update this social link"
      );
    }

    // Update social link
    await socialLink.update(updateSocialLinkDto);

    return socialLink;
  }

  async removeUserSocialLink(userId: string, linkId: string): Promise<void> {
    // Find the social link
    const socialLink = await this.socialLinkModel.findByPk(linkId);

    if (!socialLink) {
      throw new NotFoundException(`Social link with ID ${linkId} not found`);
    }

    // Verify ownership
    if (socialLink.userId !== userId) {
      throw new ForbiddenException(
        "You do not have permission to delete this social link"
      );
    }

    // Delete social link
    await socialLink.destroy();
  }
}
