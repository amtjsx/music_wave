import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { InjectModel } from "@nestjs/sequelize";
import { Sequelize } from "sequelize-typescript";
import { withTransaction } from "src/common/utils/transaction.util";
import { Track } from "../music/models/track.model";
import { User } from "../users/models/user.model";
import { CreateCommentDto } from "./dto/create-comment.dto";
import { QueryCommentsDto } from "./dto/query-comments.dto";
import { UpdateCommentDto } from "./dto/update-comment.dto";
import { Comment } from "./models/comment.model";

@Injectable()
export class CommentsService {
  constructor(
    @InjectModel(Comment)
    private readonly commentModel: typeof Comment,
    @InjectModel(Track)
    private readonly trackModel: typeof Track,
    @InjectModel(User)
    private readonly userModel: typeof User,
    @InjectModel(Sequelize)
    private readonly sequelize: Sequelize
  ) {}

  async findAll(queryDto: QueryCommentsDto) {
    const { trackId, userId, parentId, topLevelOnly, page, limit } = queryDto;

    // Build where conditions
    const where: any = {};

    if (trackId) {
      where.trackId = trackId;
    }

    if (userId) {
      where.userId = userId;
    }

    if (topLevelOnly) {
      where.parentId = null;
    } else if (parentId) {
      where.parentId = parentId;
    }

    // Calculate pagination
    const offset = (page - 1) * limit;

    // Get comments with count
    const { rows: comments, count: total } =
      await this.commentModel.findAndCountAll({
        where,
        include: [
          {
            model: this.userModel,
            attributes: ["id", "username", "avatarUrl"],
          },
        ],
        order: [["createdAt", "DESC"]],
        offset,
        limit,
      });

    // Calculate pagination metadata
    const totalPages = Math.ceil(total / limit);
    const hasNext = page < totalPages;
    const hasPrevious = page > 1;

    return {
      data: comments,
      meta: {
        total,
        page,
        limit,
        totalPages,
        hasNext,
        hasPrevious,
      },
    };
  }

  async findOne(id: string): Promise<Comment> {
    const comment = await this.commentModel.findByPk(id, {
      include: [
        {
          model: this.userModel,
          attributes: ["id", "username", "avatarUrl"],
        },
      ],
    });

    if (!comment) {
      throw new NotFoundException(`Comment with ID ${id} not found`);
    }

    return comment;
  }

  async create(
    userId: string,
    createCommentDto: CreateCommentDto
  ): Promise<Comment> {
    return withTransaction(this.sequelize, async (transaction) => {
      // Verify track exists
      const track = await this.trackModel.findByPk(createCommentDto.trackId, {
        transaction,
      });
      if (!track) {
        throw new NotFoundException(
          `Track with ID ${createCommentDto.trackId} not found`
        );
      }

      // Verify parent comment exists if provided
      if (createCommentDto.parentId) {
        const parentComment = await this.commentModel.findByPk(
          createCommentDto.parentId,
          { transaction }
        );
        if (!parentComment) {
          throw new NotFoundException(
            `Parent comment with ID ${createCommentDto.parentId} not found`
          );
        }

        // Ensure parent comment belongs to the same track
        if (parentComment.trackId !== createCommentDto.trackId) {
          throw new ForbiddenException(
            "Parent comment must belong to the same track"
          );
        }
      }

      // Create comment
      const comment = await this.commentModel.create(
        {
          ...createCommentDto,
          userId,
        },
        { transaction }
      );

      // Return comment with user info
      return this.commentModel.findByPk(comment.id, {
        include: [
          {
            model: this.userModel,
            attributes: ["id", "username", "avatarUrl"],
          },
        ],
        transaction,
      });
    });
  }

  async update(
    id: string,
    userId: string,
    updateCommentDto: UpdateCommentDto
  ): Promise<Comment> {
    return withTransaction(this.sequelize, async (transaction) => {
      const comment = await this.commentModel.findByPk(id, { transaction });

      if (!comment) {
        throw new NotFoundException(`Comment with ID ${id} not found`);
      }

      // Verify ownership
      if (comment.userId !== userId) {
        throw new ForbiddenException(
          "You do not have permission to update this comment"
        );
      }

      // Update comment
      await comment.update(
        {
          ...updateCommentDto,
          isEdited: true,
        },
        { transaction }
      );

      // Return updated comment with user info
      return this.commentModel.findByPk(id, {
        include: [
          {
            model: this.userModel,
            attributes: ["id", "username", "avatarUrl"],
          },
        ],
        transaction,
      });
    });
  }

  async remove(id: string, userId: string, isAdmin = false): Promise<void> {
    return withTransaction(this.sequelize, async (transaction) => {
      const comment = await this.commentModel.findByPk(id, { transaction });

      if (!comment) {
        throw new NotFoundException(`Comment with ID ${id} not found`);
      }

      // Verify ownership or admin status
      if (!isAdmin && comment.userId !== userId) {
        throw new ForbiddenException(
          "You do not have permission to delete this comment"
        );
      }

      // Delete comment
      await comment.destroy({ transaction });
    });
  }

  async likeComment(id: string): Promise<Comment> {
    return withTransaction(this.sequelize, async (transaction) => {
      const comment = await this.commentModel.findByPk(id, { transaction });

      if (!comment) {
        throw new NotFoundException(`Comment with ID ${id} not found`);
      }

      // Increment likes
      await comment.increment("likes", { transaction });

      // Return updated comment
      return this.commentModel.findByPk(id, {
        include: [
          {
            model: this.userModel,
            attributes: ["id", "username", "avatarUrl"],
          },
        ],
        transaction,
      });
    });
  }

  async getCommentReplies(
    commentId: string,
    page = 1,
    limit = 20
  ): Promise<any> {
    // Verify comment exists
    const comment = await this.findOne(commentId);

    // Get replies
    return this.findAll({
      parentId: commentId,
      page,
      limit,
    });
  }

  async getTrackComments(trackId: string, page = 1, limit = 20): Promise<any> {
    // Verify track exists
    const track = await this.trackModel.findByPk(trackId);
    if (!track) {
      throw new NotFoundException(`Track with ID ${trackId} not found`);
    }

    // Get top-level comments for the track
    return this.findAll({
      trackId,
      topLevelOnly: true,
      page,
      limit,
    });
  }
}
