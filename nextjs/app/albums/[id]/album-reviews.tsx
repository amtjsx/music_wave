"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { Star, ThumbsUp } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { TrustScoreBadge } from "@/components/trust-score-badge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

interface User {
  id: string;
  name: string;
  trustScore: number;
  avatarUrl: string;
}

interface Review {
  id: string;
  user: User;
  rating: number;
  text: string;
  date: string;
  likes: number;
}

interface AlbumReviewsProps {
  reviews: Review[];
  albumId: string;
}

export function AlbumReviews({ reviews, albumId }: AlbumReviewsProps) {
  const [showReviewForm, setShowReviewForm] = useState(false);
  const [reviewText, setReviewText] = useState("");
  const [rating, setRating] = useState("5");

  // Format date to be more readable
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h3 className="text-xl font-semibold">Reviews</h3>
        <Button
          variant="outline"
          onClick={() => setShowReviewForm(!showReviewForm)}
        >
          {showReviewForm ? "Cancel" : "Write a Review"}
        </Button>
      </div>

      {showReviewForm && (
        <div className="space-y-4 p-4 border rounded-md">
          <div className="flex items-center justify-between">
            <h4 className="font-medium">Write your review</h4>
            <div className="flex items-center gap-2">
              <span className="text-sm text-muted-foreground">Rating:</span>
              <Select value={rating} onValueChange={setRating}>
                <SelectTrigger className="w-[100px]">
                  <SelectValue placeholder="Rating" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="5">
                    <div className="flex items-center">
                      <span className="mr-2">5</span>
                      {Array(5)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 fill-primary text-primary"
                          />
                        ))}
                    </div>
                  </SelectItem>
                  <SelectItem value="4">
                    <div className="flex items-center">
                      <span className="mr-2">4</span>
                      {Array(4)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 fill-primary text-primary"
                          />
                        ))}
                      {Array(1)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 text-muted-foreground"
                          />
                        ))}
                    </div>
                  </SelectItem>
                  <SelectItem value="3">
                    <div className="flex items-center">
                      <span className="mr-2">3</span>
                      {Array(3)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 fill-primary text-primary"
                          />
                        ))}
                      {Array(2)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 text-muted-foreground"
                          />
                        ))}
                    </div>
                  </SelectItem>
                  <SelectItem value="2">
                    <div className="flex items-center">
                      <span className="mr-2">2</span>
                      {Array(2)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 fill-primary text-primary"
                          />
                        ))}
                      {Array(3)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 text-muted-foreground"
                          />
                        ))}
                    </div>
                  </SelectItem>
                  <SelectItem value="1">
                    <div className="flex items-center">
                      <span className="mr-2">1</span>
                      {Array(1)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 fill-primary text-primary"
                          />
                        ))}
                      {Array(4)
                        .fill(0)
                        .map((_, i) => (
                          <Star
                            key={i}
                            className="h-4 w-4 text-muted-foreground"
                          />
                        ))}
                    </div>
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
          <Textarea
            placeholder="Share your thoughts about this album..."
            value={reviewText}
            onChange={(e) => setReviewText(e.target.value)}
            rows={4}
          />
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => {
                setShowReviewForm(false);
                setReviewText("");
                setRating("5");
              }}
            >
              Cancel
            </Button>
            <Button
              onClick={() => {
                // This would normally submit the review to an API
                alert("Review submitted!");
                setShowReviewForm(false);
                setReviewText("");
                setRating("5");
              }}
            >
              Submit Review
            </Button>
          </div>
        </div>
      )}

      <div className="space-y-6">
        {reviews.map((review) => (
          <div key={review.id} className="space-y-2">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="relative h-10 w-10 rounded-full overflow-hidden">
                  <Image
                    src={review.user.avatarUrl || "/placeholder.svg"}
                    alt={review.user.name}
                    fill
                    className="object-cover"
                  />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <Link
                      href={`/profile/${review.user.id}`}
                      className="font-medium hover:text-primary transition-colors"
                    >
                      {review.user.name}
                    </Link>
                    <TrustScoreBadge score={review.user.trustScore} size="sm" />
                  </div>
                  <div className="text-sm text-muted-foreground">
                    {formatDate(review.date)}
                  </div>
                </div>
              </div>
              <div className="flex items-center">
                {Array(5)
                  .fill(0)
                  .map((_, i) => (
                    <Star
                      key={i}
                      className={`h-4 w-4 ${
                        i < review.rating
                          ? "fill-primary text-primary"
                          : "text-muted-foreground"
                      }`}
                    />
                  ))}
              </div>
            </div>
            <p className="text-muted-foreground">{review.text}</p>
            <div className="flex items-center gap-2">
              <Button variant="ghost" size="sm" className="gap-1 h-8">
                <ThumbsUp className="h-4 w-4" />
                <span>{review.likes}</span>
              </Button>
              <Button variant="ghost" size="sm" className="h-8">
                Reply
              </Button>
            </div>
          </div>
        ))}
      </div>

      <Button variant="outline" className="w-full">
        Load More Reviews
      </Button>
    </div>
  );
}
