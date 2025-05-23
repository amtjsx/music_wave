"use client";

import React from "react";

import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { cn } from "@/lib/utils";
import {
    AlertCircle,
    CheckCircle,
    File,
    Info,
    Music2,
    Pause,
    Play,
    Upload,
    X,
} from "lucide-react";
import * as mm from "music-metadata-browser";
import { useEffect, useRef, useState } from "react";

export interface AudioMetadata {
  title?: string;
  artist?: string;
  album?: string;
  year?: number;
  genre?: string;
  duration?: number;
}

interface AudioFileUploadProps {
  onChange: (file: File | null, metadata?: AudioMetadata) => void;
  maxSizeMB?: number;
  accept?: string;
  required?: boolean;
}

export function AudioFileUpload({
  onChange,
  maxSizeMB = 10,
  accept = "audio/*",
  required = false,
}: AudioFileUploadProps) {
  const [file, setFile] = useState<File | null>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [duration, setDuration] = useState(0);
  const [currentTime, setCurrentTime] = useState(0);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [fileType, setFileType] = useState<string | null>(null);
  const [isLoadingMetadata, setIsLoadingMetadata] = useState(false);
  const [metadata, setMetadata] = useState<AudioMetadata | null>(null);

  const fileInputRef = useRef<HTMLInputElement>(null);
  const audioRef = useRef<HTMLAudioElement>(null);
  const dropZoneRef = useRef<HTMLDivElement>(null);

  // Clean up audio URL on unmount
  useEffect(() => {
    return () => {
      if (audioUrl) {
        URL.revokeObjectURL(audioUrl);
      }
    };
  }, [audioUrl]);

  // Set up audio event listeners
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const updateTime = () => setCurrentTime(audio.currentTime);
    const handleLoadedMetadata = () => setDuration(audio.duration);
    const handleEnded = () => setIsPlaying(false);

    audio.addEventListener("timeupdate", updateTime);
    audio.addEventListener("loadedmetadata", handleLoadedMetadata);
    audio.addEventListener("ended", handleEnded);

    return () => {
      audio.removeEventListener("timeupdate", updateTime);
      audio.removeEventListener("loadedmetadata", handleLoadedMetadata);
      audio.removeEventListener("ended", handleEnded);
    };
  }, [file]);

  // Format time in MM:SS
  const formatTime = (time: number) => {
    if (isNaN(time)) return "0:00";
    const minutes = Math.floor(time / 60);
    const seconds = Math.floor(time % 60);
    return `${minutes}:${seconds.toString().padStart(2, "0")}`;
  };

  // Get file size in readable format
  const getFileSize = (size: number) => {
    if (size < 1024) return `${size} B`;
    if (size < 1024 * 1024) return `${(size / 1024).toFixed(1)} KB`;
    return `${(size / (1024 * 1024)).toFixed(1)} MB`;
  };

  // Validate file
  const validateFile = (file: File) => {
    // Check file size
    if (file.size > maxSizeMB * 1024 * 1024) {
      return `File size exceeds ${maxSizeMB}MB limit`;
    }

    // Check file type
    if (!file.type.startsWith("audio/")) {
      return "Please select an audio file";
    }

    return null;
  };

  // Extract metadata from audio file
  const extractMetadata = async (file: File): Promise<AudioMetadata> => {
    try {
      setIsLoadingMetadata(true);
      const metadata = await mm.parseBlob(file);
      console.log("metadata", metadata);

      const extractedData: AudioMetadata = {
        title: metadata.common.title || undefined,
        artist: metadata.common.artist || undefined,
        album: metadata.common.album || undefined,
        year: metadata.common.year || undefined,
        genre: metadata.common.genre?.[0] || undefined,
        duration: metadata.format.duration || undefined,
      };

      setMetadata(extractedData);
      return extractedData;
    } catch (error) {
      console.error("Error extracting metadata:", error);
      return {};
    } finally {
      setIsLoadingMetadata(false);
    }
  };

  // Handle file selection
  const handleFileChange = async (selectedFile: File | null) => {
    // Clean up previous file
    if (audioUrl) {
      URL.revokeObjectURL(audioUrl);
      setAudioUrl(null);
    }

    if (!selectedFile) {
      setFile(null);
      setError(null);
      setFileType(null);
      setMetadata(null);
      onChange(null);
      return;
    }

    // Validate file
    const validationError = validateFile(selectedFile);
    if (validationError) {
      setError(validationError);
      return;
    }

    // Set file and create URL
    setFile(selectedFile);
    setError(null);
    setFileType(selectedFile.type.split("/")[1].toUpperCase());
    const url = URL.createObjectURL(selectedFile);
    setAudioUrl(url);

    // Extract metadata
    const extractedMetadata = await extractMetadata(selectedFile);

    // Pass file and metadata to parent
    onChange(selectedFile, extractedMetadata);
  };

  // Handle file input change
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0] || null;
    handleFileChange(selectedFile);
  };

  // Handle drag events
  const handleDragEnter = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();

    // Only set isDragging to false if we're leaving the drop zone
    // and not entering a child element
    if (
      dropZoneRef.current &&
      !dropZoneRef.current.contains(e.relatedTarget as Node)
    ) {
      setIsDragging(false);
    }
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);

    const droppedFile = e.dataTransfer.files[0];
    if (droppedFile) {
      handleFileChange(droppedFile);
    }
  };

  // Handle play/pause
  const togglePlay = () => {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
    } else {
      audio.play();
    }
    setIsPlaying(!isPlaying);
  };

  // Handle file removal
  const removeFile = () => {
    if (audioUrl) {
      URL.revokeObjectURL(audioUrl);
    }
    setFile(null);
    setAudioUrl(null);
    setFileType(null);
    setIsPlaying(false);
    setCurrentTime(0);
    setDuration(0);
    setMetadata(null);
    onChange(null);

    // Reset file input
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  return (
    <div className="space-y-4">
      {/* Hidden audio element for playback */}
      <audio ref={audioRef} src={audioUrl || undefined} preload="metadata" />

      {/* File upload area */}
      {!file ? (
        <div
          ref={dropZoneRef}
          className={cn(
            "border-2 border-dashed rounded-lg p-8 transition-all",
            isDragging
              ? "border-primary bg-primary/5"
              : "border-gray-300 hover:border-gray-400",
            "cursor-pointer"
          )}
          onClick={() => fileInputRef.current?.click()}
          onDragEnter={handleDragEnter}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
        >
          <div className="flex flex-col items-center justify-center text-center space-y-4">
            <div className="rounded-full bg-primary/10 p-4">
              <Music2 className="h-8 w-8 text-primary" />
            </div>
            <div className="space-y-2">
              <h3 className="font-medium text-base">Upload your audio file</h3>
              <p className="text-sm text-muted-foreground">
                Drag and drop your audio file here, or click to browse
              </p>
              <p className="text-xs text-muted-foreground">
                Supports MP3, WAV, OGG, FLAC (Max {maxSizeMB}MB)
              </p>
              <p className="text-xs text-primary">
                <Info className="h-3 w-3 inline mr-1" />
                We'll automatically extract metadata to fill the form
              </p>
            </div>
            <Button variant="outline" size="sm" className="mt-2">
              <Upload className="h-4 w-4 mr-2" />
              Select File
            </Button>
          </div>
          <input
            ref={fileInputRef}
            type="file"
            accept={accept}
            onChange={handleInputChange}
            className="hidden"
            required={required}
          />
        </div>
      ) : (
        <div className="border rounded-lg p-4 bg-card">
          <div className="flex items-start space-x-4">
            {/* File icon */}
            <div className="rounded-md bg-primary/10 p-2 flex-shrink-0">
              <File className="h-8 w-8 text-primary" />
            </div>

            {/* File info */}
            <div className="flex-1 min-w-0">
              <div className="flex justify-between items-start">
                <div>
                  <h4 className="font-medium text-sm truncate">{file.name}</h4>
                  <div className="flex items-center mt-1 space-x-2">
                    <span className="text-xs bg-primary/10 text-primary px-2 py-0.5 rounded-full">
                      {fileType}
                    </span>
                    <span className="text-xs text-muted-foreground">
                      {getFileSize(file.size)}
                    </span>
                    <span className="text-xs text-muted-foreground">
                      {formatTime(duration)}
                    </span>
                  </div>
                </div>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={(e) => {
                    e.stopPropagation();
                    removeFile();
                  }}
                  className="h-8 w-8 text-muted-foreground hover:text-destructive"
                >
                  <X className="h-4 w-4" />
                </Button>
              </div>

              {/* Audio player controls */}
              <div className="mt-3 space-y-2">
                <div className="flex items-center space-x-2">
                  <Button
                    variant="outline"
                    size="icon"
                    onClick={(e) => {
                      e.stopPropagation();
                      togglePlay();
                    }}
                    className="h-8 w-8 rounded-full flex-shrink-0"
                  >
                    {isPlaying ? (
                      <Pause className="h-4 w-4" />
                    ) : (
                      <Play className="h-4 w-4" />
                    )}
                  </Button>
                  <div className="flex-1">
                    <Progress
                      value={(currentTime / duration) * 100}
                      className="h-2"
                    />
                  </div>
                  <span className="text-xs text-muted-foreground flex-shrink-0 w-10 text-right">
                    {formatTime(currentTime)}
                  </span>
                </div>
              </div>

              {/* Metadata info */}
              {metadata &&
                Object.keys(metadata).some(
                  (key) => metadata[key as keyof AudioMetadata]
                ) && (
                  <div className="mt-3 pt-2 border-t text-xs text-muted-foreground">
                    <p className="flex items-center">
                      <Info className="h-3 w-3 mr-1" />
                      Metadata extracted and form fields updated
                    </p>
                  </div>
                )}
            </div>
          </div>
        </div>
      )}

      {/* Loading metadata indicator */}
      {isLoadingMetadata && (
        <div className="flex items-center text-primary text-sm mt-2">
          <svg
            className="animate-spin -ml-1 mr-2 h-4 w-4 text-primary"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            ></circle>
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ></path>
          </svg>
          Extracting metadata...
        </div>
      )}

      {/* Error message */}
      {error && (
        <div className="flex items-center text-destructive text-sm mt-2">
          <AlertCircle className="h-4 w-4 mr-2" />
          {error}
        </div>
      )}

      {/* Success message */}
      {file && !error && !isLoadingMetadata && (
        <div className="flex items-center text-green-600 text-sm mt-2">
          <CheckCircle className="h-4 w-4 mr-2" />
          Audio file ready to upload
        </div>
      )}
    </div>
  );
}
