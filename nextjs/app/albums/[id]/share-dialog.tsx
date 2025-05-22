"use client";

import type React from "react";

import { useState } from "react";
import Image from "next/image";
import {
  Twitter,
  Facebook,
  Instagram,
  Linkedin,
  Mail,
  Link,
  QrCode,
  Copy,
  Check,
  MessageSquare,
  Share2,
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";

interface ShareDialogProps {
  item: {
    id: string;
    title: string;
    artist: string;
    coverUrl: string;
    type: "album" | "track" | "playlist" | "artist";
  };
  trigger?: React.ReactNode;
  className?: string;
}

export function ShareDialog({ item, trigger, className }: ShareDialogProps) {
  const [copied, setCopied] = useState(false);
  const [open, setOpen] = useState(false);

  // Generate share URLs
  const shareUrl = `https://musicwave.com/${item.type}/${item.id}`;
  const encodedUrl = encodeURIComponent(shareUrl);
  const encodedTitle = encodeURIComponent(
    `Check out ${item.title} by ${item.artist} on MusicWave`
  );

  const shareLinks = {
    twitter: `https://twitter.com/intent/tweet?url=${encodedUrl}&text=${encodedTitle}`,
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${encodedUrl}`,
    linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${encodedUrl}`,
    email: `mailto:?subject=${encodedTitle}&body=I thought you might like this: ${shareUrl}`,
  };

  const embedCode = `<iframe width="100%" height="450" src="${shareUrl}/embed" frameborder="0" allowtransparency="true" allow="encrypted-media"></iframe>`;

  const copyToClipboard = (text: string, type: string) => {
    navigator.clipboard.writeText(text).then(() => {
      setCopied(true);
      toast("Copied!", {
        description: `${type} copied to clipboard.`,
      });
      setTimeout(() => setCopied(false), 2000);
    });
  };

  const defaultTrigger = (
    <Button
      variant="outline"
      size="icon"
      className={`rounded-full ${className}`}
      onClick={() => setOpen(true)}
    >
      <Share2 className="h-4 w-4" />
      <span className="sr-only">Share</span>
    </Button>
  );

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>{trigger || defaultTrigger}</DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Share {item.type}</DialogTitle>
          <DialogDescription>
            Share this {item.type} with friends or on social media
          </DialogDescription>
        </DialogHeader>

        <div className="flex items-center space-x-4 py-4">
          <div className="relative h-20 w-20 flex-shrink-0 overflow-hidden rounded-md">
            <Image
              src={item.coverUrl || "/placeholder.svg"}
              alt={item.title}
              fill
              className="object-cover"
            />
          </div>
          <div>
            <h3 className="font-semibold">{item.title}</h3>
            <p className="text-sm text-muted-foreground">{item.artist}</p>
          </div>
        </div>

        <Tabs defaultValue="social">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="social">Social</TabsTrigger>
            <TabsTrigger value="link">Link</TabsTrigger>
            <TabsTrigger value="embed">Embed</TabsTrigger>
          </TabsList>

          <TabsContent value="social" className="space-y-4 py-4">
            <div className="grid grid-cols-4 gap-4">
              <a
                href={shareLinks.twitter}
                target="_blank"
                rel="noopener noreferrer"
                className="flex flex-col items-center justify-center gap-2"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[#1DA1F2]/10 text-[#1DA1F2]">
                  <Twitter className="h-5 w-5" />
                </div>
                <span className="text-xs">Twitter</span>
              </a>

              <a
                href={shareLinks.facebook}
                target="_blank"
                rel="noopener noreferrer"
                className="flex flex-col items-center justify-center gap-2"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[#1877F2]/10 text-[#1877F2]">
                  <Facebook className="h-5 w-5" />
                </div>
                <span className="text-xs">Facebook</span>
              </a>

              <a
                href="#"
                className="flex flex-col items-center justify-center gap-2"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[#E4405F]/10 text-[#E4405F]">
                  <Instagram className="h-5 w-5" />
                </div>
                <span className="text-xs">Instagram</span>
              </a>

              <a
                href={shareLinks.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                className="flex flex-col items-center justify-center gap-2"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[#0A66C2]/10 text-[#0A66C2]">
                  <Linkedin className="h-5 w-5" />
                </div>
                <span className="text-xs">LinkedIn</span>
              </a>

              <a
                href={shareLinks.email}
                className="flex flex-col items-center justify-center gap-2"
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary">
                  <Mail className="h-5 w-5" />
                </div>
                <span className="text-xs">Email</span>
              </a>

              <button
                className="flex flex-col items-center justify-center gap-2"
                onClick={() => {
                  // This would open the native share dialog on supported devices
                  if (navigator.share) {
                    navigator.share({
                      title: `${item.title} by ${item.artist}`,
                      text: `Check out ${item.title} by ${item.artist} on MusicWave`,
                      url: shareUrl,
                    });
                  }
                }}
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary">
                  <MessageSquare className="h-5 w-5" />
                </div>
                <span className="text-xs">Message</span>
              </button>

              <button
                className="flex flex-col items-center justify-center gap-2"
                onClick={() => copyToClipboard(shareUrl, "Link")}
              >
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary">
                  <Link className="h-5 w-5" />
                </div>
                <span className="text-xs">Copy Link</span>
              </button>

              <button className="flex flex-col items-center justify-center gap-2">
                <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary/10 text-primary">
                  <QrCode className="h-5 w-5" />
                </div>
                <span className="text-xs">QR Code</span>
              </button>
            </div>
          </TabsContent>

          <TabsContent value="link" className="space-y-4 py-4">
            <div className="space-y-2">
              <label htmlFor="share-link" className="text-sm font-medium">
                Share link
              </label>
              <div className="flex items-center space-x-2">
                <Input
                  id="share-link"
                  value={shareUrl}
                  readOnly
                  className="flex-1"
                />
                <Button
                  size="sm"
                  className="flex-shrink-0"
                  onClick={() => copyToClipboard(shareUrl, "Link")}
                >
                  {copied ? (
                    <Check className="h-4 w-4" />
                  ) : (
                    <Copy className="h-4 w-4" />
                  )}
                </Button>
              </div>
            </div>

            <div className="space-y-2">
              <label htmlFor="share-message" className="text-sm font-medium">
                Custom message (optional)
              </label>
              <Textarea
                id="share-message"
                placeholder="Add a personal message..."
                defaultValue={`Check out ${item.title} by ${item.artist} on MusicWave`}
              />
            </div>
          </TabsContent>

          <TabsContent value="embed" className="space-y-4 py-4">
            <div className="space-y-2">
              <label htmlFor="embed-code" className="text-sm font-medium">
                Embed code
              </label>
              <div className="flex items-center space-x-2">
                <Textarea
                  id="embed-code"
                  value={embedCode}
                  readOnly
                  rows={3}
                  className="flex-1 font-mono text-xs"
                />
                <Button
                  size="sm"
                  className="flex-shrink-0"
                  onClick={() => copyToClipboard(embedCode, "Embed code")}
                >
                  {copied ? (
                    <Check className="h-4 w-4" />
                  ) : (
                    <Copy className="h-4 w-4" />
                  )}
                </Button>
              </div>
            </div>

            <div className="rounded-md border p-4">
              <h4 className="text-sm font-medium mb-2">Preview</h4>
              <div className="aspect-video bg-muted rounded-md flex items-center justify-center">
                <div className="text-center p-4">
                  <div className="flex justify-center mb-2">
                    <div className="relative h-16 w-16 overflow-hidden rounded-md">
                      <Image
                        src={item.coverUrl || "/placeholder.svg"}
                        alt={item.title}
                        fill
                        className="object-cover"
                      />
                    </div>
                  </div>
                  <p className="text-sm font-medium">{item.title}</p>
                  <p className="text-xs text-muted-foreground">{item.artist}</p>
                  <p className="text-xs mt-2">MusicWave Player</p>
                </div>
              </div>
            </div>
          </TabsContent>
        </Tabs>

        <DialogFooter className="sm:justify-start">
          <Button
            type="button"
            variant="secondary"
            onClick={() => setOpen(false)}
          >
            Close
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
