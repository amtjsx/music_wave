"use client";

import type React from "react";

import { useState, useRef, useEffect } from "react";
import { Button } from "@/components/ui/button";
import { ChevronUp, ChevronDown, Check, X, Upload } from "lucide-react";
import Image from "next/image";

interface CoverPhotoEditorProps {
  coverUrl: string;
  onSave: (position: number, newImageUrl?: string) => void;
  onCancel: () => void;
}

export function CoverPhotoEditor({
  coverUrl,
  onSave,
  onCancel,
}: CoverPhotoEditorProps) {
  const [position, setPosition] = useState(50); // 50% is centered (range 0-100)
  const [newCoverImage, setNewCoverImage] = useState<string | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [startY, setStartY] = useState(0);
  const [startPosition, setStartPosition] = useState(50);

  // Move the image up (decrease position value)
  const moveUp = () => {
    setPosition((prev) => Math.max(0, prev - 5));
  };

  // Move the image down (increase position value)
  const moveDown = () => {
    setPosition((prev) => Math.min(100, prev + 5));
  };

  // Handle mouse down for dragging
  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    setStartY(e.clientY);
    setStartPosition(position);
  };

  // Handle touch start for mobile
  const handleTouchStart = (e: React.TouchEvent) => {
    setIsDragging(true);
    setStartY(e.touches[0].clientY);
    setStartPosition(position);
  };

  // Handle mouse move for dragging
  const handleMouseMove = (e: MouseEvent) => {
    if (!isDragging || !containerRef.current) return;

    const containerHeight = containerRef.current.clientHeight;
    const deltaY = e.clientY - startY;
    const deltaPercent = (deltaY / containerHeight) * 100;

    // Update position based on drag movement
    const newPosition = Math.min(
      100,
      Math.max(0, startPosition + deltaPercent)
    );
    setPosition(newPosition);
  };

  // Handle touch move for mobile
  const handleTouchMove = (e: TouchEvent) => {
    if (!isDragging || !containerRef.current) return;

    const containerHeight = containerRef.current.clientHeight;
    const deltaY = e.touches[0].clientY - startY;
    const deltaPercent = (deltaY / containerHeight) * 100;

    // Update position based on drag movement
    const newPosition = Math.min(
      100,
      Math.max(0, startPosition + deltaPercent)
    );
    setPosition(newPosition);
  };

  // Handle mouse up to end dragging
  const handleMouseUp = () => {
    setIsDragging(false);
  };

  // Handle file selection for new cover photo
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const file = e.target.files[0];
      const reader = new FileReader();

      reader.onload = (event) => {
        if (event.target?.result) {
          setNewCoverImage(event.target.result as string);
          // Reset position to center for new image
          setPosition(50);
        }
      };

      reader.readAsDataURL(file);
    }
  };

  // Trigger file input click
  const handleSelectNewCover = () => {
    fileInputRef.current?.click();
  };

  // Add and remove event listeners for dragging
  useEffect(() => {
    if (isDragging) {
      window.addEventListener("mousemove", handleMouseMove);
      window.addEventListener("mouseup", handleMouseUp);
      window.addEventListener("touchmove", handleTouchMove);
      window.addEventListener("touchend", handleMouseUp);
    }

    return () => {
      window.removeEventListener("mousemove", handleMouseMove);
      window.removeEventListener("mouseup", handleMouseUp);
      window.removeEventListener("touchmove", handleTouchMove);
      window.removeEventListener("touchend", handleMouseUp);
    };
  }, [isDragging]);

  // Current image to display (new uploaded image or original)
  const currentImageUrl = newCoverImage || coverUrl;

  return (
    <div className="relative h-64 w-full" ref={containerRef}>
      {/* Cover Image with position styling */}
      <div
        className="absolute inset-0 overflow-hidden bg-gradient-to-r from-purple-700 to-purple-900"
        onMouseDown={handleMouseDown}
        onTouchStart={handleTouchStart}
      >
        <Image
          src={currentImageUrl || "/placeholder.svg"}
          alt="Cover photo"
          fill
          className="object-cover transition-all duration-200 ease-in-out"
          style={{
            objectPosition: `center ${position}%`,
            cursor: isDragging ? "grabbing" : "grab",
          }}
          priority
        />
        <div className="absolute inset-0 bg-black bg-opacity-30"></div>
      </div>

      {/* Instruction overlay */}
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div className="bg-black bg-opacity-60 text-white px-4 py-2 rounded-md text-sm">
          Drag to adjust or use arrows
        </div>
      </div>

      {/* Position Controls */}
      <div className="absolute right-4 top-1/2 -translate-y-1/2 flex flex-col gap-2">
        <Button
          variant="secondary"
          size="icon"
          className="bg-white bg-opacity-80 hover:bg-white"
          onClick={moveUp}
        >
          <ChevronUp className="h-5 w-5" />
        </Button>
        <Button
          variant="secondary"
          size="icon"
          className="bg-white bg-opacity-80  hover:bg-white"
          onClick={moveDown}
        >
          <ChevronDown className="h-5 w-5" />
        </Button>
      </div>

      {/* Upload new cover photo button */}
      <div className="absolute left-4 top-4 flex gap-2">
        <Button
          variant="secondary"
          size="sm"
          className="bg-white bg-opacity-80 hover:bg-white flex items-center gap-1"
          onClick={handleSelectNewCover}
        >
          <Upload className="h-4 w-4" />
          Upload New Cover
        </Button>
        <input
          type="file"
          ref={fileInputRef}
          className="hidden"
          accept="image/*"
          onChange={handleFileChange}
        />
      </div>

      {/* Action buttons */}
      <div className="absolute bottom-4 right-4 flex gap-2">
        <Button
          variant="secondary"
          size="sm"
          className="bg-white bg-opacity-80 hover:bg-white z-50"
          onClick={onCancel}
        >
          <X className="h-4 w-4 mr-1" />
          Cancel
        </Button>
        <Button
          variant="default"
          size="sm"
          className="bg-purple-600 hover:bg-purple-700 z-50"
          onClick={() => onSave(position, newCoverImage || undefined)}
        >
          <Check className="h-4 w-4 mr-1" />
          Save
        </Button>
      </div>
    </div>
  );
}
