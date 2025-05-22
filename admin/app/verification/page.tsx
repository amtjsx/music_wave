"use client";

import {
    CheckCircle,
    ChevronDown,
    Clock,
    Download,
    Eye,
    FileText,
    Filter,
    ImageIcon,
    Search,
    Shield,
    XCircle,
} from "lucide-react";
import { useState } from "react";

import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from "@/components/ui/dialog";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Separator } from "@/components/ui/separator";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";

// Mock verification requests data
const verificationRequests = [
  {
    id: "VRF123456",
    artistName: "Jane Doe",
    email: "jane@example.com",
    submittedAt: "2025-05-15T10:30:00Z",
    status: "pending_review",
    country: "United States",
    idType: "Passport",
  },
  {
    id: "VRF234567",
    artistName: "John Smith",
    email: "john@example.com",
    submittedAt: "2025-05-14T09:15:00Z",
    status: "pending_review",
    country: "United Kingdom",
    idType: "Driver's License",
  },
  {
    id: "VRF345678",
    artistName: "Alex Johnson",
    email: "alex@example.com",
    submittedAt: "2025-05-13T14:45:00Z",
    status: "verified",
    country: "Canada",
    idType: "National ID",
  },
  {
    id: "VRF456789",
    artistName: "Maria Garcia",
    email: "maria@example.com",
    submittedAt: "2025-05-12T11:20:00Z",
    status: "rejected",
    country: "Spain",
    idType: "Passport",
  },
  {
    id: "VRF567890",
    artistName: "David Kim",
    email: "david@example.com",
    submittedAt: "2025-05-11T16:05:00Z",
    status: "verified",
    country: "South Korea",
    idType: "National ID",
  },
];

