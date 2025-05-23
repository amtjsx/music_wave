"use client";

import React from "react";

import { useTranslation } from "@/hooks/use-translation";
import { cn } from "@/lib/utils";
import { FileAudio, FileImage, Upload, X } from "lucide-react";
import { useRef, useState } from "react";

interface FileUploadZoneProps {
  onFileSelect: (file: File) => void;
  accept: string;
  fileType: "audio" | "image";
  className?: string;
  helpText?: string;
}

export function FileUploadZone({
  onFileSelect,
  accept,
  fileType,
  className,
  helpText,
}: FileUploadZoneProps) {
  const { t } = useTranslation("artist");
  const [isDragging, setIsDragging] = useState(false);
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(false);

    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      const droppedFile = e.dataTransfer.files[0];
      handleFile(droppedFile);
    }
  };

  const handleFileInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      const selectedFile = e.target.files[0];
      handleFile(selectedFile);
    }
  };

  const handleFile = (selectedFile: File) => {
    setFile(selectedFile);
    onFileSelect(selectedFile);

    // Create preview for images
    if (fileType === "image" && selectedFile.type.startsWith("image/")) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setPreview(e.target?.result as string);
      };
      reader.readAsDataURL(selectedFile);
    }
  };

  const removeFile = () => {
    setFile(null);
    setPreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  return (
    <div className={cn("w-full", className)}>
      {!file ? (
        <div
          className={cn(
            "flex flex-col items-center justify-center rounded-lg border-2 border-dashed p-6 transition-colors",
            isDragging
              ? "border-primary bg-primary/5"
              : "border-muted-foreground/25",
            className
          )}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          onClick={() => fileInputRef.current?.click()}
        >
          <div className="flex flex-col items-center justify-center text-center">
            <Upload className="mb-2 h-10 w-10 text-muted-foreground" />
            <p className="mb-1 text-sm font-medium">{t("artist.dragDrop")}</p>
            <p className="text-xs text-muted-foreground">{helpText}</p>
          </div>
          <input
            ref={fileInputRef}
            type="file"
            accept={accept}
            onChange={handleFileInput}
            className="hidden"
          />
        </div>
      ) : (
        <div className="relative rounded-lg border p-4">
          <div className="flex items-center gap-3">
            {fileType === "image" && preview ? (
              <div className="h-20 w-20 overflow-hidden rounded-md">
                <img
                  src={preview || "/placeholder.svg"}
                  alt="Preview"
                  className="h-full w-full object-cover"
                />
              </div>
            ) : (
              <div className="flex h-20 w-20 items-center justify-center rounded-md bg-muted">
                {fileType === "audio" ? (
                  <FileAudio className="h-10 w-10 text-muted-foreground" />
                ) : (
                  <FileImage className="h-10 w-10 text-muted-foreground" />
                )}
              </div>
            )}
            <div className="flex-1">
              <p className="font-medium truncate">{file.name}</p>
              <p className="text-sm text-muted-foreground">
                {(file.size / (1024 * 1024)).toFixed(2)} MB
              </p>
            </div>
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                removeFile();
              }}
              className="rounded-full p-1 hover:bg-muted"
              aria-label="Remove file"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
