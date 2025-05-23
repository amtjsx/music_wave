"use client";

import React from "react";

import { Button } from "@/components/ui/button";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Slider } from "@/components/ui/slider";
import { Check, ImageIcon, Pencil, X } from "lucide-react";
import { useCallback, useState } from "react";
import Cropper from "react-easy-crop";

interface CoverArtEditorProps {
  onImageChange: (file: File | null) => void;
}

interface CropArea {
  x: number;
  y: number;
  width: number;
  height: number;
}

export function CoverArtEditor({ onImageChange }: CoverArtEditorProps) {
  const [imgSrc, setImgSrc] = useState<string>("");
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [rotation, setRotation] = useState(0);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<CropArea | null>(
    null
  );
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [isDialogOpen, setIsDialogOpen] = useState(false);

  const onCropComplete = useCallback((_: any, croppedAreaPixels: CropArea) => {
    setCroppedAreaPixels(croppedAreaPixels);
  }, []);

  function onSelectFile(e: React.ChangeEvent<HTMLInputElement>) {
    if (e.target.files && e.target.files.length > 0) {
      const reader = new FileReader();
      reader.addEventListener("load", () => {
        setImgSrc(reader.result?.toString() || "");
        setIsDialogOpen(true);
      });
      reader.readAsDataURL(e.target.files[0]);
    }
  }

  const createCroppedImage = useCallback(async () => {
    if (!imgSrc || !croppedAreaPixels) return;

    try {
      const croppedImage = await getCroppedImg(
        imgSrc,
        croppedAreaPixels,
        rotation
      );
      const { url, file } = croppedImage;
      setPreviewUrl(url);
      onImageChange(file);
      setIsDialogOpen(false);
    } catch (e) {
      console.error(e);
    }
  }, [imgSrc, croppedAreaPixels, rotation, onImageChange]);

  const resetImage = () => {
    setImgSrc("");
    setCrop({ x: 0, y: 0 });
    setZoom(1);
    setRotation(0);
    setCroppedAreaPixels(null);
    setPreviewUrl(null);
    onImageChange(null);
  };

  return (
    <div className="w-full">
      {!previewUrl ? (
        <div className="flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-lg p-12 text-center hover:border-gray-400 transition-all">
          <ImageIcon className="h-12 w-12 text-gray-400 mb-4" />
          <div className="space-y-2">
            <p className="text-sm text-gray-500">Upload your cover art image</p>
            <Label
              htmlFor="cover-upload"
              className="cursor-pointer inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2"
            >
              Choose Image
            </Label>
            <Input
              id="cover-upload"
              type="file"
              accept="image/*"
              onChange={onSelectFile}
              className="hidden"
            />
          </div>
        </div>
      ) : (
        <div className="flex flex-col items-center space-y-4">
          <div className="border rounded-md overflow-hidden relative group">
            <img
              src={previewUrl || "/placeholder.svg"}
              alt="Cover art preview"
              className="max-w-full h-auto"
            />
            <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
              <Button
                variant="secondary"
                size="sm"
                onClick={() => setIsDialogOpen(true)}
                className="flex items-center gap-1"
              >
                <Pencil className="h-4 w-4" />
                Edit
              </Button>
            </div>
          </div>
          <Button
            variant="outline"
            onClick={resetImage}
            size="sm"
            className="flex items-center gap-1"
          >
            <X className="h-4 w-4" />
            Remove
          </Button>
        </div>
      )}

      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Edit Cover Art</DialogTitle>
            <DialogDescription>
              Crop, zoom, and rotate your image to create the perfect cover art.
            </DialogDescription>
          </DialogHeader>

          <div className="relative h-[300px] sm:h-[400px] w-full my-4 bg-gray-100 rounded-md overflow-hidden">
            {imgSrc && (
              <Cropper
                image={imgSrc}
                crop={crop}
                zoom={zoom}
                rotation={rotation}
                aspect={1}
                onCropChange={setCrop}
                onCropComplete={onCropComplete}
                onZoomChange={setZoom}
                cropShape="rect"
                showGrid={true}
                objectFit="contain"
              />
            )}
          </div>

          <div className="space-y-4">
            <div className="space-y-2">
              <div className="flex justify-between">
                <Label htmlFor="zoom">Zoom</Label>
                <span className="text-xs text-muted-foreground">
                  {Math.round(zoom * 100)}%
                </span>
              </div>
              <Slider
                id="zoom"
                value={[zoom]}
                min={1}
                max={3}
                step={0.01}
                onValueChange={(value) => setZoom(value[0])}
              />
            </div>

            <div className="space-y-2">
              <div className="flex justify-between">
                <Label htmlFor="rotate">Rotate</Label>
                <span className="text-xs text-muted-foreground">
                  {rotation}°
                </span>
              </div>
              <Slider
                id="rotate"
                value={[rotation]}
                min={0}
                max={360}
                step={1}
                onValueChange={(value) => setRotation(value[0])}
              />
            </div>
          </div>

          <DialogFooter className="flex justify-between sm:justify-between gap-2">
            <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={createCroppedImage}
              className="flex items-center gap-1"
            >
              <Check className="h-4 w-4" />
              Apply Changes
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// Helper function to create a cropped image
async function getCroppedImg(
  imageSrc: string,
  pixelCrop: CropArea,
  rotation = 0
): Promise<{ url: string; file: File }> {
  const image = await createImage(imageSrc);
  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");

  if (!ctx) {
    throw new Error("No 2d context");
  }

  // Set canvas size to the cropped area
  const maxSize = Math.max(image.width, image.height);
  const safeArea = 2 * ((maxSize / 2) * Math.sqrt(2));

  // Set dimensions to handle rotation
  canvas.width = safeArea;
  canvas.height = safeArea;

  // Draw rotated image
  ctx.translate(safeArea / 2, safeArea / 2);
  ctx.rotate((rotation * Math.PI) / 180);
  ctx.translate(-safeArea / 2, -safeArea / 2);

  // Draw the image in the center of the canvas
  ctx.drawImage(
    image,
    safeArea / 2 - image.width / 2,
    safeArea / 2 - image.height / 2
  );

  // Create a new canvas for the actual crop
  const croppedCanvas = document.createElement("canvas");
  const croppedCtx = croppedCanvas.getContext("2d");

  if (!croppedCtx) {
    throw new Error("No 2d context");
  }

  // Set the size of the cropped canvas
  croppedCanvas.width = pixelCrop.width;
  croppedCanvas.height = pixelCrop.height;

  // Draw the cropped image
  croppedCtx.drawImage(
    canvas,
    safeArea / 2 - image.width / 2 + pixelCrop.x,
    safeArea / 2 - image.height / 2 + pixelCrop.y,
    pixelCrop.width,
    pixelCrop.height,
    0,
    0,
    pixelCrop.width,
    pixelCrop.height
  );

  // Convert canvas to blob
  return new Promise((resolve) => {
    croppedCanvas.toBlob((blob) => {
      if (!blob) {
        throw new Error("Canvas is empty");
      }
      const file = new File([blob], "cover-art.jpg", { type: "image/jpeg" });
      const url = URL.createObjectURL(blob);
      resolve({ url, file });
    }, "image/jpeg");
  });
}

// Helper function to create an image
function createImage(url: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const image = new HTMLImageElement();
    image.addEventListener("load", () => resolve(image));
    image.addEventListener("error", (error) => reject(error));
    image.setAttribute("crossOrigin", "anonymous");
    image.src = url;
  });
}
