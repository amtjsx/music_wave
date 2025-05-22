"use client";

import { useState, useRef, useEffect } from "react";
import { X, Heart, ChevronDown, ChevronUp, Send } from "lucide-react";
import { formatDistanceToNow } from "date-fns";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { ScrollArea } from "@/components/ui/scroll-area";
import { cn } from "@/lib/utils";

// Types for comments
interface CommentReply {
  id: string;
  userId: string;
  userName: string;
  userAvatar: string;
  text: string;
  timestamp: Date;
  likes: number;
  isLiked: boolean;
}

interface Comment {
  id: string;
  userId: string;
  userName: string;
  userAvatar: string;
  text: string;
  timestamp: Date;
  likes: number;
  isLiked: boolean;
  replies: CommentReply[];
  showReplies: boolean;
}

interface CommentSectionProps {
  isOpen: boolean;
  onClose: () => void;
  shortId: string;
}

export function CommentSection({
  isOpen,
  onClose,
  shortId,
}: CommentSectionProps) {
  const [comments, setComments] = useState<Comment[]>([]);
  const [newComment, setNewComment] = useState("");
  const [replyingTo, setReplyingTo] = useState<string | null>(null);
  const [replyText, setReplyText] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [expandedComments, setExpandedComments] = useState<
    Record<string, boolean>
  >({});
  const commentInputRef = useRef<HTMLTextAreaElement>(null);
  const panelRef = useRef<HTMLDivElement>(null);

  // Animation states
  const [isAnimating, setIsAnimating] = useState(false);

  // Handle animation when opening/closing
  useEffect(() => {
    if (isOpen) {
      setIsAnimating(true);
      // Focus the comment input when opened
      setTimeout(() => {
        commentInputRef.current?.focus();
        setIsAnimating(false);
      }, 300);
    }
  }, [isOpen]);

  // Fetch comments
  useEffect(() => {
    if (isOpen) {
      fetchComments();
    }
  }, [isOpen, shortId]);

  // Mock function to fetch comments
  const fetchComments = async () => {
    setIsLoading(true);
    // In a real app, this would be an API call
    setTimeout(() => {
      // Mock data
      const mockComments: Comment[] = [
        {
          id: "c1",
          userId: "u1",
          userName: "Alex Johnson",
          userAvatar: "/placeholder.svg?height=40&width=40&text=AJ",
          text: "This beat is absolutely fire! 🔥 Can't wait to hear more from you. Your production skills are next level.",
          timestamp: new Date(Date.now() - 15 * 60000), // 15 minutes ago
          likes: 42,
          isLiked: false,
          replies: [
            {
              id: "r1",
              userId: "u2",
              userName: "DJ Wavelength",
              userAvatar: "/placeholder.svg?height=40&width=40&text=DJ",
              text: "Thanks! I've been working on this style for months. More coming soon!",
              timestamp: new Date(Date.now() - 10 * 60000), // 10 minutes ago
              likes: 12,
              isLiked: false,
            },
            {
              id: "r2",
              userId: "u3",
              userName: "Music Lover",
              userAvatar: "/placeholder.svg?height=40&width=40&text=ML",
              text: "I agree! The production quality is insane.",
              timestamp: new Date(Date.now() - 5 * 60000), // 5 minutes ago
              likes: 3,
              isLiked: false,
            },
          ],
          showReplies: false,
        },
        {
          id: "c2",
          userId: "u4",
          userName: "Sarah Williams",
          userAvatar: "/placeholder.svg?height=40&width=40&text=SW",
          text: "What DAW do you use for your production? The sound design is incredible!",
          timestamp: new Date(Date.now() - 45 * 60000), // 45 minutes ago
          likes: 18,
          isLiked: true,
          replies: [],
          showReplies: false,
        },
        {
          id: "c3",
          userId: "u5",
          userName: "Beat Maker",
          userAvatar: "/placeholder.svg?height=40&width=40&text=BM",
          text: "The way you mixed those samples is genius. Would love to collab sometime!",
          timestamp: new Date(Date.now() - 2 * 3600000), // 2 hours ago
          likes: 27,
          isLiked: false,
          replies: [
            {
              id: "r3",
              userId: "u2",
              userName: "DJ Wavelength",
              userAvatar: "/placeholder.svg?height=40&width=40&text=DJ",
              text: "DM me and we can set something up!",
              timestamp: new Date(Date.now() - 1.5 * 3600000), // 1.5 hours ago
              likes: 8,
              isLiked: false,
            },
          ],
          showReplies: false,
        },
        {
          id: "c4",
          userId: "u6",
          userName: "Music Producer",
          userAvatar: "/placeholder.svg?height=40&width=40&text=MP",
          text: "Those transitions are so smooth. What effects chain are you using?",
          timestamp: new Date(Date.now() - 5 * 3600000), // 5 hours ago
          likes: 15,
          isLiked: false,
          replies: [],
          showReplies: false,
        },
        {
          id: "c5",
          userId: "u7",
          userName: "Rhythm King",
          userAvatar: "/placeholder.svg?height=40&width=40&text=RK",
          text: "The drum patterns in this are so unique. Really stands out from other tracks!",
          timestamp: new Date(Date.now() - 12 * 3600000), // 12 hours ago
          likes: 31,
          isLiked: false,
          replies: [],
          showReplies: false,
        },
      ];

      setComments(mockComments);
      setIsLoading(false);
    }, 1000);
  };

  // Toggle showing replies for a comment
  const toggleReplies = (commentId: string) => {
    setComments(
      comments.map((comment) =>
        comment.id === commentId
          ? { ...comment, showReplies: !comment.showReplies }
          : comment
      )
    );
  };

  // Toggle expanded state for long comments
  const toggleExpanded = (commentId: string) => {
    setExpandedComments({
      ...expandedComments,
      [commentId]: !expandedComments[commentId],
    });
  };

  // Like a comment
  const likeComment = (commentId: string) => {
    setComments(
      comments.map((comment) => {
        if (comment.id === commentId) {
          return {
            ...comment,
            likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
            isLiked: !comment.isLiked,
          };
        }
        return comment;
      })
    );
  };

  // Like a reply
  const likeReply = (commentId: string, replyId: string) => {
    setComments(
      comments.map((comment) => {
        if (comment.id === commentId) {
          return {
            ...comment,
            replies: comment.replies.map((reply) => {
              if (reply.id === replyId) {
                return {
                  ...reply,
                  likes: reply.isLiked ? reply.likes - 1 : reply.likes + 1,
                  isLiked: !reply.isLiked,
                };
              }
              return reply;
            }),
          };
        }
        return comment;
      })
    );
  };

  // Start replying to a comment
  const startReply = (commentId: string) => {
    setReplyingTo(commentId);
    setReplyText("");
    // Ensure replies are visible
    setComments(
      comments.map((comment) =>
        comment.id === commentId ? { ...comment, showReplies: true } : comment
      )
    );
    // Focus will be set by useEffect after the reply input is rendered
  };

  // Cancel replying
  const cancelReply = () => {
    setReplyingTo(null);
    setReplyText("");
  };

  // Submit a new comment
  const submitComment = () => {
    if (!newComment.trim()) return;

    const newCommentObj: Comment = {
      id: `c${Date.now()}`,
      userId: "current-user", // In a real app, this would be the current user's ID
      userName: "You", // In a real app, this would be the current user's name
      userAvatar: "/placeholder.svg?height=40&width=40&text=YOU",
      text: newComment.trim(),
      timestamp: new Date(),
      likes: 0,
      isLiked: false,
      replies: [],
      showReplies: false,
    };

    setComments([newCommentObj, ...comments]);
    setNewComment("");
  };

  // Submit a reply to a comment
  const submitReply = () => {
    if (!replyingTo || !replyText.trim()) return;

    const newReply: CommentReply = {
      id: `r${Date.now()}`,
      userId: "current-user", // In a real app, this would be the current user's ID
      userName: "You", // In a real app, this would be the current user's name
      userAvatar: "/placeholder.svg?height=40&width=40&text=YOU",
      text: replyText.trim(),
      timestamp: new Date(),
      likes: 0,
      isLiked: false,
    };

    setComments(
      comments.map((comment) => {
        if (comment.id === replyingTo) {
          return {
            ...comment,
            replies: [...comment.replies, newReply],
            showReplies: true,
          };
        }
        return comment;
      })
    );

    setReplyingTo(null);
    setReplyText("");
  };

  // Report a comment (mock function)
  const reportComment = (commentId: string) => {
    alert(
      `Comment ${commentId} reported. In a real app, this would send a report to moderators.`
    );
  };

  // Report a reply (mock function)
  const reportReply = (replyId: string) => {
    alert(
      `Reply ${replyId} reported. In a real app, this would send a report to moderators.`
    );
  };

  // Focus the reply input when replyingTo changes
  useEffect(() => {
    if (replyingTo) {
      // Small delay to ensure the input is rendered
      setTimeout(() => {
        const replyInput = document.getElementById(`reply-input-${replyingTo}`);
        if (replyInput) {
          replyInput.focus();
        }
      }, 100);
    }
  }, [replyingTo]);

  // Handle click outside to close the panel
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        panelRef.current &&
        !panelRef.current.contains(event.target as Node) &&
        isOpen &&
        !isAnimating
      ) {
        onClose();
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [isOpen, onClose, isAnimating]);

  // Handle escape key to close the panel
  useEffect(() => {
    const handleEscKey = (event: KeyboardEvent) => {
      if (event.key === "Escape" && isOpen && !isAnimating) {
        onClose();
      }
    };

    document.addEventListener("keydown", handleEscKey);
    return () => {
      document.removeEventListener("keydown", handleEscKey);
    };
  }, [isOpen, onClose, isAnimating]);

  return (
    <div
      className={cn(
        "flex h-full w-full flex-col bg-background border-l transition-all duration-300 ease-in-out",
        isOpen
          ? "opacity-100 translate-x-0"
          : "opacity-0 translate-x-full w-0 border-l-0"
      )}
      ref={panelRef}
    >
      {/* Header */}
      <div className="flex items-center justify-between border-b px-4 py-3">
        <h2 className="text-lg font-semibold">Comments</h2>
        <Button
          variant="ghost"
          size="icon"
          onClick={onClose}
          className="h-8 w-8"
        >
          <X className="h-5 w-5" />
          <span className="sr-only">Close</span>
        </Button>
      </div>

      {/* Comment input */}
      <div className="border-b px-4 py-3">
        <div className="flex items-start gap-2">
          <Avatar className="h-8 w-8">
            <AvatarImage
              src="/placeholder.svg?height=40&width=40&text=YOU"
              alt="Your avatar"
            />
            <AvatarFallback>YOU</AvatarFallback>
          </Avatar>
          <div className="flex-1">
            <Textarea
              ref={commentInputRef}
              placeholder="Add a comment..."
              value={newComment}
              onChange={(e) => setNewComment(e.target.value)}
              className="min-h-[60px] resize-none"
            />
            <div className="mt-2 flex justify-end">
              <Button
                size="sm"
                onClick={submitComment}
                disabled={!newComment.trim()}
                className="gap-1"
              >
                <Send className="h-4 w-4" />
                Post
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Comments list */}
      <ScrollArea className="flex-1">
        {isLoading ? (
          <div className="flex h-full items-center justify-center">
            <div className="flex flex-col items-center gap-2">
              <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
              <p className="text-sm text-muted-foreground">
                Loading comments...
              </p>
            </div>
          </div>
        ) : comments.length === 0 ? (
          <div className="flex h-full flex-col items-center justify-center p-4">
            <p className="mb-2 text-lg font-medium">No comments yet</p>
            <p className="text-center text-sm text-muted-foreground">
              Be the first to comment on this video!
            </p>
          </div>
        ) : (
          <div className="divide-y">
            {comments.map((comment) => (
              <div key={comment.id} className="p-4">
                {/* Comment */}
                <div className="flex gap-3">
                  <Avatar className="h-8 w-8">
                    <AvatarImage
                      src={comment.userAvatar || "/placeholder.svg"}
                      alt={comment.userName}
                    />
                    <AvatarFallback>
                      {comment.userName.charAt(0)}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span className="font-medium">{comment.userName}</span>
                      <span className="text-xs text-muted-foreground">
                        {formatDistanceToNow(comment.timestamp, {
                          addSuffix: true,
                        })}
                      </span>
                    </div>
                    <div className="mt-1">
                      {comment.text.length > 150 &&
                      !expandedComments[comment.id] ? (
                        <>
                          <p className="text-sm">
                            {comment.text.slice(0, 150)}...
                          </p>
                          <button
                            onClick={() => toggleExpanded(comment.id)}
                            className="mt-1 text-xs font-medium text-primary"
                          >
                            Read more
                          </button>
                        </>
                      ) : (
                        <>
                          <p className="text-sm">{comment.text}</p>
                          {comment.text.length > 150 && (
                            <button
                              onClick={() => toggleExpanded(comment.id)}
                              className="mt-1 text-xs font-medium text-primary"
                            >
                              Show less
                            </button>
                          )}
                        </>
                      )}
                    </div>
                    <div className="mt-2 flex items-center gap-4">
                      <button
                        onClick={() => likeComment(comment.id)}
                        className={cn(
                          "flex items-center gap-1 text-xs",
                          comment.isLiked
                            ? "text-primary"
                            : "text-muted-foreground"
                        )}
                      >
                        <Heart
                          className={cn(
                            "h-3.5 w-3.5",
                            comment.isLiked && "fill-primary"
                          )}
                        />
                        <span>{comment.likes}</span>
                      </button>
                      <button
                        onClick={() => startReply(comment.id)}
                        className="text-xs text-muted-foreground hover:text-foreground"
                      >
                        Reply
                      </button>
                      <button
                        onClick={() => reportComment(comment.id)}
                        className="text-xs text-muted-foreground hover:text-foreground"
                      >
                        Report
                      </button>
                    </div>
                  </div>
                </div>

                {/* Replies */}
                {comment.replies.length > 0 && (
                  <div className="mt-3 pl-11">
                    <button
                      onClick={() => toggleReplies(comment.id)}
                      className="flex items-center gap-1 text-xs font-medium text-primary"
                    >
                      {comment.showReplies ? (
                        <>
                          <ChevronUp className="h-3.5 w-3.5" />
                          Hide {comment.replies.length} replies
                        </>
                      ) : (
                        <>
                          <ChevronDown className="h-3.5 w-3.5" />
                          View {comment.replies.length} replies
                        </>
                      )}
                    </button>

                    {comment.showReplies && (
                      <div className="mt-3 space-y-3">
                        {comment.replies.map((reply) => (
                          <div key={reply.id} className="flex gap-3">
                            <Avatar className="h-6 w-6">
                              <AvatarImage
                                src={reply.userAvatar || "/placeholder.svg"}
                                alt={reply.userName}
                              />
                              <AvatarFallback>
                                {reply.userName.charAt(0)}
                              </AvatarFallback>
                            </Avatar>
                            <div className="flex-1">
                              <div className="flex items-center gap-2">
                                <span className="text-sm font-medium">
                                  {reply.userName}
                                </span>
                                <span className="text-xs text-muted-foreground">
                                  {formatDistanceToNow(reply.timestamp, {
                                    addSuffix: true,
                                  })}
                                </span>
                              </div>
                              <p className="text-sm">{reply.text}</p>
                              <div className="mt-1 flex items-center gap-4">
                                <button
                                  onClick={() =>
                                    likeReply(comment.id, reply.id)
                                  }
                                  className={cn(
                                    "flex items-center gap-1 text-xs",
                                    reply.isLiked
                                      ? "text-primary"
                                      : "text-muted-foreground"
                                  )}
                                >
                                  <Heart
                                    className={cn(
                                      "h-3.5 w-3.5",
                                      reply.isLiked && "fill-primary"
                                    )}
                                  />
                                  <span>{reply.likes}</span>
                                </button>
                                <button
                                  onClick={() => reportReply(reply.id)}
                                  className="text-xs text-muted-foreground hover:text-foreground"
                                >
                                  Report
                                </button>
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}

                {/* Reply input */}
                {replyingTo === comment.id && (
                  <div className="mt-3 pl-11">
                    <div className="flex items-start gap-2">
                      <Avatar className="h-6 w-6">
                        <AvatarImage
                          src="/placeholder.svg?height=40&width=40&text=YOU"
                          alt="Your avatar"
                        />
                        <AvatarFallback>YOU</AvatarFallback>
                      </Avatar>
                      <div className="flex-1">
                        <Textarea
                          id={`reply-input-${comment.id}`}
                          placeholder={`Reply to ${comment.userName}...`}
                          value={replyText}
                          onChange={(e) => setReplyText(e.target.value)}
                          className="min-h-[60px] resize-none text-sm"
                        />
                        <div className="mt-2 flex justify-end gap-2">
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={cancelReply}
                          >
                            Cancel
                          </Button>
                          <Button
                            size="sm"
                            onClick={submitReply}
                            disabled={!replyText.trim()}
                            className="gap-1"
                          >
                            <Send className="h-3.5 w-3.5" />
                            Reply
                          </Button>
                        </div>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </ScrollArea>
    </div>
  );
}
