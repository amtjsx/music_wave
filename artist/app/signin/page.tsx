"use client";

import type React from "react";

import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Apple, Lock, Mail, Music } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

export default function AuthPage() {
  const [isLoading, setIsLoading] = useState<boolean>(false);

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    setIsLoading(true);
    // Simulate API call
    setTimeout(() => {
      setIsLoading(false);
    }, 1000);
  };

  return (
    <div className="flex min-h-screen w-full">
      {/* Left side - Auth forms */}
      <div className="flex w-full max-w-lg mx-auto flex-col justify-center space-y-6 px-4 md:w-1/2 md:px-8 lg:px-12">
        <div className="flex items-center space-x-2">
          <Music className="h-6 w-6 text-purple-600" />
          <span className="text-xl font-bold">MusicWave</span>
        </div>
        <div className="space-y-2">
          <h1 className="text-3xl font-bold">Welcome to MusicWave</h1>
          <p className="text-muted-foreground">
            Sign in to your account to continue your musical journey
          </p>
        </div>

        <h2 className="font-bold text-2xl">Sign In</h2>

        <div className="space-y-4">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <div className="relative">
                <Mail className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                <Input
                  id="email"
                  type="email"
                  placeholder="name@example.com"
                  className="pl-10"
                  required
                />
              </div>
            </div>
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <Label htmlFor="password">Password</Label>
                <Link
                  href="/forgot-password"
                  className="text-xs text-purple-600 hover:underline"
                >
                  Forgot password?
                </Link>
              </div>
              <div className="relative">
                <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
                <Input
                  id="password"
                  type="password"
                  className="pl-10"
                  required
                />
              </div>
            </div>
            <div className="flex items-center space-x-2">
              <Checkbox id="remember" />
              <Label htmlFor="remember" className="text-sm">
                Remember me
              </Label>
            </div>
            <Button
              type="submit"
              className="w-full bg-purple-600 hover:bg-purple-700"
              disabled={isLoading}
            >
              {isLoading ? "Signing in..." : "Sign In"}
            </Button>
          </form>

          <div className="relative my-4">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-background px-2 text-muted-foreground">
                Or continue with
              </span>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Button
              variant="outline"
              className="flex items-center justify-center gap-2"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="lucide lucide-chrome"
              >
                <circle cx="12" cy="12" r="10" />
                <circle cx="12" cy="12" r="4" />
                <line x1="21.17" x2="12" y1="8" y2="8" />
                <line x1="3.95" x2="8.54" y1="6.06" y2="14" />
                <line x1="10.88" x2="15.46" y1="21.94" y2="14" />
              </svg>
              Google
            </Button>
            <Button
              variant="outline"
              className="flex items-center justify-center gap-2"
            >
              <Apple className="h-4 w-4" />
              Apple
            </Button>
          </div>
          <Link
            href="/signup"
            className="text-sm mt-4 text-center text-purple-600 hover:underline"
          >
            Don't have an account? Sign up
          </Link>
        </div>
      </div>

      {/* Right side - Image */}
      <div className="hidden bg-gradient-to-br from-purple-900 via-purple-800 to-indigo-900 md:flex md:w-1/2 md:flex-col md:items-center md:justify-center">
        <div className="px-8 text-center">
          <div className="mb-4 flex justify-center">
            <Image
              src="/abstract-music-waves.png"
              alt="Music visualization"
              width={300}
              height={300}
              className="rounded-full"
            />
          </div>
          <h2 className="mb-2 text-2xl font-bold text-white">
            Discover Your Sound
          </h2>
          <p className="mb-6 text-gray-200">
            Join MusicWave today and unlock a world of music tailored just for
            you.
          </p>
          <div className="flex justify-center space-x-4">
            <div className="flex items-center space-x-1 rounded-full bg-white/10 px-3 py-1 text-sm text-white">
              <span>50M+ Songs</span>
            </div>
            <div className="flex items-center space-x-1 rounded-full bg-white/10 px-3 py-1 text-sm text-white">
              <span>HD Audio</span>
            </div>
            <div className="flex items-center space-x-1 rounded-full bg-white/10 px-3 py-1 text-sm text-white">
              <span>Ad-free</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
