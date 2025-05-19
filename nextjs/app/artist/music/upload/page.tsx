"use client";

import type React from "react";

import { format } from "date-fns";
import { CalendarIcon, Info } from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";

import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Calendar } from "@/components/ui/calendar";
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
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { FileUploadZone } from "../../components/file-upload-zone";
import { useTranslation } from "@/hooks/use-translation";

export default function ArtistUploadPage() {
  const { t } = useTranslation("artist");
  const router = useRouter();
  const [uploadType, setUploadType] = useState("track");
  const [audioFile, setAudioFile] = useState<File | null>(null);
  const [coverArt, setCoverArt] = useState<File | null>(null);
  const [releaseDate, setReleaseDate] = useState<Date | undefined>(undefined);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setIsSubmitting(true);

    // Simulate API call
    setTimeout(() => {
      setIsSubmitting(false);
      router.push("/artist/music");
    }, 2000);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">
          {t("artist.upload")}
        </h1>
        <p className="text-muted-foreground">{t("artist.uploadDescription")}</p>
      </div>

      <Tabs
        defaultValue="track"
        value={uploadType}
        onValueChange={setUploadType}
        className="w-full"
      >
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="track">{t("artist.uploadTrack")}</TabsTrigger>
          <TabsTrigger value="album">{t("artist.uploadAlbum")}</TabsTrigger>
        </TabsList>
      </Tabs>

      <Alert>
        <Info className="h-4 w-4" />
        <AlertTitle>{t("artist.uploadTip")}</AlertTitle>
        <AlertDescription>
          {uploadType === "track"
            ? t("artist.uploadTrackTip")
            : t("artist.uploadAlbumTip")}
        </AlertDescription>
      </Alert>

      <form onSubmit={handleSubmit}>
        <Card>
          <CardHeader>
            <CardTitle>
              {uploadType === "track"
                ? t("artist.trackDetails")
                : t("artist.albumDetails")}
            </CardTitle>
            <CardDescription>
              {uploadType === "track"
                ? t("artist.trackDetailsDescription")
                : t("artist.albumDetailsDescription")}
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Audio File Upload (Track only) */}
            {uploadType === "track" && (
              <div className="space-y-2">
                <Label htmlFor="audio-file">{t("artist.audioFile")}</Label>
                <FileUploadZone
                  onFileSelect={setAudioFile}
                  accept="audio/*"
                  fileType="audio"
                  helpText={t("artist.audioFileHelp")}
                />
              </div>
            )}

            {/* Cover Art Upload */}
            <div className="space-y-2">
              <Label htmlFor="cover-art">{t("artist.coverArt")}</Label>
              <FileUploadZone
                onFileSelect={setCoverArt}
                accept="image/*"
                fileType="image"
                helpText={t("artist.coverArtHelp")}
              />
            </div>

            {/* Title */}
            <div className="space-y-2">
              <Label htmlFor="title">{t("artist.title")}</Label>
              <Input
                id="title"
                placeholder={t("artist.titlePlaceholder")}
                required
              />
            </div>

            {/* Album Selection (Track only) */}
            {uploadType === "track" && (
              <div className="space-y-2">
                <Label htmlFor="album">{t("artist.album")}</Label>
                <Select>
                  <SelectTrigger>
                    <SelectValue placeholder={t("artist.selectAlbum")} />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="new">
                      {t("artist.createNewAlbum")}
                    </SelectItem>
                    <SelectItem value="1">Summer Collection</SelectItem>
                    <SelectItem value="2">Winter Melodies</SelectItem>
                    <SelectItem value="3">Spring Awakening</SelectItem>
                    <SelectItem value="4">Upcoming Album</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            )}

            {/* Genre */}
            <div className="space-y-2">
              <Label htmlFor="genre">{t("artist.genre")}</Label>
              <Select>
                <SelectTrigger>
                  <SelectValue placeholder={t("artist.selectGenre")} />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="pop">Pop</SelectItem>
                  <SelectItem value="rock">Rock</SelectItem>
                  <SelectItem value="hiphop">Hip Hop</SelectItem>
                  <SelectItem value="electronic">Electronic</SelectItem>
                  <SelectItem value="jazz">Jazz</SelectItem>
                  <SelectItem value="classical">Classical</SelectItem>
                  <SelectItem value="rnb">R&B</SelectItem>
                  <SelectItem value="country">Country</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Description */}
            <div className="space-y-2">
              <Label htmlFor="description">{t("artist.description")}</Label>
              <Textarea
                id="description"
                placeholder={t("artist.descriptionPlaceholder")}
                className="min-h-[100px]"
              />
            </div>

            {/* Release Date */}
            <div className="space-y-2">
              <Label htmlFor="release-date">{t("artist.releaseDate")}</Label>
              <Popover>
                <PopoverTrigger asChild>
                  <Button
                    variant="outline"
                    className="w-full justify-start text-left font-normal"
                  >
                    <CalendarIcon className="mr-2 h-4 w-4" />
                    {releaseDate
                      ? format(releaseDate, "PPP")
                      : t("artist.pickDate")}
                  </Button>
                </PopoverTrigger>
                <PopoverContent className="w-auto p-0">
                  <Calendar
                    mode="single"
                    selected={releaseDate}
                    onSelect={setReleaseDate}
                    initialFocus
                  />
                </PopoverContent>
              </Popover>
            </div>

            {/* Visibility */}
            <div className="space-y-2">
              <Label>{t("artist.visibility")}</Label>
              <RadioGroup defaultValue="public">
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="public" id="public" />
                  <Label htmlFor="public">{t("artist.public")}</Label>
                </div>
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="private" id="private" />
                  <Label htmlFor="private">{t("artist.private")}</Label>
                </div>
              </RadioGroup>
            </div>

            {/* Release Status */}
            <div className="space-y-2">
              <Label>{t("artist.releaseStatus")}</Label>
              <RadioGroup defaultValue="publish">
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="publish" id="publish" />
                  <Label htmlFor="publish">{t("artist.publishNow")}</Label>
                </div>
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="draft" id="draft" />
                  <Label htmlFor="draft">{t("artist.saveAsDraft")}</Label>
                </div>
              </RadioGroup>
            </div>
          </CardContent>
          <CardFooter className="flex justify-between">
            <Button
              variant="outline"
              type="button"
              onClick={() => router.back()}
            >
              {t("artist.cancel")}
            </Button>
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? t("artist.uploading") : t("artist.upload")}
            </Button>
          </CardFooter>
        </Card>
      </form>
    </div>
  );
}
