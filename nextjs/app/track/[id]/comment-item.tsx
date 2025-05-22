"use client";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { VerifiedBadge } from "@/components/verified-badge";
import {
  Flag,
  MessageSquare,
  MoreVertical,
  ThumbsUp,
  Trash,
} from "lucide-react";
import { TrustScoreBadge } from "./trust-score-badge";

interface CommentItemProps {
  id: string;
  user: {
    id: string;
    name: string;
    username: string;
    avatar: string;
    isVerified?: boolean;
    trustScore: number;
  };
  content: string;
  timestamp: string;
  likes: number;
  isLiked?: boolean;
  isAuthor?: boolean;
  onLike?: (id: string) => void;
  onReply?: (id: string) => void;
  onReport?: (id: string) => void;
  onDelete?: (id: string) => void;
  replies?: CommentItemProps[];
  showReplies?: boolean;
}

export function CommentItem({
  id,
  user,
  content,
  timestamp,
  likes,
  isLiked = false,
  isAuthor = false,
  onLike,
  onReply,
  onReport,
  onDelete,
  replies = [],
  showReplies = true,
}: CommentItemProps) {
  return (
    <div className="space-y-4">
      <div className="flex gap-3">
        <Avatar className="h-10 w-10">
          <AvatarImage
            src={user.avatar || "/placeholder.svg"}
            alt={user.name}
          />
          <AvatarFallback>{user.name.charAt(0)}</AvatarFallback>
        </Avatar>

        <div className="flex-1 space-y-1.5">
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1.5">
              <span className="font-semibold">{user.name}</span>
              {user.isVerified && <VerifiedBadge size="sm" />}
              <TrustScoreBadge score={user.trustScore} size="sm" />
            </div>
            <span className="text-xs text-muted-foreground">
              @{user.username}
            </span>
            <span className="text-xs text-muted-foreground">{timestamp}</span>
          </div>

          <div className="text-sm">{content}</div>

          <div className="flex items-center gap-2 pt-1">
            <Button
              variant="ghost"
              size="sm"
              className={`h-8 px-2 ${isLiked ? "text-purple-500" : ""}`}
              onClick={() => onLike?.(id)}
            >
              <ThumbsUp className="h-4 w-4 mr-1" />
              <span>{likes}</span>
            </Button>

            <Button
              variant="ghost"
              size="sm"
              className="h-8 px-2"
              onClick={() => onReply?.(id)}
            >
              <MessageSquare className="h-4 w-4 mr-1" />
              <span>Reply</span>
            </Button>

            <div className="ml-auto">
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                    <MoreVertical className="h-4 w-4" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end">
                  {isAuthor ? (
                    <DropdownMenuItem onClick={() => onDelete?.(id)}>
                      <Trash className="h-4 w-4 mr-2" />
                      Delete
                    </DropdownMenuItem>
                  ) : (
                    <DropdownMenuItem onClick={() => onReport?.(id)}>
                      <Flag className="h-4 w-4 mr-2" />
                      Report
                    </DropdownMenuItem>
                  )}
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          </div>
        </div>
      </div>

      {showReplies && replies.length > 0 && (
        <div className="pl-12 space-y-4 border-l-2 border-slate-100">
          {replies.map((reply) => (
            <CommentItem
              key={reply.id}
              {...reply}
              showReplies={false}
              onLike={onLike}
              onReply={onReply}
              onReport={onReport}
              onDelete={onDelete}
            />
          ))}
        </div>
      )}
    </div>
  );
}
