"use client";

import React from "react";

import { Button } from "@/components/ui/button";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog";
import { Check, Copy, Download, QrCode } from "lucide-react";
import Image from "next/image";
import { useEffect, useState } from "react";
import { toast } from "sonner";

interface ShareQRDialogProps {
  url: string;
  title: string;
  trigger?: React.ReactNode;
}

export function ShareQRDialog({ url, title, trigger }: ShareQRDialogProps) {
  const [qrCodeUrl, setQrCodeUrl] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (!url) return;

    // Generate QR code URL
    const encodedUrl = encodeURIComponent(url);
    setQrCodeUrl(
      `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodedUrl}`
    );

    // In a real implementation, you might want to call your own API endpoint
    // that generates and returns a QR code
    /*
    const fetchQRCode = async () => {
      setIsLoading(true)
      try {
        const response = await fetch(`/api/qrcode?url=${encodedUrl}`)
        const data = await response.json()
        if (data.success) {
          setQrCodeUrl(data.qrCodeUrl)
        }
      } catch (error) {
        console.error("Failed to generate QR code:", error)
      } finally {
        setIsLoading(false)
      }
    }
    
    fetchQRCode()
    */
  }, [url]);

  const copyToClipboard = () => {
    navigator.clipboard.writeText(url).then(() => {
      setCopied(true);
      toast("Copied!", {
        description: "Link copied to clipboard.",
      });
      setTimeout(() => setCopied(false), 2000);
    });
  };

  const downloadQRCode = () => {
    if (!qrCodeUrl) return;

    const link = document.createElement("a");
    link.href = qrCodeUrl;
    link.download = `musicwave-qr-${title
      .toLowerCase()
      .replace(/\s+/g, "-")}.png`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

    toast("Downloaded!", {
      description: "QR code downloaded successfully.",
    });
  };

  const defaultTrigger = (
    <div className="flex flex-col items-center justify-center gap-2">
      <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary">
        <QrCode className="h-5 w-5" />
      </div>
      <span className="text-xs">QR Code</span>
    </div>
  );

  return (
    <Dialog>
      <DialogTrigger asChild>{trigger || defaultTrigger}</DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Share with QR Code</DialogTitle>
          <DialogDescription>
            Scan this QR code to access the content on any device
          </DialogDescription>
        </DialogHeader>

        <div className="flex flex-col items-center justify-center py-4">
          {isLoading ? (
            <div className="h-48 w-48 flex items-center justify-center bg-muted rounded-md">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
            </div>
          ) : qrCodeUrl ? (
            <div className="relative h-48 w-48 overflow-hidden rounded-md border">
              <Image
                src={qrCodeUrl || "/placeholder.svg"}
                alt="QR Code"
                fill
                className="object-cover"
              />
            </div>
          ) : (
            <div className="h-48 w-48 flex items-center justify-center bg-muted rounded-md">
              <p className="text-sm text-muted-foreground">
                Failed to generate QR code
              </p>
            </div>
          )}

          <p className="mt-4 text-sm text-center text-muted-foreground">
            Scan with your camera app to open this content
          </p>
        </div>

        <div className="flex flex-col sm:flex-row gap-2">
          <Button
            className="flex-1 gap-2"
            onClick={downloadQRCode}
            disabled={!qrCodeUrl || isLoading}
          >
            <Download className="h-4 w-4" />
            Download
          </Button>
          <Button
            variant="outline"
            className="flex-1 gap-2"
            onClick={copyToClipboard}
          >
            {copied ? (
              <Check className="h-4 w-4" />
            ) : (
              <Copy className="h-4 w-4" />
            )}
            Copy Link
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}
