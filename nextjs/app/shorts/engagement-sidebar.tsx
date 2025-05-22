"use client";

import { useState } from "react";
import { Heart, MessageSquare, Share2, Bookmark } from "lucide-react";
import { formatNumber } from "@/lib/utils";

interface EngagementSidebarProps {
  likes: number;
  comments: number;
  shares: number;
  userAvatar: string;
}

export default function EngagementSidebar({
  likes,
  comments,
  shares,
  userAvatar,
}: EngagementSidebarProps) {
  const [liked, setLiked] = useState(false);
  const [saved, setSaved] = useState(false);
  const [localLikes, setLocalLikes] = useState(likes);

  const handleLike = () => {
    if (liked) {
      setLocalLikes((prev) => prev - 1);
    } else {
      setLocalLikes((prev) => prev + 1);
    }
    setLiked(!liked);
  };

  const handleSave = () => {
    setSaved(!saved);
  };

  return (
    <div className="absolute right-4 bottom-24 flex flex-col items-center space-y-6">
      {/* Like button */}
      <div className="flex flex-col items-center">
        <button
          onClick={handleLike}
          className="h-12 w-12 rounded-full bg-black/40 flex items-center justify-center"
        >
          <Heart
            className={`h-6 w-6 ${
              liked ? "text-red-500 fill-red-500" : "text-white"
            }`}
          />
        </button>
        <span className="text-white text-xs mt-1">
          {formatNumber(localLikes)}
        </span>
      </div>

      {/* Comments button */}
      <div className="flex flex-col items-center">
        <button className="h-12 w-12 rounded-full bg-black/40 flex items-center justify-center">
          <MessageSquare className="h-6 w-6 text-white" />
        </button>
        <span className="text-white text-xs mt-1">
          {formatNumber(comments)}
        </span>
      </div>

      {/* Share button */}
      <div className="flex flex-col items-center">
        <button className="h-12 w-12 rounded-full bg-black/40 flex items-center justify-center">
          <Share2 className="h-6 w-6 text-white" />
        </button>
        <span className="text-white text-xs mt-1">{formatNumber(shares)}</span>
      </div>

      {/* Save button */}
      <div className="flex flex-col items-center">
        <button
          onClick={handleSave}
          className="h-12 w-12 rounded-full bg-black/40 flex items-center justify-center"
        >
          <Bookmark
            className={`h-6 w-6 ${
              saved ? "text-purple-500 fill-purple-500" : "text-white"
            }`}
          />
        </button>
        <span className="text-white text-xs mt-1">Save</span>
      </div>

      {/* User avatar (spinning record effect) */}
      <div className="h-12 w-12 rounded-full border-2 border-white overflow-hidden animate-spin-slow">
        <img
          src={userAvatar || "/placeholder.svg"}
          alt="Creator"
          className="h-full w-full object-cover"
        />
      </div>
    </div>
  );
}
