"use client";

import { useState } from "react";
import { Check, Copy, Mail, Plus, Search, Trash, UserPlus } from "lucide-react";
import { useToast } from "@/hooks/use-toast";

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
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Switch } from "@/components/ui/switch";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";

// Sample users for search results
const sampleUsers = [
  {
    id: "user3",
    name: "Emily Wilson",
    email: "emily@example.com",
    avatarUrl: "/placeholder.svg?height=40&width=40&text=EW",
  },
  {
    id: "user4",
    name: "Michael Brown",
    email: "michael@example.com",
    avatarUrl: "/placeholder.svg?height=40&width=40&text=MB",
  },
  {
    id: "user5",
    name: "Jessica Taylor",
    email: "jessica@example.com",
    avatarUrl: "/placeholder.svg?height=40&width=40&text=JT",
  },
];

export function CollaboratorsDialog({
  open,
  onOpenChange,
  playlist,
  onCollaboratorsUpdate,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  playlist: any;
  onCollaboratorsUpdate: (collaborators: any[]) => void;
}) {
  const { toast } = useToast();
  const [collaborators, setCollaborators] = useState(
    playlist.collaborators || []
  );
  const [isCollaborative, setIsCollaborative] = useState(
    playlist.isCollaborative
  );
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<typeof sampleUsers>([]);
  const [inviteEmail, setInviteEmail] = useState("");
  const [inviteRole, setInviteRole] = useState("editor");
  const [shareLink, setShareLink] = useState(
    `https://musicwave.example/invite/${playlist.id}/${generateInviteCode()}`
  );
  const [linkCopied, setLinkCopied] = useState(false);

  // Handle search input
  const handleSearch = (query: string) => {
    setSearchQuery(query);
    if (query.trim() === "") {
      setSearchResults([]);
      return;
    }

    // Filter users based on search query
    const filteredUsers = sampleUsers.filter(
      (user) =>
        user.name.toLowerCase().includes(query.toLowerCase()) ||
        user.email.toLowerCase().includes(query.toLowerCase())
    );

    // Remove users that are already collaborators
    const availableUsers = filteredUsers.filter(
      (user) =>
        !collaborators.some((collaborator: any) => collaborator.id === user.id)
    );

    setSearchResults(availableUsers);
  };

  // Add collaborator
  const addCollaborator = (user: any, role = "editor") => {
    const newCollaborator = {
      ...user,
      role,
    };
    setCollaborators([...collaborators, newCollaborator]);
    setSearchQuery("");
    setSearchResults([]);
    setIsCollaborative(true);
  };

  // Remove collaborator
  const removeCollaborator = (userId: string) => {
    setCollaborators(collaborators.filter((c: any) => c.id !== userId));
  };

  // Update collaborator role
  const updateCollaboratorRole = (userId: string, role: string) => {
    setCollaborators(
      collaborators.map((c: any) => (c.id === userId ? { ...c, role } : c))
    );
  };

  // Send email invitation
  const sendEmailInvitation = () => {
    if (!inviteEmail || !inviteEmail.includes("@")) {
      toast({
        title: "Invalid email",
        description: "Please enter a valid email address.",
        variant: "destructive",
      });
      return;
    }

    // In a real app, you would send an API request to send the invitation
    toast({
      title: "Invitation sent",
      description: `An invitation has been sent to ${inviteEmail}`,
    });

    setInviteEmail("");
    setIsCollaborative(true);
  };

  // Copy share link
  const copyShareLink = () => {
    navigator.clipboard.writeText(shareLink);
    setLinkCopied(true);
    toast({
      title: "Link copied",
      description: "Collaboration link copied to clipboard",
    });

    setTimeout(() => {
      setLinkCopied(false);
    }, 2000);
  };

  // Generate new share link
  const generateNewShareLink = () => {
    setShareLink(
      `https://musicwave.example/invite/${playlist.id}/${generateInviteCode()}`
    );
    toast({
      title: "New link generated",
      description: "A new collaboration link has been generated",
    });
  };

  // Save changes
  const saveChanges = () => {
    onCollaboratorsUpdate(isCollaborative ? collaborators : []);
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[600px]">
        <DialogHeader>
          <DialogTitle>Manage Collaborators</DialogTitle>
          <DialogDescription>
            Invite others to collaborate on "{playlist.title}". Collaborators
            can add and remove tracks.
          </DialogDescription>
        </DialogHeader>

        <div className="flex items-center space-x-2 py-4">
          <Switch
            id="collaborative-mode"
            checked={isCollaborative}
            onCheckedChange={setIsCollaborative}
          />
          <Label htmlFor="collaborative-mode">Enable collaborative mode</Label>
        </div>

        {isCollaborative && (
          <Tabs defaultValue="collaborators" className="w-full">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="collaborators">Collaborators</TabsTrigger>
              <TabsTrigger value="invite">Invite by Email</TabsTrigger>
              <TabsTrigger value="link">Share Link</TabsTrigger>
            </TabsList>

            {/* Current Collaborators Tab */}
            <TabsContent value="collaborators" className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="search-users">Search users</Label>
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="search-users"
                    placeholder="Search by name or email"
                    className="pl-10"
                    value={searchQuery}
                    onChange={(e) => handleSearch(e.target.value)}
                  />
                </div>

                {/* Search Results */}
                {searchResults.length > 0 && (
                  <ScrollArea className="h-[120px] border rounded-md">
                    <div className="p-2 space-y-2">
                      {searchResults.map((user) => (
                        <div
                          key={user.id}
                          className="flex items-center justify-between p-2 rounded-md hover:bg-accent"
                        >
                          <div className="flex items-center gap-3">
                            <Avatar>
                              <AvatarImage
                                src={user.avatarUrl || "/placeholder.svg"}
                                alt={user.name}
                              />
                              <AvatarFallback>
                                {user.name
                                  .split(" ")
                                  .map((n) => n[0])
                                  .join("")}
                              </AvatarFallback>
                            </Avatar>
                            <div>
                              <div className="font-medium">{user.name}</div>
                              <div className="text-sm text-muted-foreground">
                                {user.email}
                              </div>
                            </div>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => addCollaborator(user)}
                            className="gap-1"
                          >
                            <Plus className="h-4 w-4" />
                            Add
                          </Button>
                        </div>
                      ))}
                    </div>
                  </ScrollArea>
                )}

                {/* Current Collaborators */}
                <div className="mt-6">
                  <h3 className="text-sm font-medium mb-2">
                    Current collaborators
                  </h3>
                  <ScrollArea className="h-[200px] border rounded-md">
                    <div className="p-2 space-y-2">
                      {/* Owner */}
                      <div className="flex items-center justify-between p-2 rounded-md bg-muted/50">
                        <div className="flex items-center gap-3">
                          <Avatar>
                            <AvatarImage
                              src="/placeholder.svg?height=40&width=40&text=YN"
                              alt="Your Name"
                            />
                            <AvatarFallback>YN</AvatarFallback>
                          </Avatar>
                          <div>
                            <div className="font-medium">Your Name (You)</div>
                            <div className="text-sm text-muted-foreground">
                              your.email@example.com
                            </div>
                          </div>
                        </div>
                        <Badge>Owner</Badge>
                      </div>

                      {/* Collaborators */}
                      {collaborators.map((collaborator: any) => (
                        <div
                          key={collaborator.id}
                          className="flex items-center justify-between p-2 rounded-md hover:bg-accent"
                        >
                          <div className="flex items-center gap-3">
                            <Avatar>
                              <AvatarImage
                                src={
                                  collaborator.avatarUrl || "/placeholder.svg"
                                }
                                alt={collaborator.name}
                              />
                              <AvatarFallback>
                                {collaborator.name
                                  .split(" ")
                                  .map((n: string) => n[0])
                                  .join("")}
                              </AvatarFallback>
                            </Avatar>
                            <div>
                              <div className="font-medium">
                                {collaborator.name}
                              </div>
                              <div className="text-sm text-muted-foreground">
                                {collaborator.email}
                              </div>
                            </div>
                          </div>
                          <div className="flex items-center gap-2">
                            <Select
                              defaultValue={collaborator.role}
                              onValueChange={(value) =>
                                updateCollaboratorRole(collaborator.id, value)
                              }
                            >
                              <SelectTrigger className="w-[110px] h-8">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="editor">Can edit</SelectItem>
                                <SelectItem value="viewer">Can view</SelectItem>
                              </SelectContent>
                            </Select>
                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() =>
                                removeCollaborator(collaborator.id)
                              }
                              className="text-destructive"
                            >
                              <Trash className="h-4 w-4" />
                              <span className="sr-only">Remove</span>
                            </Button>
                          </div>
                        </div>
                      ))}

                      {collaborators.length === 0 && (
                        <div className="flex flex-col items-center justify-center py-8 text-center text-muted-foreground">
                          <UserPlus className="h-8 w-8 mb-2" />
                          <p>No collaborators yet</p>
                          <p className="text-sm">
                            Invite people to collaborate on this playlist
                          </p>
                        </div>
                      )}
                    </div>
                  </ScrollArea>
                </div>
              </div>
            </TabsContent>

            {/* Invite by Email Tab */}
            <TabsContent value="invite" className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="invite-email">Email address</Label>
                <div className="relative">
                  <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="invite-email"
                    type="email"
                    placeholder="Enter email address"
                    className="pl-10"
                    value={inviteEmail}
                    onChange={(e) => setInviteEmail(e.target.value)}
                  />
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="invite-role">Permission</Label>
                <Select defaultValue={inviteRole} onValueChange={setInviteRole}>
                  <SelectTrigger id="invite-role">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="editor">Can edit</SelectItem>
                    <SelectItem value="viewer">Can view</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <Button onClick={sendEmailInvitation} className="w-full gap-2">
                <Mail className="h-4 w-4" />
                Send Invitation
              </Button>

              <div className="text-sm text-muted-foreground text-center mt-4">
                <p>
                  An email will be sent with instructions on how to join this
                  playlist.
                </p>
              </div>
            </TabsContent>

            {/* Share Link Tab */}
            <TabsContent value="link" className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="share-link">Collaboration link</Label>
                <div className="flex gap-2">
                  <div className="relative flex-1">
                    <Input
                      id="share-link"
                      value={shareLink}
                      readOnly
                      className="pr-10"
                      onClick={(e) => (e.target as HTMLInputElement).select()}
                    />
                    <Button
                      variant="ghost"
                      size="icon"
                      className="absolute right-0 top-0 h-full"
                      onClick={copyShareLink}
                    >
                      {linkCopied ? (
                        <Check className="h-4 w-4 text-green-500" />
                      ) : (
                        <Copy className="h-4 w-4" />
                      )}
                      <span className="sr-only">Copy</span>
                    </Button>
                  </div>
                  <Button variant="outline" onClick={generateNewShareLink}>
                    Reset
                  </Button>
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="link-permission">Permission</Label>
                <Select defaultValue="editor">
                  <SelectTrigger id="link-permission">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="editor">Can edit</SelectItem>
                    <SelectItem value="viewer">Can view</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="text-sm text-muted-foreground space-y-2 mt-4 p-4 border rounded-md bg-muted/50">
                <p className="font-medium">
                  Anyone with the link can join this playlist
                </p>
                <p>
                  Share this link with people you trust. They'll be able to join
                  the playlist without requiring approval.
                </p>
                <p>
                  You can reset the link at any time to revoke access from
                  previous links.
                </p>
              </div>
            </TabsContent>
          </Tabs>
        )}

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            Cancel
          </Button>
          <Button onClick={saveChanges}>Save Changes</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// Helper function to generate a random invite code
function generateInviteCode() {
  return Math.random().toString(36).substring(2, 10);
}
