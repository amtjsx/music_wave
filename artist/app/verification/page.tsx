"use client";

import React from "react";

import {
    AlertCircle,
    CheckCircle,
    Clock,
    FileText,
    Globe,
    ImageIcon,
    Info,
    Shield,
    X,
} from "lucide-react";
import { useRouter } from "next/navigation";
import { useState } from "react";

import {
    Accordion,
    AccordionContent,
    AccordionItem,
    AccordionTrigger,
} from "@/components/ui/accordion";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { FileUploader } from "./file-uploader";

export default function VerificationPage() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState("overview");
  const [verificationStatus, setVerificationStatus] = useState("not_started"); // not_started, in_progress, pending_review, verified, rejected
  const [uploadedFiles, setUploadedFiles] = useState<{
    [key: string]: { name: string; size: string; type: string }[];
  }>({
    identity: [],
    professional: [],
    social: [],
  });
  const [formData, setFormData] = useState({
    fullLegalName: "",
    artistName: "Jane Doe", // Pre-filled from profile
    idType: "",
    idNumber: "",
    country: "",
    professionalDescription: "",
    recordLabel: "",
    distributorName: "",
    spotifyLink: "",
    appleMusicLink: "",
    instagramLink: "",
    twitterLink: "",
    websiteLink: "",
    additionalInfo: "",
    termsAgreed: false,
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

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

  const handleFileUpload = (
    category: string,
    files: { name: string; size: string; type: string }[]
  ) => {
    setUploadedFiles((prev) => ({
      ...prev,
      [category]: [...prev[category], ...files],
    }));
  };

  const removeFile = (category: string, index: number) => {
    setUploadedFiles((prev) => ({
      ...prev,
      [category]: prev[category].filter((_, i) => i !== index),
    }));
  };

  const startVerification = () => {
    setVerificationStatus("in_progress");
    setActiveTab("identity");
  };

  const submitVerification = () => {
    setIsSubmitting(true);

    // Simulate API call
    setTimeout(() => {
      setIsSubmitting(false);
      setVerificationStatus("pending_review");
      setActiveTab("overview");
    }, 2000);
  };

  const getVerificationProgress = () => {
    if (verificationStatus === "not_started") return 0;
    if (verificationStatus === "in_progress") {
      // Calculate based on filled sections
      let progress = 0;
      if (uploadedFiles.identity.length > 0) progress += 33;
      if (uploadedFiles.professional.length > 0) progress += 33;
      if (uploadedFiles.social.length > 0) progress += 34;
      return progress;
    }
    if (verificationStatus === "pending_review") return 100;
    if (verificationStatus === "verified") return 100;
    if (verificationStatus === "rejected") return 100;
    return 0;
  };

  const renderStatusBadge = () => {
    switch (verificationStatus) {
      case "not_started":
        return (
          <Badge variant="outline" className="gap-1 text-muted-foreground">
            <Clock className="h-3 w-3" /> Not Started
          </Badge>
        );
      case "in_progress":
        return (
          <Badge
            variant="outline"
            className="gap-1 text-blue-500 border-blue-200 bg-blue-100 dark:border-blue-800 dark:bg-blue-950"
          >
            <Clock className="h-3 w-3" /> In Progress
          </Badge>
        );
      case "pending_review":
        return (
          <Badge
            variant="outline"
            className="gap-1 text-orange-500 border-orange-200 bg-orange-100 dark:border-orange-800 dark:bg-orange-950"
          >
            <Clock className="h-3 w-3" /> Under Review
          </Badge>
        );
      case "verified":
        return (
          <Badge className="gap-1 bg-green-600">
            <CheckCircle className="h-3 w-3" /> Verified
          </Badge>
        );
      case "rejected":
        return (
          <Badge variant="destructive" className="gap-1">
            <X className="h-3 w-3" /> Rejected
          </Badge>
        );
      default:
        return null;
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Artist Verification
          </h1>
          <p className="text-muted-foreground">
            Verify your identity to unlock premium features and build trust with
            your audience
          </p>
        </div>
        <div className="flex items-center gap-2">{renderStatusBadge()}</div>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger
            value="identity"
            disabled={
              verificationStatus === "not_started" ||
              verificationStatus === "pending_review" ||
              verificationStatus === "verified"
            }
          >
            Identity
          </TabsTrigger>
          <TabsTrigger
            value="professional"
            disabled={
              verificationStatus === "not_started" ||
              verificationStatus === "pending_review" ||
              verificationStatus === "verified"
            }
          >
            Professional
          </TabsTrigger>
          <TabsTrigger
            value="social"
            disabled={
              verificationStatus === "not_started" ||
              verificationStatus === "pending_review" ||
              verificationStatus === "verified"
            }
          >
            Social Media
          </TabsTrigger>
        </TabsList>

        {/* Overview Tab */}
        <TabsContent value="overview">
          <div className="grid gap-6 md:grid-cols-2">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Shield className="h-5 w-5 text-purple-600" />
                  Verification Status
                </CardTitle>
                <CardDescription>
                  Track your verification progress
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <div className="flex items-center justify-between">
                    <span className="text-sm font-medium">
                      Verification Progress
                    </span>
                    <span className="text-sm text-muted-foreground">
                      {getVerificationProgress()}%
                    </span>
                  </div>
                  <Progress value={getVerificationProgress()} className="h-2" />
                </div>

                {verificationStatus === "not_started" && (
                  <div className="rounded-lg border p-4">
                    <h3 className="mb-2 text-sm font-medium">
                      Get Verified in 3 Steps
                    </h3>
                    <ol className="space-y-3 text-sm">
                      <li className="flex items-start gap-2">
                        <div className="flex h-5 w-5 items-center justify-center rounded-full bg-muted text-xs font-medium">
                          1
                        </div>
                        <div>
                          <span className="font-medium">
                            Identity Verification
                          </span>
                          <p className="text-xs text-muted-foreground">
                            Confirm your legal identity with government-issued
                            ID
                          </p>
                        </div>
                      </li>
                      <li className="flex items-start gap-2">
                        <div className="flex h-5 w-5 items-center justify-center rounded-full bg-muted text-xs font-medium">
                          2
                        </div>
                        <div>
                          <span className="font-medium">
                            Professional Verification
                          </span>
                          <p className="text-xs text-muted-foreground">
                            Provide evidence of your music career
                          </p>
                        </div>
                      </li>
                      <li className="flex items-start gap-2">
                        <div className="flex h-5 w-5 items-center justify-center rounded-full bg-muted text-xs font-medium">
                          3
                        </div>
                        <div>
                          <span className="font-medium">
                            Social Media Verification
                          </span>
                          <p className="text-xs text-muted-foreground">
                            Link your official social media accounts
                          </p>
                        </div>
                      </li>
                    </ol>
                    <Button
                      onClick={startVerification}
                      className="mt-4 w-full bg-purple-600 hover:bg-purple-700"
                    >
                      Start Verification Process
                    </Button>
                  </div>
                )}

                {verificationStatus === "in_progress" && (
                  <div className="rounded-lg border p-4">
                    <h3 className="mb-2 text-sm font-medium">
                      Verification in Progress
                    </h3>
                    <p className="text-sm text-muted-foreground">
                      Complete all three verification steps to submit your
                      application.
                    </p>
                    <div className="mt-3 space-y-2">
                      <div className="flex items-center justify-between">
                        <span className="text-xs">Identity Verification</span>
                        {uploadedFiles.identity.length > 0 ? (
                          <Badge
                            variant="outline"
                            className="text-green-600 border-green-200 bg-green-100 dark:border-green-800 dark:bg-green-950"
                          >
                            <CheckCircle className="mr-1 h-3 w-3" /> Complete
                          </Badge>
                        ) : (
                          <Badge
                            variant="outline"
                            className="text-muted-foreground"
                          >
                            Incomplete
                          </Badge>
                        )}
                      </div>
                      <div className="flex items-center justify-between">
                        <span className="text-xs">
                          Professional Verification
                        </span>
                        {uploadedFiles.professional.length > 0 ? (
                          <Badge
                            variant="outline"
                            className="text-green-600 border-green-200 bg-green-100 dark:border-green-800 dark:bg-green-950"
                          >
                            <CheckCircle className="mr-1 h-3 w-3" /> Complete
                          </Badge>
                        ) : (
                          <Badge
                            variant="outline"
                            className="text-muted-foreground"
                          >
                            Incomplete
                          </Badge>
                        )}
                      </div>
                      <div className="flex items-center justify-between">
                        <span className="text-xs">
                          Social Media Verification
                        </span>
                        {uploadedFiles.social.length > 0 ? (
                          <Badge
                            variant="outline"
                            className="text-green-600 border-green-200 bg-green-100 dark:border-green-800 dark:bg-green-950"
                          >
                            <CheckCircle className="mr-1 h-3 w-3" /> Complete
                          </Badge>
                        ) : (
                          <Badge
                            variant="outline"
                            className="text-muted-foreground"
                          >
                            Incomplete
                          </Badge>
                        )}
                      </div>
                    </div>
                    <Button
                      onClick={submitVerification}
                      className="mt-4 w-full bg-purple-600 hover:bg-purple-700"
                      disabled={
                        uploadedFiles.identity.length === 0 ||
                        uploadedFiles.professional.length === 0 ||
                        uploadedFiles.social.length === 0 ||
                        !formData.termsAgreed ||
                        isSubmitting
                      }
                    >
                      {isSubmitting
                        ? "Submitting..."
                        : "Submit Verification Request"}
                    </Button>
                  </div>
                )}

                {verificationStatus === "pending_review" && (
                  <div className="rounded-lg border p-4">
                    <div className="flex items-center gap-3">
                      <div className="flex h-10 w-10 items-center justify-center rounded-full bg-orange-100 dark:bg-orange-900">
                        <Clock className="h-5 w-5 text-orange-600" />
                      </div>
                      <div>
                        <h3 className="text-sm font-medium">Under Review</h3>
                        <p className="text-xs text-muted-foreground">
                          Your verification request is being reviewed by our
                          team.
                        </p>
                      </div>
                    </div>
                    <div className="mt-3 rounded-md bg-muted p-3">
                      <p className="text-xs">
                        Estimated review time:{" "}
                        <span className="font-medium">3-5 business days</span>
                      </p>
                      <p className="mt-1 text-xs text-muted-foreground">
                        You'll receive an email notification once the review is
                        complete.
                      </p>
                    </div>
                  </div>
                )}

                {verificationStatus === "verified" && (
                  <div className="rounded-lg border p-4">
                    <div className="flex items-center gap-3">
                      <div className="flex h-10 w-10 items-center justify-center rounded-full bg-green-100 dark:bg-green-900">
                        <CheckCircle className="h-5 w-5 text-green-600" />
                      </div>
                      <div>
                        <h3 className="text-sm font-medium">
                          Verification Approved
                        </h3>
                        <p className="text-xs text-muted-foreground">
                          Congratulations! Your artist profile is now verified.
                        </p>
                      </div>
                    </div>
                    <div className="mt-3 rounded-md bg-muted p-3">
                      <p className="text-xs">
                        Verified on:{" "}
                        <span className="font-medium">May 18, 2025</span>
                      </p>
                      <p className="mt-1 text-xs text-muted-foreground">
                        Your verification badge is now visible on your profile.
                      </p>
                    </div>
                  </div>
                )}

                {verificationStatus === "rejected" && (
                  <div className="rounded-lg border border-red-200 bg-red-50 p-4 dark:border-red-800 dark:bg-red-950">
                    <div className="flex items-center gap-3">
                      <div className="flex h-10 w-10 items-center justify-center rounded-full bg-red-100 dark:bg-red-900">
                        <AlertCircle className="h-5 w-5 text-red-600" />
                      </div>
                      <div>
                        <h3 className="text-sm font-medium">
                          Verification Rejected
                        </h3>
                        <p className="text-xs text-muted-foreground">
                          Your verification request was not approved.
                        </p>
                      </div>
                    </div>
                    <div className="mt-3 rounded-md bg-background p-3">
                      <p className="text-xs font-medium">
                        Reason for rejection:
                      </p>
                      <p className="mt-1 text-xs text-muted-foreground">
                        The provided identification documents could not be
                        verified. Please ensure your ID is clearly visible and
                        matches your account information.
                      </p>
                    </div>
                    <Button onClick={startVerification} className="mt-4 w-full">
                      Try Again
                    </Button>
                  </div>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Verification Benefits</CardTitle>
                <CardDescription>
                  Why get verified on MusicWave?
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-start gap-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900">
                    <CheckCircle className="h-4 w-4 text-purple-600" />
                  </div>
                  <div>
                    <h3 className="text-sm font-medium">
                      Build Trust with Fans
                    </h3>
                    <p className="text-xs text-muted-foreground">
                      A verification badge shows fans they're following the real
                      you, not an impersonator.
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900">
                    <CheckCircle className="h-4 w-4 text-purple-600" />
                  </div>
                  <div>
                    <h3 className="text-sm font-medium">Enhanced Visibility</h3>
                    <p className="text-xs text-muted-foreground">
                      Verified artists receive priority placement in search
                      results and recommendations.
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900">
                    <CheckCircle className="h-4 w-4 text-purple-600" />
                  </div>
                  <div>
                    <h3 className="text-sm font-medium">
                      Access to Premium Features
                    </h3>
                    <p className="text-xs text-muted-foreground">
                      Unlock advanced analytics, promotional tools, and early
                      access to new features.
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className="flex h-8 w-8 items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900">
                    <CheckCircle className="h-4 w-4 text-purple-600" />
                  </div>
                  <div>
                    <h3 className="text-sm font-medium">
                      Direct Support Channel
                    </h3>
                    <p className="text-xs text-muted-foreground">
                      Verified artists get priority customer support and access
                      to our artist relations team.
                    </p>
                  </div>
                </div>

                <Separator className="my-2" />

                <Accordion type="single" collapsible className="w-full">
                  <AccordionItem value="faq-1">
                    <AccordionTrigger className="text-sm">
                      How long does verification take?
                    </AccordionTrigger>
                    <AccordionContent className="text-xs text-muted-foreground">
                      The verification process typically takes 3-5 business days
                      after you submit all required documentation. Complex cases
                      may take longer.
                    </AccordionContent>
                  </AccordionItem>
                  <AccordionItem value="faq-2">
                    <AccordionTrigger className="text-sm">
                      What if my verification is rejected?
                    </AccordionTrigger>
                    <AccordionContent className="text-xs text-muted-foreground">
                      If your verification is rejected, you'll receive a
                      detailed explanation why. You can address the issues and
                      resubmit your application.
                    </AccordionContent>
                  </AccordionItem>
                  <AccordionItem value="faq-3">
                    <AccordionTrigger className="text-sm">
                      Is my personal information secure?
                    </AccordionTrigger>
                    <AccordionContent className="text-xs text-muted-foreground">
                      Yes, all verification documents are encrypted and stored
                      securely. We only use them to verify your identity and
                      don't share them with third parties.
                    </AccordionContent>
                  </AccordionItem>
                </Accordion>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* Identity Verification Tab */}
        <TabsContent value="identity">
          <Card>
            <CardHeader>
              <CardTitle>Identity Verification</CardTitle>
              <CardDescription>
                Confirm your legal identity with government-issued ID
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <Alert>
                <Info className="h-4 w-4" />
                <AlertTitle>Secure Document Handling</AlertTitle>
                <AlertDescription>
                  Your identification documents are encrypted and stored
                  securely. They are only used for verification purposes and
                  will never be shared with third parties.
                </AlertDescription>
              </Alert>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="fullLegalName">Full Legal Name</Label>
                  <Input
                    id="fullLegalName"
                    name="fullLegalName"
                    value={formData.fullLegalName}
                    onChange={handleChange}
                    placeholder="As it appears on your ID"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="artistName">Artist/Band Name</Label>
                  <Input
                    id="artistName"
                    name="artistName"
                    value={formData.artistName}
                    onChange={handleChange}
                    disabled
                  />
                  <p className="text-xs text-muted-foreground">
                    This is your current artist name from your profile
                  </p>
                </div>
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="idType">ID Type</Label>
                  <Select
                    onValueChange={(value) =>
                      handleSelectChange("idType", value)
                    }
                  >
                    <SelectTrigger id="idType">
                      <SelectValue placeholder="Select ID type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="passport">Passport</SelectItem>
                      <SelectItem value="drivers_license">
                        Driver's License
                      </SelectItem>
                      <SelectItem value="national_id">
                        National ID Card
                      </SelectItem>
                      <SelectItem value="residence_permit">
                        Residence Permit
                      </SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="idNumber">
                    ID Number (Last 4 digits only)
                  </Label>
                  <Input
                    id="idNumber"
                    name="idNumber"
                    value={formData.idNumber}
                    onChange={handleChange}
                    placeholder="e.g. XXXX"
                    maxLength={4}
                  />
                  <p className="text-xs text-muted-foreground">
                    For security, only enter the last 4 digits
                  </p>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="country">Country of Issue</Label>
                <Select
                  onValueChange={(value) =>
                    handleSelectChange("country", value)
                  }
                >
                  <SelectTrigger id="country">
                    <SelectValue placeholder="Select country" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="us">United States</SelectItem>
                    <SelectItem value="ca">Canada</SelectItem>
                    <SelectItem value="uk">United Kingdom</SelectItem>
                    <SelectItem value="au">Australia</SelectItem>
                    <SelectItem value="de">Germany</SelectItem>
                    <SelectItem value="fr">France</SelectItem>
                    <SelectItem value="jp">Japan</SelectItem>
                    <SelectItem value="other">Other</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="space-y-2">
                <Label>Upload ID Document</Label>
                <FileUploader
                  onFilesAdded={(files) => handleFileUpload("identity", files)}
                  acceptedFileTypes={[
                    "image/jpeg",
                    "image/png",
                    "application/pdf",
                  ]}
                  maxFileSizeMB={5}
                  maxFiles={2}
                />
                <p className="text-xs text-muted-foreground">
                  Upload a clear photo of your government-issued ID. We accept
                  JPG, PNG, or PDF files up to 5MB.
                </p>
              </div>

              {uploadedFiles.identity.length > 0 && (
                <div className="space-y-2">
                  <Label>Uploaded Documents</Label>
                  <div className="rounded-md border">
                    {uploadedFiles.identity.map((file, index) => (
                      <div
                        key={index}
                        className="flex items-center justify-between border-b p-3 last:border-0"
                      >
                        <div className="flex items-center gap-3">
                          {file.type.includes("image") ? (
                            <ImageIcon className="h-5 w-5 text-muted-foreground" />
                          ) : (
                            <FileText className="h-5 w-5 text-muted-foreground" />
                          )}
                          <div>
                            <p className="text-sm font-medium">{file.name}</p>
                            <p className="text-xs text-muted-foreground">
                              {file.size}
                            </p>
                          </div>
                        </div>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => removeFile("identity", index)}
                        >
                          <X className="h-4 w-4" />
                        </Button>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </CardContent>
            <CardFooter className="flex justify-end">
              <Button
                onClick={() => setActiveTab("professional")}
                className="bg-purple-600 hover:bg-purple-700"
                disabled={uploadedFiles.identity.length === 0}
              >
                Continue to Professional Verification
              </Button>
            </CardFooter>
          </Card>
        </TabsContent>

        {/* Professional Verification Tab */}
        <TabsContent value="professional">
          <Card>
            <CardHeader>
              <CardTitle>Professional Verification</CardTitle>
              <CardDescription>
                Provide evidence of your music career
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-2">
                <Label htmlFor="professionalDescription">
                  Professional Background
                </Label>
                <Textarea
                  id="professionalDescription"
                  name="professionalDescription"
                  value={formData.professionalDescription}
                  onChange={handleChange}
                  placeholder="Describe your music career, including notable achievements, releases, performances, etc."
                  className="min-h-[120px]"
                />
              </div>

              <div className="grid gap-4 md:grid-cols-2">
                <div className="space-y-2">
                  <Label htmlFor="recordLabel">
                    Record Label (if applicable)
                  </Label>
                  <Input
                    id="recordLabel"
                    name="recordLabel"
                    value={formData.recordLabel}
                    onChange={handleChange}
                    placeholder="e.g. Universal Music"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="distributorName">
                    Music Distributor (if applicable)
                  </Label>
                  <Input
                    id="distributorName"
                    name="distributorName"
                    value={formData.distributorName}
                    onChange={handleChange}
                    placeholder="e.g. DistroKid, CD Baby"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label>Upload Professional Evidence</Label>
                <FileUploader
                  onFilesAdded={(files) =>
                    handleFileUpload("professional", files)
                  }
                  acceptedFileTypes={[
                    "image/jpeg",
                    "image/png",
                    "application/pdf",
                  ]}
                  maxFileSizeMB={10}
                  maxFiles={5}
                />
                <p className="text-xs text-muted-foreground">
                  Upload documents that prove your professional status as an
                  artist. This could include:
                </p>
                <ul className="ml-5 list-disc text-xs text-muted-foreground">
                  <li>Record label contracts</li>
                  <li>Distribution agreements</li>
                  <li>Performance contracts</li>
                  <li>Press features</li>
                  <li>Album/single artwork with your name</li>
                  <li>Screenshots of your music on streaming platforms</li>
                </ul>
              </div>

              {uploadedFiles.professional.length > 0 && (
                <div className="space-y-2">
                  <Label>Uploaded Documents</Label>
                  <div className="rounded-md border">
                    {uploadedFiles.professional.map((file, index) => (
                      <div
                        key={index}
                        className="flex items-center justify-between border-b p-3 last:border-0"
                      >
                        <div className="flex items-center gap-3">
                          {file.type.includes("image") ? (
                            <ImageIcon className="h-5 w-5 text-muted-foreground" />
                          ) : (
                            <FileText className="h-5 w-5 text-muted-foreground" />
                          )}
                          <div>
                            <p className="text-sm font-medium">{file.name}</p>
                            <p className="text-xs text-muted-foreground">
                              {file.size}
                            </p>
                          </div>
                        </div>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => removeFile("professional", index)}
                        >
                          <X className="h-4 w-4" />
                        </Button>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </CardContent>
            <CardFooter className="flex justify-between">
              <Button
                variant="outline"
                onClick={() => setActiveTab("identity")}
              >
                Back to Identity Verification
              </Button>
              <Button
                onClick={() => setActiveTab("social")}
                className="bg-purple-600 hover:bg-purple-700"
                disabled={uploadedFiles.professional.length === 0}
              >
                Continue to Social Media Verification
              </Button>
            </CardFooter>
          </Card>
        </TabsContent>

        {/* Social Media Verification Tab */}
        <TabsContent value="social">
          <Card>
            <CardHeader>
              <CardTitle>Social Media Verification</CardTitle>
              <CardDescription>
                Link your official social media accounts
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <Alert>
                <Info className="h-4 w-4" />
                <AlertTitle>Verification Process</AlertTitle>
                <AlertDescription>
                  To verify ownership of your social media accounts, we'll ask
                  you to post a unique verification code or add it to your bio
                  temporarily. This helps us confirm you control these accounts.
                </AlertDescription>
              </Alert>

              <div className="space-y-4">
                <div className="space-y-2">
                  <Label
                    htmlFor="spotifyLink"
                    className="flex items-center gap-2"
                  >
                    <svg
                      className="h-4 w-4 text-green-600"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z" />
                    </svg>
                    Spotify Artist Link
                  </Label>
                  <Input
                    id="spotifyLink"
                    name="spotifyLink"
                    value={formData.spotifyLink}
                    onChange={handleChange}
                    placeholder="https://open.spotify.com/artist/..."
                  />
                </div>

                <div className="space-y-2">
                  <Label
                    htmlFor="appleMusicLink"
                    className="flex items-center gap-2"
                  >
                    <svg
                      className="h-4 w-4 text-red-600"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M23.997 6.124c0-.738-.065-1.47-.24-2.19-.317-1.31-1.062-2.31-2.18-3.043C21.003.517 20.373.285 19.7.164c-.517-.093-1.038-.135-1.564-.15-.04-.003-.083-.01-.124-.013H5.988c-.152.01-.303.017-.455.026C4.786.07 4.043.15 3.34.428 2.004.958 1.04 1.88.448 3.208c-.207.458-.332.939-.384 1.442-.058.565-.07 1.13-.07 1.696v11.308c.005.563.012 1.12.06 1.678.038.51.154 1 .34 1.472.594 1.345 1.582 2.28 2.975 2.804.565.213 1.156.32 1.762.36.667.05 1.337.042 2.005.042h9.93c.296 0 .593-.01.89-.022.55-.02 1.1-.08 1.624-.24 1.613-.5 2.702-1.5 3.264-3.096.16-.453.25-.932.28-1.42.08-1.214.07-2.43.07-3.645V9.77c0-.32.013-.64.013-.96 0-.8-.013-1.6-.146-2.395-.066-.39-.163-.78-.316-1.148-.437-1.058-1.175-1.858-2.22-2.422-.38-.207-.79-.342-1.208-.442-.292-.07-.58-.117-.885-.142-.136-.012-.27-.02-.405-.032-.426-.026-.85-.026-1.275-.026H17.66z" />
                      <path
                        d="M17.55 12.488c-.02-2.05 1.666-3.078 1.743-3.12-.95-1.383-2.424-1.573-2.944-1.594-1.24-.126-2.45.732-3.083.732-.647 0-1.63-.723-2.688-.702-1.368.02-2.65.802-3.355 2.023-1.45 2.52-.37 6.226 1.022 8.27.692.992 1.51 2.106 2.577 2.066 1.04-.042 1.425-.662 2.68-.662 1.24 0 1.604.662 2.68.64 1.11-.02 1.81-.992 2.48-1.994.79-1.133 1.11-2.246 1.125-2.302-.025-.01-2.148-.82-2.168-3.27zm-2.038-6.008c.56-.692 .95-1.646.84-2.61-.815.042-1.828.553-2.413 1.234-.52.604-.99 1.594-.87 2.53.905.07 1.833-.45 2.443-1.154z"
                        fill="white"
                      />
                    </svg>
                    Apple Music Link
                  </Label>
                  <Input
                    id="appleMusicLink"
                    name="appleMusicLink"
                    value={formData.appleMusicLink}
                    onChange={handleChange}
                    placeholder="https://music.apple.com/artist/..."
                  />
                </div>

                <div className="space-y-2">
                  <Label
                    htmlFor="instagramLink"
                    className="flex items-center gap-2"
                  >
                    <svg
                      className="h-4 w-4 text-pink-600"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.072 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.073-1.689-.073-4.948 0-3.259.013-3.667.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z" />
                    </svg>
                    Instagram
                  </Label>
                  <Input
                    id="instagramLink"
                    name="instagramLink"
                    value={formData.instagramLink}
                    onChange={handleChange}
                    placeholder="https://instagram.com/..."
                  />
                </div>

                <div className="space-y-2">
                  <Label
                    htmlFor="twitterLink"
                    className="flex items-center gap-2"
                  >
                    <svg
                      className="h-4 w-4 text-blue-400"
                      viewBox="0 0 24 24"
                      fill="currentColor"
                    >
                      <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z" />
                    </svg>
                    Twitter
                  </Label>
                  <Input
                    id="twitterLink"
                    name="twitterLink"
                    value={formData.twitterLink}
                    onChange={handleChange}
                    placeholder="https://twitter.com/..."
                  />
                </div>

                <div className="space-y-2">
                  <Label
                    htmlFor="websiteLink"
                    className="flex items-center gap-2"
                  >
                    <Globe className="h-4 w-4" />
                    Official Website
                  </Label>
                  <Input
                    id="websiteLink"
                    name="websiteLink"
                    value={formData.websiteLink}
                    onChange={handleChange}
                    placeholder="https://..."
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label>Upload Social Media Verification</Label>
                <FileUploader
                  onFilesAdded={(files) => handleFileUpload("social", files)}
                  acceptedFileTypes={[
                    "image/jpeg",
                    "image/png",
                    "application/pdf",
                  ]}
                  maxFileSizeMB={5}
                  maxFiles={5}
                />
                <p className="text-xs text-muted-foreground">
                  Upload screenshots showing you have control of these accounts.
                  For example:
                </p>
                <ul className="ml-5 list-disc text-xs text-muted-foreground">
                  <li>Screenshots of you logged into these accounts</li>
                  <li>Screenshots showing you can post content</li>
                  <li>Screenshots of account settings pages</li>
                </ul>
              </div>

              {uploadedFiles.social.length > 0 && (
                <div className="space-y-2">
                  <Label>Uploaded Screenshots</Label>
                  <div className="rounded-md border">
                    {uploadedFiles.social.map((file, index) => (
                      <div
                        key={index}
                        className="flex items-center justify-between border-b p-3 last:border-0"
                      >
                        <div className="flex items-center gap-3">
                          {file.type.includes("image") ? (
                            <ImageIcon className="h-5 w-5 text-muted-foreground" />
                          ) : (
                            <FileText className="h-5 w-5 text-muted-foreground" />
                          )}
                          <div>
                            <p className="text-sm font-medium">{file.name}</p>
                            <p className="text-xs text-muted-foreground">
                              {file.size}
                            </p>
                          </div>
                        </div>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => removeFile("social", index)}
                        >
                          <X className="h-4 w-4" />
                        </Button>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              <div className="space-y-2">
                <Label htmlFor="additionalInfo">
                  Additional Information (Optional)
                </Label>
                <Textarea
                  id="additionalInfo"
                  name="additionalInfo"
                  value={formData.additionalInfo}
                  onChange={handleChange}
                  placeholder="Any additional information you'd like to provide to help with verification..."
                  className="min-h-[100px]"
                />
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
                    I confirm all information is accurate
                  </Label>
                  <p className="text-xs text-muted-foreground">
                    By checking this box, I confirm that all information and
                    documents provided are accurate and authentic. I understand
                    that providing false information may result in permanent
                    account suspension.
                  </p>
                </div>
              </div>
            </CardContent>
            <CardFooter className="flex justify-between">
              <Button
                variant="outline"
                onClick={() => setActiveTab("professional")}
              >
                Back to Professional Verification
              </Button>
              <Button
                onClick={() => setActiveTab("overview")}
                className="bg-purple-600 hover:bg-purple-700"
                disabled={uploadedFiles.social.length === 0}
              >
                Review & Submit
              </Button>
            </CardFooter>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
