"use client";

import type React from "react";

import { useState, useRef } from "react";
import { Upload } from "lucide-react";
import { Button } from "@/components/ui/button";

interface FileUploaderProps {
  onFilesAdded: (files: { name: string; size: string; type: string }[]) => void;
  acceptedFileTypes?: string[];
  maxFileSizeMB?: number;
  maxFiles?: number;
}

export function FileUploader({
  onFilesAdded,
  acceptedFileTypes = ["image/jpeg", "image/png", "application/pdf"],
  maxFileSizeMB = 5,
  maxFiles = 5,
}: FileUploaderProps) {
  const [isDragging, setIsDragging] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = () => {
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDragging(false);

    if (e.dataTransfer.files) {
      handleFiles(e.dataTransfer.files);
    }
  };

  const handleFileInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files) {
      handleFiles(e.target.files);
    }
  };

  const handleFiles = (fileList: FileList) => {
    setError(null);
    const files: { name: string; size: string; type: string }[] = [];

    if (fileList.length > maxFiles) {
      setError(`You can only upload up to ${maxFiles} files at once.`);
      return;
    }

    for (let i = 0; i < fileList.length; i++) {
      const file = fileList[i];

      // Check file type
      if (!acceptedFileTypes.includes(file.type)) {
        setError(
          `File type not supported: ${
            file.name
          }. Please upload ${acceptedFileTypes.join(", ")} files.`
        );
        return;
      }

      // Check file size
      if (file.size > maxFileSizeMB * 1024 * 1024) {
        setError(
          `File too large: ${file.name}. Maximum size is ${maxFileSizeMB}MB.`
        );
        return;
      }

      // Format file size
      let fileSize = "";
      if (file.size < 1024) {
        fileSize = `${file.size} B`;
      } else if (file.size < 1024 * 1024) {
        fileSize = `${(file.size / 1024).toFixed(1)} KB`;
      } else {
        fileSize = `${(file.size / (1024 * 1024)).toFixed(1)} MB`;
      }

      files.push({
        name: file.name,
        size: fileSize,
        type: file.type,
      });
    }

    onFilesAdded(files);

    // Reset file input
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const handleButtonClick = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  return (
    <div className="w-full">
      <div
        className={`flex flex-col items-center justify-center rounded-md border border-dashed p-6 transition-colors ${
          isDragging
            ? "border-purple-500 bg-purple-50 dark:bg-purple-950/20"
            : "border-border"
        }`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
      >
        <div className="mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-muted">
          <Upload className="h-6 w-6 text-muted-foreground" />
        </div>
        <p className="mb-1 text-sm font-medium">Drag and drop files here or</p>
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={handleButtonClick}
          className="mt-2"
        >
          Choose Files
        </Button>
        <input
          ref={fileInputRef}
          type="file"
          className="hidden"
          multiple
          accept={acceptedFileTypes.join(",")}
          onChange={handleFileInputChange}
        />
        <p className="mt-2 text-xs text-muted-foreground">
          Accepted file types:{" "}
          {acceptedFileTypes
            .map((type) =>
              type.replace("image/", ".").replace("application/", ".")
            )
            .join(", ")}
        </p>
        <p className="text-xs text-muted-foreground">
          Maximum file size: {maxFileSizeMB}MB (up to {maxFiles} files)
        </p>
      </div>

      {error && (
        <div className="mt-2 rounded-md bg-red-50 p-3 text-sm text-red-600 dark:bg-red-950/50 dark:text-red-400">
          {error}
        </div>
      )}
    </div>
  );
}
