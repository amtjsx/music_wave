"use client";

import React from "react";

import {
    ArrowLeft,
    ArrowRight,
    Check,
    Globe,
    Info,
    Instagram,
    Music,
    AirplayIcon as Spotify,
    Twitter,
    Upload,
    Youtube,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import { Checkbox } from "@/components/ui/checkbox";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Progress } from "@/components/ui/progress";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { Separator } from "@/components/ui/separator";
import { Textarea } from "@/components/ui/textarea";
import {
    Tooltip,
    TooltipContent,
    TooltipProvider,
    TooltipTrigger,
} from "@/components/ui/tooltip";

export default function ArtistSignupPage() {
  const router = useRouter();
  const [step, setStep] = useState(1);
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    confirmPassword: "",
    artistName: "",
    bio: "",
    primaryGenre: "",
    secondaryGenres: [] as string[],
    instagram: "",
    twitter: "",
    youtube: "",
    spotify: "",
    website: "",
    paymentMethod: "",
    accountNumber: "",
    routingNumber: "",
    taxId: "",
    termsAgreed: false,
  });

  const totalSteps = 4;
  const progress = (step / totalSteps) * 100;

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSelectChange = (name: string, value: string) => {
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleCheckboxChange = (name: string, checked: boolean) => {
    setFormData((prev) => ({ ...prev, [name]: checked }));
  };

  const handleGenreToggle = (genre: string) => {
    setFormData((prev) => {
      const currentGenres = [...prev.secondaryGenres];
      if (currentGenres.includes(genre)) {
        return {
          ...prev,
          secondaryGenres: currentGenres.filter((g) => g !== genre),
        };
      } else {
        return { ...prev, secondaryGenres: [...currentGenres, genre] };
      }
    });
  };

  const nextStep = () => {
    if (step < totalSteps) {
      setStep(step + 1);
      window.scrollTo(0, 0);
    }
  };

  const prevStep = () => {
    if (step > 1) {
      setStep(step - 1);
      window.scrollTo(0, 0);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    // Simulate API call
    setTimeout(() => {
      setIsLoading(false);
      router.push("/dashboard");
    }, 2000);
  };

  const genres = [
    "Pop",
    "Rock",
    "Hip Hop",
    "R&B",
    "Electronic",
    "Jazz",
    "Classical",
    "Country",
    "Folk",
    "Indie",
    "Metal",
    "Blues",
    "Reggae",
    "Punk",
    "Soul",
    "Funk",
    "Disco",
    "Ambient",
  ];

  return (
    <div className="flex min-h-screen w-full flex-col bg-gradient-to-br from-purple-900/20 via-background to-background">
      {/* Header */}
      <header className="container mx-auto flex h-16 items-center justify-between px-4">
        <Link href="/" className="flex items-center gap-2">
          <Music className="h-6 w-6 text-purple-600" />
          <span className="text-xl font-bold">MusicWave</span>
        </Link>
        <div className="flex items-center gap-4">
          <span className="text-sm text-muted-foreground">
            Already have an account?
          </span>
          <Button variant="outline" asChild>
            <Link href="/auth">Sign In</Link>
          </Button>
        </div>
      </header>

      <main className="container mx-auto flex flex-1 flex-col px-4 py-8">
        <div className="mb-8 text-center">
          <h1 className="text-3xl font-bold">Join MusicWave as an Artist</h1>
          <p className="mt-2 text-muted-foreground">
            Share your music with the world and start earning from your streams
          </p>
        </div>

        {/* Progress bar */}
        <div className="mx-auto mb-8 w-full max-w-md">
          <Progress value={progress} className="h-2" />
          <div className="mt-2 flex justify-between text-xs text-muted-foreground">
            <div className={step >= 1 ? "text-purple-600 font-medium" : ""}>
              Account
            </div>
            <div className={step >= 2 ? "text-purple-600 font-medium" : ""}>
              Profile
            </div>
            <div className={step >= 3 ? "text-purple-600 font-medium" : ""}>
              Platforms
            </div>
            <div className={step >= 4 ? "text-purple-600 font-medium" : ""}>
              Payment
            </div>
          </div>
        </div>

        <Card className="mx-auto w-full max-w-3xl">
          <form onSubmit={handleSubmit}>
            {/* Step 1: Account Information */}
            {step === 1 && (
              <>
                <CardHeader>
                  <CardTitle>Create Your Account</CardTitle>
                  <CardDescription>
                    Enter your personal information to get started
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="firstName">First Name</Label>
                      <Input
                        id="firstName"
                        name="firstName"
                        value={formData.firstName}
                        onChange={handleChange}
                        required
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="lastName">Last Name</Label>
                      <Input
                        id="lastName"
                        name="lastName"
                        value={formData.lastName}
                        onChange={handleChange}
                        required
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="email">Email</Label>
                    <Input
                      id="email"
                      name="email"
                      type="email"
                      value={formData.email}
                      onChange={handleChange}
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="password">Password</Label>
                    <Input
                      id="password"
                      name="password"
                      type="password"
                      value={formData.password}
                      onChange={handleChange}
                      required
                    />
                    <p className="text-xs text-muted-foreground">
                      Password must be at least 8 characters long with a mix of
                      letters, numbers, and symbols
                    </p>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="confirmPassword">Confirm Password</Label>
                    <Input
                      id="confirmPassword"
                      name="confirmPassword"
                      type="password"
                      value={formData.confirmPassword}
                      onChange={handleChange}
                      required
                    />
                  </div>
                </CardContent>
              </>
            )}

            {/* Step 2: Artist Profile */}
            {step === 2 && (
              <>
                <CardHeader>
                  <CardTitle>Artist Profile</CardTitle>
                  <CardDescription>
                    Tell us about yourself and your music
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="artistName">Artist/Band Name</Label>
                    <Input
                      id="artistName"
                      name="artistName"
                      value={formData.artistName}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                    <div className="space-y-2">
                      <Label>Profile Image</Label>
                      <div className="flex flex-col items-center justify-center rounded-md border border-dashed p-4">
                        <div className="mb-3 h-24 w-24 overflow-hidden rounded-full bg-muted">
                          <Image
                            src="/artist-profile.png"
                            alt="Profile preview"
                            width={96}
                            height={96}
                            className="h-full w-full object-cover"
                          />
                        </div>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          className="gap-2"
                        >
                          <Upload className="h-4 w-4" />
                          Upload Photo
                        </Button>
                        <p className="mt-2 text-xs text-muted-foreground">
                          JPG, PNG or GIF, max 2MB
                        </p>
                      </div>
                    </div>

                    <div className="space-y-2">
                      <Label>Cover Image</Label>
                      <div className="flex flex-col items-center justify-center rounded-md border border-dashed p-4">
                        <div className="mb-3 h-24 w-full overflow-hidden rounded-md bg-muted">
                          <Image
                            src="/abstract-music-cover.png"
                            alt="Cover preview"
                            width={192}
                            height={96}
                            className="h-full w-full object-cover"
                          />
                        </div>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          className="gap-2"
                        >
                          <Upload className="h-4 w-4" />
                          Upload Cover
                        </Button>
                        <p className="mt-2 text-xs text-muted-foreground">
                          Recommended size: 1400x400px
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="bio">Bio</Label>
                    <Textarea
                      id="bio"
                      name="bio"
                      value={formData.bio}
                      onChange={handleChange}
                      placeholder="Tell your fans about yourself and your music..."
                      className="min-h-[120px]"
                    />
                    <p className="text-xs text-muted-foreground">
                      {formData.bio.length}/500 characters
                    </p>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="primaryGenre">Primary Genre</Label>
                    <Select
                      value={formData.primaryGenre}
                      onValueChange={(value) =>
                        handleSelectChange("primaryGenre", value)
                      }
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
                    <Label>Secondary Genres (Select up to 3)</Label>
                    <div className="flex flex-wrap gap-2">
                      {genres.map((genre) => (
                        <Badge
                          key={genre}
                          variant={
                            formData.secondaryGenres.includes(genre)
                              ? "default"
                              : "outline"
                          }
                          className={`cursor-pointer ${
                            formData.secondaryGenres.includes(genre)
                              ? "bg-purple-600 hover:bg-purple-700"
                              : ""
                          }`}
                          onClick={() => {
                            if (
                              !formData.secondaryGenres.includes(genre) &&
                              formData.secondaryGenres.length < 3
                            ) {
                              handleGenreToggle(genre);
                            } else if (
                              formData.secondaryGenres.includes(genre)
                            ) {
                              handleGenreToggle(genre);
                            }
                          }}
                        >
                          {genre}
                          {formData.secondaryGenres.includes(genre) && (
                            <Check className="ml-1 h-3 w-3" />
                          )}
                        </Badge>
                      ))}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      {formData.secondaryGenres.length}/3 genres selected
                    </p>
                  </div>
                </CardContent>
              </>
            )}

            {/* Step 3: Social Media & Platforms */}
            {step === 3 && (
              <>
                <CardHeader>
                  <CardTitle>Your Online Presence</CardTitle>
                  <CardDescription>
                    Connect your social media accounts and music platforms
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label
                      htmlFor="instagram"
                      className="flex items-center gap-2"
                    >
                      <Instagram className="h-4 w-4 text-pink-600" />
                      Instagram
                    </Label>
                    <Input
                      id="instagram"
                      name="instagram"
                      placeholder="@username"
                      value={formData.instagram}
                      onChange={handleChange}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label
                      htmlFor="twitter"
                      className="flex items-center gap-2"
                    >
                      <Twitter className="h-4 w-4 text-blue-400" />
                      Twitter
                    </Label>
                    <Input
                      id="twitter"
                      name="twitter"
                      placeholder="@username"
                      value={formData.twitter}
                      onChange={handleChange}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label
                      htmlFor="youtube"
                      className="flex items-center gap-2"
                    >
                      <Youtube className="h-4 w-4 text-red-600" />
                      YouTube Channel
                    </Label>
                    <Input
                      id="youtube"
                      name="youtube"
                      placeholder="youtube.com/channel/..."
                      value={formData.youtube}
                      onChange={handleChange}
                    />
                  </div>

                  <Separator />

                  <div className="space-y-2">
                    <Label
                      htmlFor="spotify"
                      className="flex items-center gap-2"
                    >
                      <Spotify className="h-4 w-4 text-green-600" />
                      Spotify Artist Link
                    </Label>
                    <Input
                      id="spotify"
                      name="spotify"
                      placeholder="open.spotify.com/artist/..."
                      value={formData.spotify}
                      onChange={handleChange}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label
                      htmlFor="website"
                      className="flex items-center gap-2"
                    >
                      <Globe className="h-4 w-4" />
                      Website
                    </Label>
                    <Input
                      id="website"
                      name="website"
                      placeholder="https://yourwebsite.com"
                      value={formData.website}
                      onChange={handleChange}
                    />
                  </div>

                  <div className="rounded-md bg-muted p-4">
                    <div className="flex items-start gap-3">
                      <Info className="mt-0.5 h-5 w-5 text-blue-500" />
                      <div>
                        <h4 className="text-sm font-medium">
                          Why connect your accounts?
                        </h4>
                        <p className="text-xs text-muted-foreground">
                          Connecting your existing platforms helps us verify
                          your identity as an artist and allows your fans to
                          find all your content in one place. It also helps with
                          royalty distribution across platforms.
                        </p>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </>
            )}

            {/* Step 4: Payment Information */}
            {step === 4 && (
              <>
                <CardHeader>
                  <CardTitle>Payment Information</CardTitle>
                  <CardDescription>
                    Set up how you'll receive your earnings
                  </CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="paymentMethod">Payment Method</Label>
                    <Select
                      value={formData.paymentMethod}
                      onValueChange={(value) =>
                        handleSelectChange("paymentMethod", value)
                      }
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select payment method" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="bankTransfer">
                          Direct Bank Transfer
                        </SelectItem>
                        <SelectItem value="paypal">PayPal</SelectItem>
                        <SelectItem value="stripe">Stripe</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  {formData.paymentMethod === "bankTransfer" && (
                    <>
                      <div className="space-y-2">
                        <Label htmlFor="accountNumber">Account Number</Label>
                        <Input
                          id="accountNumber"
                          name="accountNumber"
                          value={formData.accountNumber}
                          onChange={handleChange}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label htmlFor="routingNumber">Routing Number</Label>
                        <Input
                          id="routingNumber"
                          name="routingNumber"
                          value={formData.routingNumber}
                          onChange={handleChange}
                        />
                      </div>
                    </>
                  )}

                  <div className="space-y-2">
                    <Label htmlFor="taxId">
                      <div className="flex items-center gap-2">
                        Tax ID / SSN
                        <TooltipProvider>
                          <Tooltip>
                            <TooltipTrigger asChild>
                              <Info className="h-4 w-4 text-muted-foreground" />
                            </TooltipTrigger>
                            <TooltipContent>
                              <p className="max-w-xs text-xs">
                                Required for tax purposes. For individuals, this
                                is typically your Social Security Number. For
                                businesses, this is your Employer Identification
                                Number.
                              </p>
                            </TooltipContent>
                          </Tooltip>
                        </TooltipProvider>
                      </div>
                    </Label>
                    <Input
                      id="taxId"
                      name="taxId"
                      value={formData.taxId}
                      onChange={handleChange}
                    />
                    <p className="text-xs text-muted-foreground">
                      Your tax information is encrypted and securely stored
                    </p>
                  </div>

                  <div className="rounded-md bg-muted p-4">
                    <h4 className="mb-2 text-sm font-medium">
                      Royalty Distribution
                    </h4>
                    <p className="text-xs text-muted-foreground">
                      MusicWave pays artists 70% of all revenue generated from
                      streams. Payments are processed monthly for all earnings
                      over $20. You'll receive detailed reports on your earnings
                      in your dashboard.
                    </p>
                  </div>

                  <div className="flex items-start space-x-2">
                    <Checkbox
                      id="termsAgreed"
                      checked={formData.termsAgreed}
                      onCheckedChange={(checked) =>
                        handleCheckboxChange("termsAgreed", checked as boolean)
                      }
                    />
                    <div className="grid gap-1.5 leading-none">
                      <Label
                        htmlFor="termsAgreed"
                        className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                      >
                        I agree to the terms and conditions
                      </Label>
                      <p className="text-xs text-muted-foreground">
                        By checking this box, you agree to our{" "}
                        <Link
                          href="/terms"
                          className="text-purple-600 hover:underline"
                        >
                          Terms of Service
                        </Link>
                        ,{" "}
                        <Link
                          href="/privacy"
                          className="text-purple-600 hover:underline"
                        >
                          Privacy Policy
                        </Link>
                        , and{" "}
                        <Link
                          href="/artist-agreement"
                          className="text-purple-600 hover:underline"
                        >
                          Artist Agreement
                        </Link>
                        .
                      </p>
                    </div>
                  </div>
                </CardContent>
              </>
            )}

            <CardFooter className="flex justify-between">
              <Button
                type="button"
                variant="outline"
                onClick={prevStep}
                disabled={step === 1}
                className="gap-2"
              >
                <ArrowLeft className="h-4 w-4" /> Back
              </Button>

              {step < totalSteps ? (
                <Button
                  type="button"
                  onClick={nextStep}
                  className="gap-2 bg-purple-600 hover:bg-purple-700"
                >
                  Next <ArrowRight className="h-4 w-4" />
                </Button>
              ) : (
                <Button
                  type="submit"
                  disabled={!formData.termsAgreed || isLoading}
                  className="gap-2 bg-purple-600 hover:bg-purple-700"
                >
                  {isLoading ? "Creating Account..." : "Complete Sign Up"}
                </Button>
              )}
            </CardFooter>
          </form>
        </Card>

        {/* Benefits section */}
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          <div className="rounded-lg border bg-card p-6">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900">
              <Music className="h-6 w-6 text-purple-600" />
            </div>
            <h3 className="mb-2 text-lg font-medium">Share Your Music</h3>
            <p className="text-sm text-muted-foreground">
              Upload your tracks and reach millions of potential fans worldwide.
              No label required.
            </p>
          </div>
          <div className="rounded-lg border bg-card p-6">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="h-6 w-6 text-purple-600"
              >
                <circle cx="12" cy="12" r="10" />
                <path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20" />
                <path d="M2 12h20" />
              </svg>
            </div>
            <h3 className="mb-2 text-lg font-medium">Global Reach</h3>
            <p className="text-sm text-muted-foreground">
              Get discovered by listeners around the world with our personalized
              recommendation algorithms.
            </p>
          </div>
          <div className="rounded-lg border bg-card p-6">
            <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="h-6 w-6 text-purple-600"
              >
                <path d="M18 21V19C18 17.9391 17.5786 16.9217 16.8284 16.1716C16.0783 15.4214 15.0609 15 14 15H10C8.93913 15 7.92172 15.4214 7.17157 16.1716C6.42143 16.9217 6 17.9391 6 19V21" />
                <path d="M12 11C14.2091 11 16 9.20914 16 7C16 4.79086 14.2091 3 12 3C9.79086 3 8 4.79086 8 7C8 9.20914 9.79086 11 12 11Z" />
                <path d="M9 21H15" />
              </svg>
            </div>
            <h3 className="mb-2 text-lg font-medium">Fair Compensation</h3>
            <p className="text-sm text-muted-foreground">
              Earn 70% of all revenue generated from your music with transparent
              royalty payments.
            </p>
          </div>
        </div>
      </main>

      <footer className="border-t bg-muted/40 py-6">
        <div className="container mx-auto px-4">
          <div className="flex flex-col items-center justify-between gap-4 md:flex-row">
            <div className="flex items-center gap-2">
              <Music className="h-5 w-5 text-purple-600" />
              <span className="text-sm font-semibold">MusicWave</span>
            </div>
            <div className="flex gap-6 text-sm text-muted-foreground">
              <Link href="/about" className="hover:text-foreground">
                About
              </Link>
              <Link href="/terms" className="hover:text-foreground">
                Terms
              </Link>
              <Link href="/privacy" className="hover:text-foreground">
                Privacy
              </Link>
              <Link href="/help" className="hover:text-foreground">
                Help
              </Link>
            </div>
            <div className="text-xs text-muted-foreground">
              © {new Date().getFullYear()} MusicWave. All rights reserved.
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
