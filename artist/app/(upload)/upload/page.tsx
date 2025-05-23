"use client";

import { Info } from "lucide-react"; // Import Info component
import React from "react";

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { apiClient } from "@/lib/api-client";
import { AlertCircle, CheckCircle2, Music2, Upload } from "lucide-react";
import { useState } from "react";
import { AudioFileUpload, type AudioMetadata } from "./audio-file-upload";
import { CoverArtEditor } from "./cover-art-editor";

export default function MusicUploadForm() {
  const [formData, setFormData] = useState({
    title: "",
    artist: "",
    album: "",
    genre: "",
    year: new Date().getFullYear(),
  });

  const [audioFile, setAudioFile] = useState<File | null>(null);
  const [coverFile, setCoverFile] = useState<File | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<{
    type: "success" | "error" | null;
    message: string;
  }>({ type: null, message: "" });
  const [metadataApplied, setMetadataApplied] = useState(false);

  const genres = [
    "Pop",
    "Rock",
    "Hip Hop",
    "R&B",
    "Country",
    "Electronic",
    "Jazz",
    "Classical",
    "Folk",
    "Reggae",
    "Other",
  ];

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSelectChange = (name: string, value: string) => {
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleAudioChange = (file: File | null, metadata?: AudioMetadata) => {
    setAudioFile(file);

    // Apply metadata to form fields if available
    if (file && metadata) {
      const updates: Partial<typeof formData> = {};

      if (metadata.title) updates.title = metadata.title;
      if (metadata.artist) updates.artist = metadata.artist;
      if (metadata.album) updates.album = metadata.album;
      if (metadata.genre) updates.genre = metadata.genre;
      if (metadata.year) updates.year = metadata.year;

      // Only update if we have at least one field
      if (Object.keys(updates).length > 0) {
        setFormData((prev) => ({ ...prev, ...updates }));
        setMetadataApplied(true);

        // Show a temporary notification
        setTimeout(() => {
          setMetadataApplied(false);
        }, 3000);
      }
    }
  };

  const handleCoverChange = (file: File | null) => {
    setCoverFile(file);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!audioFile) {
      setSubmitStatus({
        type: "error",
        message: "Please select an audio file to upload",
      });
      return;
    }

    setIsSubmitting(true);
    setSubmitStatus({ type: null, message: "" });

    try {
      // Create FormData object
      const formDataToSend = new FormData();

      // Add track details
      Object.entries(formData).forEach(([key, value]) => {
        formDataToSend.append(key, value.toString());
      });

      // Add files
      formDataToSend.append("audio", audioFile);
      if (coverFile) {
        formDataToSend.append("coverArt", coverFile);
      }

      // Method 1: Using the uploadForm method (recommended)
      const result = await apiClient.uploadForm("/music", formDataToSend);

      // Method 2: Using the post method (also works)
      // const result = await apiClient.post("/music", formDataToSend)

      console.log("Upload result:", result);

      // Reset form on success

      setAudioFile(null);
      setCoverFile(null);

      // Show success message
      setSubmitStatus({
        type: "success",
        message: "Track uploaded successfully!",
      });
    } catch (error) {
      console.error("Error uploading track:", error);
      setSubmitStatus({
        type: "error",
        message:
          error instanceof Error ? error.message : "An unknown error occurred",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="container mx-auto py-10 px-4">
      <Card className="max-w-2xl mx-auto">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Music2 className="h-6 w-6" />
            Upload New Track
          </CardTitle>
          <CardDescription>
            Fill in the details and upload your music file
          </CardDescription>
        </CardHeader>

        <form onSubmit={handleSubmit}>
          <CardContent className="space-y-6">
            {submitStatus.type && (
              <Alert
                variant={
                  submitStatus.type === "error" ? "destructive" : "default"
                }
                className={
                  submitStatus.type === "success"
                    ? "bg-green-50 text-green-800 border-green-200"
                    : undefined
                }
              >
                {submitStatus.type === "error" ? (
                  <AlertCircle className="h-4 w-4" />
                ) : (
                  <CheckCircle2 className="h-4 w-4" />
                )}
                <AlertTitle>
                  {submitStatus.type === "error" ? "Error" : "Success"}
                </AlertTitle>
                <AlertDescription>{submitStatus.message}</AlertDescription>
              </Alert>
            )}

            {metadataApplied && (
              <Alert className="bg-blue-50 text-blue-800 border-blue-200">
                <Info className="h-4 w-4" />
                <AlertTitle>Metadata Applied</AlertTitle>
                <AlertDescription>
                  Form fields have been automatically filled based on the MP3
                  metadata. You can edit them if needed.
                </AlertDescription>
              </Alert>
            )}

            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="audio">Audio File *</Label>
                <AudioFileUpload
                  onChange={handleAudioChange}
                  required
                  maxSizeMB={20}
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="title">Track Title *</Label>
                  <Input
                    id="title"
                    name="title"
                    value={formData.title}
                    onChange={handleInputChange}
                    placeholder="Enter track title"
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="artist">Artist *</Label>
                  <Input
                    id="artist"
                    name="artist"
                    value={formData.artist}
                    onChange={handleInputChange}
                    placeholder="Enter artist name"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="album">Album</Label>
                  <Input
                    id="album"
                    name="album"
                    value={formData.album}
                    onChange={handleInputChange}
                    placeholder="Enter album name (optional)"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="year">Year</Label>
                  <Input
                    id="year"
                    name="year"
                    type="number"
                    min="1900"
                    max={new Date().getFullYear()}
                    value={formData.year}
                    onChange={handleInputChange}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="genre">Genre</Label>
                <Select
                  value={formData.genre}
                  onValueChange={(value) => handleSelectChange("genre", value)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select a genre" />
                  </SelectTrigger>
                  <SelectContent>
                    {genres.map((genre) => (
                      <SelectItem key={genre} value={genre}>
                        {genre}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label>Cover Art</Label>
                <CoverArtEditor onImageChange={handleCoverChange} />
              </div>
            </div>
          </CardContent>

          <CardFooter>
            <Button type="submit" className="w-full" disabled={isSubmitting}>
              {isSubmitting ? (
                <span className="flex items-center gap-2">
                  <svg
                    className="animate-spin -ml-1 mr-2 h-4 w-4 text-white"
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
                  Uploading...
                </span>
              ) : (
                <span className="flex items-center gap-2">
                  <Upload className="h-4 w-4" />
                  Upload Track
                </span>
              )}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </div>
  );
}
