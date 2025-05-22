import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException,
} from "@nestjs/common";
import { Sequelize } from "sequelize-typescript";
import { Op } from "sequelize";
import { Rating } from "./models/rating.model";
import { Track } from "../music/models/track.model";
import { User } from "../users/models/user.model";
import { CreateRatingDto } from "./dto/create-rating.dto";
import { UpdateRatingDto } from "./dto/update-rating.dto";
import { QueryRatingsDto } from "./dto/query-ratings.dto";
import { withTransaction } from "../common/utils/transaction.util";
import { InjectModel } from "@nestjs/sequelize";

@Injectable()
export class RatingsService {
  constructor(
    @InjectModel(Rating)
    private ratingModel: typeof Rating,
    @InjectModel(Track)
    private trackModel: typeof Track,
    @InjectModel(User)
    private userModel: typeof User,
    private sequelize: Sequelize
  ) {}

  async findAll(queryDto: QueryRatingsDto) {
    const { trackId, userId, minValue, maxValue, page, limit } = queryDto;

    // Build where conditions
    const where: any = {};

    if (trackId) {
      where.trackId = trackId;
    }

    if (userId) {
      where.userId = userId;
    }

    // Add rating value range filter
    if (minValue !== undefined || maxValue !== undefined) {
      where.value = {};
      if (minValue !== undefined) {
        where.value[Op.gte] = minValue;
      }
      if (maxValue !== undefined) {
        where.value[Op.lte] = maxValue;
      }
    }

    // Calculate pagination
    const offset = (page - 1) * limit;

    // Get ratings with count
    const { rows: ratings, count: total } =
      await this.ratingModel.findAndCountAll({
        where,
        include: [
          {
            model: this.userModel,
            attributes: ["id", "username", "avatarUrl"],
          },
          {
            model: this.trackModel,
            attributes: ["id", "title", "artist", "coverArt"],
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
      data: ratings,
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

  async findOne(id: string): Promise<Rating> {
    const rating = await this.ratingModel.findByPk(id, {
      include: [
        {
          model: this.userModel,
          attributes: ["id", "username", "avatarUrl"],
        },
        {
          model: this.trackModel,
          attributes: ["id", "title", "artist", "coverArt"],
        },
      ],
    });

    if (!rating) {
      throw new NotFoundException(`Rating with ID ${id} not found`);
    }

    return rating;
  }

  async findUserRatingForTrack(
    userId: string,
    trackId: string
  ): Promise<Rating | null> {
    return this.ratingModel.findOne({
      where: {
        userId,
        trackId,
      },
      include: [
        {
          model: this.userModel,
          attributes: ["id", "username", "avatarUrl"],
        },
      ],
    });
  }

  async create(
    userId: string,
    createRatingDto: CreateRatingDto
  ): Promise<Rating> {
    return withTransaction(this.sequelize, async (transaction) => {
      // Verify track exists
      const track = await this.trackModel.findByPk(createRatingDto.trackId, {
        transaction,
      });
      if (!track) {
        throw new NotFoundException(
          `Track with ID ${createRatingDto.trackId} not found`
        );
      }

      // Check if user already rated this track
      const existingRating = await this.ratingModel.findOne({
        where: {
          userId,
          trackId: createRatingDto.trackId,
        },
        transaction,
      });

      if (existingRating) {
        throw new ConflictException(
          "You have already rated this track. Use PUT to update your rating."
        );
      }

      // Create rating
      const rating = await this.ratingModel.create(
        {
          ...createRatingDto,
          userId,
        },
        { transaction }
      );

      // Update track's average rating
      await this.updateTrackAverageRating(createRatingDto.trackId, transaction);

      // Return rating with user and track info
      return this.ratingModel.findByPk(rating.id, {
        include: [
          {
            model: this.userModel,
            attributes: ["id", "username", "avatarUrl"],
          },
          {
            model: this.trackModel,
            attributes: ["id", "title", "artist", "coverArt"],
          },
        ],
        transaction,
      });
    });
  }

  async update(
    id: string,
    userId: string,
    updateRatingDto: UpdateRatingDto
  ): Promise<Rating> {
    return withTransaction(this.sequelize, async (transaction) => {
      const rating = await this.ratingModel.findByPk(id, { transaction });

      if (!rating) {
        throw new NotFoundException(`Rating with ID ${id} not found`);
      }

      // Verify ownership
      if (rating.userId !== userId) {
        throw new ForbiddenException(
          "You do not have permission to update this rating"
        );
      }

      // Update rating
      await rating.update(updateRatingDto, { transaction });

      // Update track's average rating
      await this.updateTrackAverageRating(rating.trackId, transaction);

      // Return updated rating with user and track info
      return this.ratingModel.findByPk(id, {
        include: [
          {
            model: this.userModel,
            attributes: ["id", "username", "avatarUrl"],
          },
          {
            model: this.trackModel,
            attributes: ["id", "title", "artist", "coverArt"],
          },
        ],
        transaction,
      });
    });
  }

  async remove(id: string, userId: string, isAdmin = false): Promise<void> {
    return withTransaction(this.sequelize, async (transaction) => {
      const rating = await this.ratingModel.findByPk(id, { transaction });

      if (!rating) {
        throw new NotFoundException(`Rating with ID ${id} not found`);
      }

      // Verify ownership or admin status
      if (!isAdmin && rating.userId !== userId) {
        throw new ForbiddenException(
          "You do not have permission to delete this rating"
        );
      }

      // Store trackId before deleting
      const trackId = rating.trackId;

      // Delete rating
      await rating.destroy({ transaction });

      // Update track's average rating
      await this.updateTrackAverageRating(trackId, transaction);
    });
  }

  async getTrackRatings(trackId: string, page = 1, limit = 20): Promise<any> {
    // Verify track exists
    const track = await this.trackModel.findByPk(trackId);
    if (!track) {
      throw new NotFoundException(`Track with ID ${trackId} not found`);
    }

    // Get ratings for the track
    return this.findAll({
      trackId,
      page,
      limit,
    });
  }

  async getTrackRatingStats(trackId: string): Promise<any> {
    // Verify track exists
    const track = await this.trackModel.findByPk(trackId);
    if (!track) {
      throw new NotFoundException(`Track with ID ${trackId} not found`);
    }

    // Get all ratings for the track
    const ratings = await this.ratingModel.findAll({
      where: { trackId },
      attributes: ["value"],
    });

    if (ratings.length === 0) {
      return {
        trackId,
        averageRating: 0,
        totalRatings: 0,
        distribution: {
          1: 0,
          2: 0,
          3: 0,
          4: 0,
          5: 0,
        },
      };
    }

    // Calculate average rating
    const sum = ratings.reduce((acc, rating) => acc + rating.value, 0);
    const averageRating = sum / ratings.length;

    // Calculate rating distribution
    const distribution = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };

    ratings.forEach((rating) => {
      distribution[Math.round(rating.value)]++;
    });

    return {
      trackId,
      averageRating,
      totalRatings: ratings.length,
      distribution,
    };
  }

  // Helper method to update a track's average rating
  private async updateTrackAverageRating(
    trackId: string,
    transaction: any
  ): Promise<void> {
    // Get all ratings for the track
    const ratings = await this.ratingModel.findAll({
      where: { trackId },
      attributes: ["value"],
      transaction,
    });

    // Calculate average rating
    let averageRating = 0;
    if (ratings.length > 0) {
      const sum = ratings.reduce((acc, rating) => acc + rating.value, 0);
      averageRating = sum / ratings.length;
    }

    // Update track with average rating
    await this.trackModel.update(
      { averageRating, ratingCount: ratings.length },
      {
        where: { id: trackId },
        transaction,
      }
    );
  }
}