export default function AdminVerificationPage() {
  const [activeTab, setActiveTab] = useState("pending");
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedRequest, setSelectedRequest] = useState<
    (typeof verificationRequests)[0] | null
  >(null);
  const [viewDialogOpen, setViewDialogOpen] = useState(false);
  const [decisionDialogOpen, setDecisionDialogOpen] = useState(false);
  const [decisionType, setDecisionType] = useState<"approve" | "reject" | null>(
    null
  );
  const [rejectionReason, setRejectionReason] = useState("");

  const filteredRequests = verificationRequests.filter((request) => {
    // Filter by tab
    if (activeTab === "pending" && request.status !== "pending_review")
      return false;
    if (activeTab === "verified" && request.status !== "verified") return false;
    if (activeTab === "rejected" && request.status !== "rejected") return false;

    // Filter by search query
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      return (
        request.id.toLowerCase().includes(query) ||
        request.artistName.toLowerCase().includes(query) ||
        request.email.toLowerCase().includes(query)
      );
    }

    return true;
  });

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    }).format(date);
  };

  const handleViewRequest = (request: (typeof verificationRequests)[0]) => {
    setSelectedRequest(request);
    setViewDialogOpen(true);
  };

  const handleDecision = (
    request: (typeof verificationRequests)[0],
    type: "approve" | "reject"
  ) => {
    setSelectedRequest(request);
    setDecisionType(type);
    setDecisionDialogOpen(true);
  };

  const submitDecision = () => {
    // In a real implementation, this would call an API to update the verification status
    console.log("Decision submitted:", {
      requestId: selectedRequest?.id,
      decision: decisionType,
      rejectionReason: decisionType === "reject" ? rejectionReason : undefined,
    });

    setDecisionDialogOpen(false);
    // In a real implementation, we would refresh the data
    // For demo purposes, we'll just close the dialog
  };

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Artist Verification Management
          </h1>
          <p className="text-muted-foreground">
            Review and manage artist verification requests
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Badge className="gap-1 bg-purple-600">
            <Shield className="h-3 w-3" /> Admin
          </Badge>
        </div>
      </div>

      <div className="flex items-center justify-between">
        <div className="relative w-64">
          <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
          <Input
            type="search"
            placeholder="Search requests..."
            className="pl-8"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="outline" className="gap-2">
              <Filter className="h-4 w-4" /> Filter
              <ChevronDown className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem>All Countries</DropdownMenuItem>
            <DropdownMenuItem>United States</DropdownMenuItem>
            <DropdownMenuItem>Europe</DropdownMenuItem>
            <DropdownMenuItem>Asia</DropdownMenuItem>
            <DropdownMenuItem>Other Regions</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-3">
          <TabsTrigger value="pending" className="gap-2">
            <Clock className="h-4 w-4" /> Pending
            <Badge
              variant="outline"
              className="ml-1 bg-orange-100 text-orange-600 dark:bg-orange-900 dark:text-orange-300"
            >
              {
                verificationRequests.filter(
                  (r) => r.status === "pending_review"
                ).length
              }
            </Badge>
          </TabsTrigger>
          <TabsTrigger value="verified" className="gap-2">
            <CheckCircle className="h-4 w-4" /> Verified
            <Badge
              variant="outline"
              className="ml-1 bg-green-100 text-green-600 dark:bg-green-900 dark:text-green-300"
            >
              {
                verificationRequests.filter((r) => r.status === "verified")
                  .length
              }
            </Badge>
          </TabsTrigger>
          <TabsTrigger value="rejected" className="gap-2">
            <XCircle className="h-4 w-4" /> Rejected
            <Badge
              variant="outline"
              className="ml-1 bg-red-100 text-red-600 dark:bg-red-900 dark:text-red-300"
            >
              {
                verificationRequests.filter((r) => r.status === "rejected")
                  .length
              }
            </Badge>
          </TabsTrigger>
        </TabsList>

        <TabsContent value={activeTab} className="mt-4">
          <Card>
            <CardHeader>
              <CardTitle>
                {activeTab === "pending" && "Pending Verification Requests"}
                {activeTab === "verified" && "Verified Artists"}
                {activeTab === "rejected" && "Rejected Verification Requests"}
              </CardTitle>
              <CardDescription>
                {activeTab === "pending" &&
                  "Review and approve or reject artist verification requests"}
                {activeTab === "verified" &&
                  "Artists who have been successfully verified"}
                {activeTab === "rejected" &&
                  "Artists whose verification requests were rejected"}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Request ID</TableHead>
                    <TableHead>Artist</TableHead>
                    <TableHead>Submitted</TableHead>
                    <TableHead>Country</TableHead>
                    <TableHead>ID Type</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredRequests.length > 0 ? (
                    filteredRequests.map((request) => (
                      <TableRow key={request.id}>
                        <TableCell className="font-medium">
                          {request.id}
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <Avatar className="h-8 w-8">
                              <AvatarFallback>
                                {request.artistName.charAt(0)}
                              </AvatarFallback>
                            </Avatar>
                            <div>
                              <div className="font-medium">
                                {request.artistName}
                              </div>
                              <div className="text-xs text-muted-foreground">
                                {request.email}
                              </div>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell>{formatDate(request.submittedAt)}</TableCell>
                        <TableCell>{request.country}</TableCell>
                        <TableCell>{request.idType}</TableCell>
                        <TableCell>
                          {request.status === "pending_review" && (
                            <Badge
                              variant="outline"
                              className="gap-1 text-orange-500 border-orange-200 bg-orange-100 dark:border-orange-800 dark:bg-orange-950"
                            >
                              <Clock className="h-3 w-3" /> Pending
                            </Badge>
                          )}
                          {request.status === "verified" && (
                            <Badge className="gap-1 bg-green-600">
                              <CheckCircle className="h-3 w-3" /> Verified
                            </Badge>
                          )}
                          {request.status === "rejected" && (
                            <Badge variant="destructive" className="gap-1">
                              <XCircle className="h-3 w-3" /> Rejected
                            </Badge>
                          )}
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex justify-end gap-2">
                            <Button
                              variant="outline"
                              size="sm"
                              className="h-8 gap-1"
                              onClick={() => handleViewRequest(request)}
                            >
                              <Eye className="h-3.5 w-3.5" />
                              View
                            </Button>

                            {request.status === "pending_review" && (
                              <>
                                <Button
                                  variant="outline"
                                  size="sm"
                                  className="h-8 gap-1 border-green-200 bg-green-100 text-green-600 hover:bg-green-200 dark:border-green-800 dark:bg-green-900 dark:text-green-300 dark:hover:bg-green-800"
                                  onClick={() =>
                                    handleDecision(request, "approve")
                                  }
                                >
                                  <CheckCircle className="h-3.5 w-3.5" />
                                  Approve
                                </Button>
                                <Button
                                  variant="outline"
                                  size="sm"
                                  className="h-8 gap-1 border-red-200 bg-red-100 text-red-600 hover:bg-red-200 dark:border-red-800 dark:bg-red-900 dark:text-red-300 dark:hover:bg-red-800"
                                  onClick={() =>
                                    handleDecision(request, "reject")
                                  }
                                >
                                  <XCircle className="h-3.5 w-3.5" />
                                  Reject
                                </Button>
                              </>
                            )}
                          </div>
                        </TableCell>
                      </TableRow>
                    ))
                  ) : (
                    <TableRow>
                      <TableCell colSpan={7} className="h-24 text-center">
                        No verification requests found.
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* View Request Dialog */}
      <Dialog open={viewDialogOpen} onOpenChange={setViewDialogOpen}>
        <DialogContent className="max-h-[90vh] max-w-3xl overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Verification Request Details</DialogTitle>
            <DialogDescription>
              Request ID: {selectedRequest?.id} • Submitted:{" "}
              {selectedRequest ? formatDate(selectedRequest.submittedAt) : ""}
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-6">
            {/* Artist Information */}
            <div>
              <h3 className="mb-2 text-sm font-medium">Artist Information</h3>
              <div className="rounded-md border p-4">
                <div className="flex items-center gap-4">
                  <Avatar className="h-16 w-16">
                    <AvatarFallback>
                      {selectedRequest?.artistName.charAt(0)}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <h4 className="text-lg font-medium">
                      {selectedRequest?.artistName}
                    </h4>
                    <p className="text-sm text-muted-foreground">
                      {selectedRequest?.email}
                    </p>
                    <div className="mt-1 flex items-center gap-2">
                      <Badge variant="outline">
                        {selectedRequest?.country}
                      </Badge>
                      <Badge variant="outline">{selectedRequest?.idType}</Badge>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Identity Documents */}
            <div>
              <h3 className="mb-2 text-sm font-medium">Identity Documents</h3>
              <div className="grid gap-4 md:grid-cols-2">
                <div className="rounded-md border p-4">
                  <div className="flex items-center gap-3">
                    <FileText className="h-5 w-5 text-muted-foreground" />
                    <div>
                      <p className="text-sm font-medium">passport_scan.jpg</p>
                      <p className="text-xs text-muted-foreground">
                        2.4 MB • Uploaded May 15, 2025
                      </p>
                    </div>
                  </div>
                  <div className="mt-3 flex justify-end gap-2">
                    <Button variant="outline" size="sm" className="h-8 gap-1">
                      <Eye className="h-3.5 w-3.5" /> View
                    </Button>
                    <Button variant="outline" size="sm" className="h-8 gap-1">
                      <Download className="h-3.5 w-3.5" /> Download
                    </Button>
                  </div>
                </div>
                <div className="rounded-md border p-4">
                  <div className="flex items-center gap-3">
                    <ImageIcon className="h-5 w-5 text-muted-foreground" />
                    <div>
                      <p className="text-sm font-medium">id_verification.jpg</p>
                      <p className="text-xs text-muted-foreground">
                        1.8 MB • Uploaded May 15, 2025
                      </p>
                    </div>
                  </div>
                  <div className="mt-3 flex justify-end gap-2">
                    <Button variant="outline" size="sm" className="h-8 gap-1">
                      <Eye className="h-3.5 w-3.5" /> View
                    </Button>
                    <Button variant="outline" size="sm" className="h-8 gap-1">
                      <Download className="h-3.5 w-3.5" /> Download
                    </Button>
                  </div>
                </div>
              </div>
            </div>

            {/* Professional Evidence */}
            <div>
              <h3 className="mb-2 text-sm font-medium">
                Professional Evidence
              </h3>
              <div className="rounded-md border p-4">
                <p className="text-sm">
                  I've been producing music for over 5 years and have released 3
                  albums and multiple singles. My music is available on all
                  major streaming platforms including Spotify, Apple Music, and
                  Amazon Music. I've performed at several local venues and
                  festivals.
                </p>
                <Separator className="my-3" />
                <div className="grid gap-3 md:grid-cols-2">
                  <div className="flex items-center gap-3">
                    <FileText className="h-5 w-5 text-muted-foreground" />
                    <div>
                      <p className="text-sm font-medium">
                        distribution_agreement.pdf
                      </p>
                      <p className="text-xs text-muted-foreground">1.2 MB</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <ImageIcon className="h-5 w-5 text-muted-foreground" />
                    <div>
                      <p className="text-sm font-medium">album_artwork.jpg</p>
                      <p className="text-xs text-muted-foreground">3.5 MB</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Social Media Links */}
            <div>
              <h3 className="mb-2 text-sm font-medium">
                Social Media & Platforms
              </h3>
              <div className="grid gap-3 md:grid-cols-2">
                <div className="flex items-center gap-3 rounded-md border p-3">
                  <svg
                    className="h-5 w-5 text-green-600"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                  >
                    <path d="M12 0C5.4 0 0 5.4 0 12s5.4 12 12 12 12-5.4 12-12S18.66 0 12 0zm5.521 17.34c-.24.359-.66.48-1.021.24-2.82-1.74-6.36-2.101-10.561-1.141-.418.122-.779-.179-.899-.539-.12-.421.18-.78.54-.9 4.56-1.021 8.52-.6 11.64 1.32.42.18.479.659.301 1.02zm1.44-3.3c-.301.42-.841.6-1.262.3-3.239-1.98-8.159-2.58-11.939-1.38-.479.12-1.02-.12-1.14-.6-.12-.48.12-1.021.6-1.141C9.6 9.9 15 10.561 18.72 12.84c.361.181.54.78.241 1.2zm.12-3.36C15.24 8.4 8.82 8.16 5.16 9.301c-.6.179-1.2-.181-1.38-.721-.18-.601.18-1.2.72-1.381 4.26-1.26 11.28-1.02 15.721 1.621.539.3.719 1.02.419 1.56-.299.421-1.02.599-1.559.3z" />
                  </svg>
                  <div>
                    <p className="text-sm font-medium">Spotify</p>
                    <a
                      href="#"
                      className="text-xs text-purple-600 hover:underline"
                    >
                      https://open.spotify.com/artist/example
                    </a>
                  </div>
                </div>
                <div className="flex items-center gap-3 rounded-md border p-3">
                  <svg
                    className="h-5 w-5 text-pink-600"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                  >
                    <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zM12 0C8.741 0 8.333.014 7.053.072 2.695.272.273 2.69.073 7.052.014 8.333 0 8.741 0 12c0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98C8.333 23.986 8.741 24 12 24c3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98C15.668.014 15.259 0 12 0zm0 5.838a6.162 6.162 0 100 12.324 6.162 6.162 0 000-12.324zM12 16a4 4 0 110-8 4 4 0 010 8zm6.406-11.845a1.44 1.44 0 100 2.881 1.44 1.44 0 000-2.881z" />
                  </svg>
                  <div>
                    <p className="text-sm font-medium">Instagram</p>
                    <a
                      href="#"
                      className="text-xs text-purple-600 hover:underline"
                    >
                      https://instagram.com/example
                    </a>
                  </div>
                </div>
              </div>
            </div>

            {/* Admin Notes */}
            <div>
              <h3 className="mb-2 text-sm font-medium">Admin Notes</h3>
              <Textarea
                placeholder="Add notes about this verification request..."
                className="min-h-[100px]"
              />
            </div>
          </div>

          <DialogFooter className="flex justify-between">
            <div className="flex gap-2">
              <Button variant="outline">
                <Download className="mr-2 h-4 w-4" /> Download All Files
              </Button>
            </div>
            {selectedRequest?.status === "pending_review" && (
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  className="border-red-200 bg-red-100 text-red-600 hover:bg-red-200 dark:border-red-800 dark:bg-red-900 dark:text-red-300 dark:hover:bg-red-800"
                  onClick={() => {
                    setViewDialogOpen(false);
                    handleDecision(selectedRequest, "reject");
                  }}
                >
                  <XCircle className="mr-2 h-4 w-4" /> Reject
                </Button>
                <Button
                  className="bg-green-600 hover:bg-green-700"
                  onClick={() => {
                    setViewDialogOpen(false);
                    handleDecision(selectedRequest, "approve");
                  }}
                >
                  <CheckCircle className="mr-2 h-4 w-4" /> Approve
                </Button>
              </div>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Decision Dialog */}
      <Dialog open={decisionDialogOpen} onOpenChange={setDecisionDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {decisionType === "approve"
                ? "Approve Verification"
                : "Reject Verification"}
            </DialogTitle>
            <DialogDescription>
              {decisionType === "approve"
                ? "This will verify the artist and grant them a verified badge."
                : "Please provide a reason for rejecting this verification request."}
            </DialogDescription>
          </DialogHeader>

          <div className="py-4">
            {decisionType === "approve" ? (
              <div className="rounded-md bg-green-50 p-4 dark:bg-green-950/50">
                <div className="flex items-start gap-3">
                  <CheckCircle className="mt-0.5 h-5 w-5 text-green-600" />
                  <div>
                    <h4 className="text-sm font-medium text-green-800 dark:text-green-300">
                      Confirm Approval
                    </h4>
                    <p className="mt-1 text-sm text-green-700 dark:text-green-400">
                      You are about to verify{" "}
                      <strong>{selectedRequest?.artistName}</strong>. This will:
                    </p>
                    <ul className="mt-2 list-disc space-y-1 pl-5 text-sm text-green-700 dark:text-green-400">
                      <li>Grant them a verified badge on their profile</li>
                      <li>Give them access to verified artist features</li>
                      <li>Send them an email notification</li>
                    </ul>
                  </div>
                </div>
              </div>
            ) : (
              <div className="space-y-4">
                <div className="rounded-md bg-red-50 p-4 dark:bg-red-950/50">
                  <div className="flex items-start gap-3">
                    <XCircle className="mt-0.5 h-5 w-5 text-red-600" />
                    <div>
                      <h4 className="text-sm font-medium text-red-800 dark:text-red-300">
                        Confirm Rejection
                      </h4>
                      <p className="mt-1 text-sm text-red-700 dark:text-red-400">
                        You are about to reject{" "}
                        <strong>{selectedRequest?.artistName}</strong>'s
                        verification request.
                      </p>
                    </div>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="rejectionReason">Reason for Rejection</Label>
                  <Textarea
                    id="rejectionReason"
                    value={rejectionReason}
                    onChange={(e) => setRejectionReason(e.target.value)}
                    placeholder="Explain why this verification request is being rejected..."
                    className="min-h-[100px]"
                  />
                  <p className="text-xs text-muted-foreground">
                    This reason will be shared with the artist to help them
                    understand why their verification was rejected.
                  </p>
                </div>
              </div>
            )}
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setDecisionDialogOpen(false)}
            >
              Cancel
            </Button>
            <Button
              onClick={submitDecision}
              className={
                decisionType === "approve"
                  ? "bg-green-600 hover:bg-green-700"
                  : "bg-red-600 hover:bg-red-700"
              }
              disabled={decisionType === "reject" && !rejectionReason.trim()}
            >
              {decisionType === "approve"
                ? "Approve Verification"
                : "Reject Verification"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
