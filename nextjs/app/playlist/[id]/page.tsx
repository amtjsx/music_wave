"use client";

import {
  Clock,
  Download,
  GripVertical,
  Heart,
  MoreHorizontal,
  Music,
  Pencil,
  Play,
  Plus,
  Save,
  Share2,
  Users,
  X,
  History,
} from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  type DragEndEvent,
} from "@dnd-kit/core";
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from "@dnd-kit/sortable";
import { CSS } from "@dnd-kit/utilities";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useTranslation } from "@/hooks/use-translation";
import {
  getAlbumArtPlaceholder,
  getColoredPlaceholder,
} from "@/utils/image-utils";
import { cn } from "@/lib/utils";
import { CollaboratorsDialog } from "./collaborators-dialog";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ActivityFeed } from "./activity-feed";

// Sample playlists data
const samplePlaylists = [
  {
    id: "1",
    title: "My Favorites",
    description: "All my favorite songs in one playlist",
    creator: "Your Name",
    coverArt: getColoredPlaceholder(300, 300, "ec4899"),
    isPublic: true,
    followers: 12,
    trackCount: 42,
    totalDuration: "2h 45m",
    createdAt: "2023-05-15",
    isInLibrary: true,
    isCreatedByUser: true,
    isCollaborative: true,
    collaborators: [
      {
        id: "user1",
        name: "Alex Johnson",
        email: "alex@example.com",
        avatarUrl: getAlbumArtPlaceholder(40, 40, "AJ", "8b5cf6"),
        role: "editor", // editor, viewer
      },
      {
        id: "user2",
        name: "Sam Smith",
        email: "sam@example.com",
        avatarUrl: getAlbumArtPlaceholder(40, 40, "SS", "ec4899"),
        role: "editor",
      },
    ],
    tracks: [
      {
        id: "101",
        title: "Blinding Lights",
        artist: "The Weeknd",
        album: "After Hours",
        duration: "3:20",
        dateAdded: "2023-05-15",
        addedBy: "Your Name",
        coverArt: getAlbumArtPlaceholder(40, 40, "Blinding Lights", "8b5cf6"),
        isLiked: true,
      },
      {
        id: "102",
        title: "Shape of You",
        artist: "Ed Sheeran",
        album: "÷ (Divide)",
        duration: "3:53",
        dateAdded: "2023-05-15",
        addedBy: "Alex Johnson",
        coverArt: getAlbumArtPlaceholder(40, 40, "Shape of You", "ec4899"),
        isLiked: false,
      },
      {
        id: "103",
        title: "Dance Monkey",
        artist: "Tones and I",
        album: "The Kids Are Coming",
        duration: "3:29",
        dateAdded: "2023-05-16",
        addedBy: "Your Name",
        coverArt: getAlbumArtPlaceholder(40, 40, "Dance Monkey", "f97316"),
        isLiked: true,
      },
      {
        id: "104",
        title: "Someone You Loved",
        artist: "Lewis Capaldi",
        album: "Divinely Uninspired to a Hellish Extent",
        duration: "3:02",
        dateAdded: "2023-05-16",
        addedBy: "Sam Smith",
        coverArt: getAlbumArtPlaceholder(40, 40, "Someone You Loved", "22c55e"),
        isLiked: false,
      },
      {
        id: "105",
        title: "Watermelon Sugar",
        artist: "Harry Styles",
        album: "Fine Line",
        duration: "2:54",
        dateAdded: "2023-05-17",
        addedBy: "Alex Johnson",
        coverArt: getAlbumArtPlaceholder(40, 40, "Watermelon Sugar", "3b82f6"),
        isLiked: true,
      },
    ],
  },
  {
    id: "2",
    title: "Workout Mix",
    description: "High energy tracks for exercise",
    creator: "Your Name",
    coverArt: getColoredPlaceholder(300, 300, "8b5cf6"),
    isPublic: false,
    followers: 5,
    trackCount: 28,
    totalDuration: "1h 52m",
    createdAt: "2023-06-10",
    isInLibrary: true,
    isCreatedByUser: true,
    isCollaborative: false,
    collaborators: [],
    tracks: [
      {
        id: "201",
        title: "Eye of the Tiger",
        artist: "Survivor",
        album: "Eye of the Tiger",
        duration: "4:05",
        dateAdded: "2023-06-10",
        addedBy: "Your Name",
        coverArt: getAlbumArtPlaceholder(40, 40, "Eye of the Tiger", "f43f5e"),
        isLiked: true,
      },
      {
        id: "202",
        title: "Can't Hold Us",
        artist: "Macklemore & Ryan Lewis",
        album: "The Heist",
        duration: "4:18",
        dateAdded: "2023-06-10",
        addedBy: "Your Name",
        coverArt: getAlbumArtPlaceholder(40, 40, "Can't Hold Us", "06b6d4"),
        isLiked: false,
      },
      {
        id: "203",
        title: "Stronger",
        artist: "Kanye West",
        album: "Graduation",
        duration: "5:12",
        dateAdded: "2023-06-11",
        addedBy: "Your Name",
        coverArt: getAlbumArtPlaceholder(40, 40, "Stronger", "eab308"),
        isLiked: true,
      },
    ],
  },
  {
    id: "3",
    title: "Chill Vibes",
    description: "Relaxing music for downtime",
    creator: "SoundWave",
    coverArt: getColoredPlaceholder(300, 300, "3b82f6"),
    isPublic: true,
    followers: 1243,
    trackCount: 35,
    totalDuration: "2h 15m",
    createdAt: "2023-04-22",
    isInLibrary: true,
    isCreatedByUser: false,
    isCollaborative: false,
    collaborators: [],
    tracks: [
      {
        id: "301",
        title: "Circles",
        artist: "Post Malone",
        album: "Hollywood's Bleeding",
        duration: "3:35",
        dateAdded: "2023-04-22",
        addedBy: "SoundWave",
        coverArt: getAlbumArtPlaceholder(40, 40, "Circles", "8b5cf6"),
        isLiked: false,
      },
      {
        id: "302",
        title: "Sunflower",
        artist: "Post Malone, Swae Lee",
        album: "Spider-Man: Into the Spider-Verse",
        duration: "2:38",
        dateAdded: "2023-04-22",
        addedBy: "SoundWave",
        coverArt: getAlbumArtPlaceholder(40, 40, "Sunflower", "eab308"),
        isLiked: true,
      },
      {
        id: "303",
        title: "Memories",
        artist: "Maroon 5",
        album: "Memories",
        duration: "3:09",
        dateAdded: "2023-04-23",
        addedBy: "SoundWave",
        coverArt: getAlbumArtPlaceholder(40, 40, "Memories", "ec4899"),
        isLiked: false,
      },
    ],
  },
];

// Sortable track row component
function SortableTrackRow({
  track,
  index,
  toggleLike,
  isEditMode,
  showAddedBy = false,
}: {
  track: any;
  index: number;
  toggleLike: (id: string) => void;
  isEditMode: boolean;
  showAddedBy?: boolean;
}) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: track.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <TableRow
      ref={setNodeRef}
      style={style}
      className={cn(
        "group",
        isDragging ? "bg-accent opacity-80 relative z-10" : ""
      )}
    >
      <TableCell className="font-medium">
        {isEditMode ? (
          <div
            {...attributes}
            {...listeners}
            className="cursor-grab flex items-center justify-center"
          >
            <GripVertical className="h-5 w-5 text-muted-foreground" />
          </div>
        ) : (
          index + 1
        )}
      </TableCell>
      <TableCell>
        <div className="flex items-center space-x-3">
          <Image
            src={track.coverArt || "/placeholder.svg"}
            alt={`${track.title} album cover`}
            width={40}
            height={40}
            className="rounded-md"
          />
          <div>
            <div className="font-medium">{track.title}</div>
            <div className="text-sm text-muted-foreground">{track.artist}</div>
          </div>
        </div>
      </TableCell>
      <TableCell className="hidden md:table-cell">{track.album}</TableCell>
      {showAddedBy && (
        <TableCell className="hidden lg:table-cell text-muted-foreground">
          {track.addedBy}
        </TableCell>
      )}
      <TableCell className="hidden lg:table-cell text-muted-foreground">
        {track.dateAdded}
      </TableCell>
      <TableCell className="text-right text-muted-foreground">
        {track.duration}
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-2">
          <Button
            variant="ghost"
            size="icon"
            className="opacity-0 group-hover:opacity-100 transition-opacity"
            onClick={() => toggleLike(track.id)}
          >
            <Heart
              className={`h-4 w-4 ${
                track.isLiked ? "fill-primary text-primary" : ""
              }`}
            />
            <span className="sr-only">{track.isLiked ? "Unlike" : "Like"}</span>
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <MoreHorizontal className="h-4 w-4" />
            <span className="sr-only">More options</span>
          </Button>
        </div>
      </TableCell>
    </TableRow>
  );
}

export default function PlaylistPage() {
  const { t } = useTranslation("playlist");
  const params = useParams();
  const router = useRouter();
  const [playlist, setPlaylist] = useState<(typeof samplePlaylists)[0] | null>(
    null
  );
  const [isLoading, setIsLoading] = useState(true);
  const [isEditMode, setIsEditMode] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [isCollaboratorsDialogOpen, setIsCollaboratorsDialogOpen] =
    useState(false);
  const [activeTab, setActiveTab] = useState("tracks");

  // Set up drag-and-drop sensors
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  // Handle drag end event
  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      setPlaylist((currentPlaylist) => {
        if (!currentPlaylist) return null;

        const oldIndex = currentPlaylist.tracks.findIndex(
          (track) => track.id === active.id
        );
        const newIndex = currentPlaylist.tracks.findIndex(
          (track) => track.id === over.id
        );

        return {
          ...currentPlaylist,
          tracks: arrayMove(currentPlaylist.tracks, oldIndex, newIndex),
        };
      });
    }
  };

  // Fetch playlist data based on ID
  useEffect(() => {
    const playlistId = params.id as string;
    // Simulate API call
    setTimeout(() => {
      const foundPlaylist = samplePlaylists.find((p) => p.id === playlistId);
      setPlaylist(foundPlaylist || null);
      setIsLoading(false);
    }, 500);
  }, [params.id]);

  // Toggle like status for a track
  const toggleLike = (trackId: string) => {
    if (!playlist) return;

    setPlaylist({
      ...playlist,
      tracks: playlist.tracks.map((track) =>
        track.id === trackId ? { ...track, isLiked: !track.isLiked } : track
      ),
    });
  };

  // Toggle library status for the playlist
  const toggleLibrary = () => {
    if (!playlist) return;

    setPlaylist({
      ...playlist,
      isInLibrary: !playlist.isInLibrary,
    });
  };

  // Toggle edit mode
  const toggleEditMode = () => {
    setIsEditMode(!isEditMode);
  };

  // Save reordered playlist
  const savePlaylist = () => {
    if (!playlist) return;

    setIsSaving(true);

    // Simulate API call
    setTimeout(() => {
      setIsSaving(false);
      setIsEditMode(false);
      // In a real app, you would save the changes to the backend here
    }, 1000);
  };

  // Toggle collaborative status
  const toggleCollaborative = () => {
    if (!playlist) return;

    setPlaylist({
      ...playlist,
      isCollaborative: !playlist.isCollaborative,
      collaborators: playlist.isCollaborative ? [] : playlist.collaborators,
    });
  };

  // Handle collaborator updates
  const handleCollaboratorsUpdate = (collaborators: any[]) => {
    if (!playlist) return;

    setPlaylist({
      ...playlist,
      collaborators,
    });
  };

  if (isLoading) {
    return (
      <main className="flex-1 pb-20">
        <div className="container py-8">
          <div className="animate-pulse">
            <div className="flex flex-col md:flex-row gap-8">
              <div className="w-64 h-64 bg-muted rounded-lg"></div>
              <div className="flex flex-col justify-end gap-2">
                <div className="h-6 w-24 bg-muted rounded"></div>
                <div className="h-10 w-64 bg-muted rounded"></div>
                <div className="h-6 w-48 bg-muted rounded"></div>
                <div className="h-6 w-32 bg-muted rounded"></div>
              </div>
            </div>
            <div className="mt-8">
              <div className="h-10 w-full bg-muted rounded"></div>
              {[1, 2, 3, 4, 5].map((i) => (
                <div
                  key={i}
                  className="h-16 w-full bg-muted rounded mt-2"
                ></div>
              ))}
            </div>
          </div>
        </div>
      </main>
    );
  }

  if (!playlist) {
    return (
      <main className="flex-1 pb-20">
        <div className="container py-8 text-center">
          <h1 className="text-3xl font-bold mb-4">Playlist not found</h1>
          <p className="text-muted-foreground mb-6">
            The playlist you're looking for doesn't exist or has been removed.
          </p>
          <Button asChild>
            <Link href="/library">Go to Library</Link>
          </Button>
        </div>
      </main>
    );
  }

  const canManageCollaborators = playlist.isCreatedByUser;

  return (
    <main className="flex-1 pb-20">
      {/* Playlist Header */}
      <div className="bg-gradient-to-b from-primary/10 to-background pt-8">
        <div className="container">
          <div className="flex flex-col md:flex-row gap-8">
            {/* Playlist Cover */}
            <div className="w-64 h-64 flex-shrink-0 rounded-lg overflow-hidden shadow-lg">
              <Image
                src={playlist.coverArt || "/placeholder.svg"}
                alt={playlist.title}
                width={300}
                height={300}
                className="w-full h-full object-cover"
              />
            </div>

            {/* Playlist Info */}
            <div className="flex flex-col justify-end">
              <div className="flex items-center gap-2 mb-2">
                <Badge variant={playlist.isPublic ? "default" : "outline"}>
                  {playlist.isPublic
                    ? t("playlist.public", "Public")
                    : t("playlist.private", "Private")}
                </Badge>
                {playlist.isCreatedByUser && (
                  <Badge variant="outline">
                    {t("library.created", "Created by you")}
                  </Badge>
                )}
                {playlist.isCollaborative && (
                  <Badge
                    variant="secondary"
                    className="flex items-center gap-1"
                  >
                    <Users className="h-3 w-3" />
                    {t("playlist.collaborative", "Collaborative")}
                  </Badge>
                )}
              </div>
              <h1 className="text-3xl font-bold md:text-4xl lg:text-5xl mb-2">
                {playlist.title}
              </h1>
              <p className="text-muted-foreground mb-2">
                {playlist.description}
              </p>
              <div className="flex items-center gap-1 text-sm text-muted-foreground mb-4">
                <span className="font-medium">{playlist.creator}</span>
                <span>•</span>
                <span>
                  {playlist.trackCount} {t("playlist.tracks", "tracks")}
                </span>
                <span>•</span>
                <span>{playlist.totalDuration}</span>
                {playlist.followers > 0 && (
                  <>
                    <span>•</span>
                    <span>
                      {playlist.followers}{" "}
                      {t("playlist.followers", "followers")}
                    </span>
                  </>
                )}
              </div>

              {/* Collaborators */}
              {playlist.isCollaborative &&
                playlist.collaborators.length > 0 && (
                  <div className="flex items-center gap-2 mb-4">
                    <div className="flex -space-x-2">
                      {playlist.collaborators
                        .slice(0, 3)
                        .map((collaborator) => (
                          <TooltipProvider key={collaborator.id}>
                            <Tooltip>
                              <TooltipTrigger asChild>
                                <Avatar className="h-8 w-8 border-2 border-background">
                                  <AvatarImage
                                    src={
                                      collaborator.avatarUrl ||
                                      "/placeholder.svg"
                                    }
                                    alt={collaborator.name}
                                  />
                                  <AvatarFallback>
                                    {collaborator.name
                                      .split(" ")
                                      .map((n) => n[0])
                                      .join("")}
                                  </AvatarFallback>
                                </Avatar>
                              </TooltipTrigger>
                              <TooltipContent>
                                <p>{collaborator.name}</p>
                                <p className="text-xs text-muted-foreground">
                                  {collaborator.role}
                                </p>
                              </TooltipContent>
                            </Tooltip>
                          </TooltipProvider>
                        ))}
                      {playlist.collaborators.length > 3 && (
                        <Avatar className="h-8 w-8 border-2 border-background bg-muted">
                          <AvatarFallback>
                            +{playlist.collaborators.length - 3}
                          </AvatarFallback>
                        </Avatar>
                      )}
                    </div>
                    {canManageCollaborators && (
                      <Button
                        variant="outline"
                        size="sm"
                        className="h-8 text-xs"
                        onClick={() => setIsCollaboratorsDialogOpen(true)}
                      >
                        {t("playlist.manageCollaborators", "Manage")}
                      </Button>
                    )}
                  </div>
                )}

              {/* Action Buttons */}
              <div className="flex flex-wrap gap-3">
                {isEditMode ? (
                  <>
                    <Button
                      size="lg"
                      className="gap-2"
                      onClick={savePlaylist}
                      disabled={isSaving}
                    >
                      <Save className="h-5 w-5" />
                      {isSaving
                        ? t("playlist.saving", "Saving...")
                        : t("playlist.saveChanges", "Save Changes")}
                    </Button>
                    <Button
                      variant="outline"
                      size="lg"
                      onClick={toggleEditMode}
                      disabled={isSaving}
                    >
                      <X className="h-5 w-5" />
                      {t("playlist.cancel", "Cancel")}
                    </Button>
                  </>
                ) : (
                  <>
                    <Button size="lg" className="gap-2">
                      <Play className="h-5 w-5" />
                      {t("playlist.playAll", "Play All")}
                    </Button>

                    {playlist.isCreatedByUser && (
                      <>
                        <Button
                          variant="outline"
                          size="lg"
                          onClick={toggleEditMode}
                          className="gap-2"
                        >
                          <Pencil className="h-5 w-5" />
                          {t("playlist.reorderTracks", "Reorder Tracks")}
                        </Button>

                        <Button
                          variant="outline"
                          size="lg"
                          onClick={() => setIsCollaboratorsDialogOpen(true)}
                          className="gap-2"
                        >
                          <Users className="h-5 w-5" />
                          {playlist.isCollaborative
                            ? t(
                                "playlist.manageCollaborators",
                                "Manage Collaborators"
                              )
                            : t(
                                "playlist.inviteCollaborators",
                                "Invite Collaborators"
                              )}
                        </Button>
                      </>
                    )}

                    <Button
                      variant="outline"
                      size="lg"
                      onClick={toggleLibrary}
                      className="gap-2"
                    >
                      {playlist.isInLibrary
                        ? t("playlist.removeFromLibrary", "Remove from Library")
                        : t("playlist.addToLibrary", "Add to Library")}
                    </Button>

                    <Button variant="outline" size="icon">
                      <Download className="h-5 w-5" />
                      <span className="sr-only">
                        {t("playlist.download", "Download")}
                      </span>
                    </Button>

                    <Button variant="outline" size="icon">
                      <Share2 className="h-5 w-5" />
                      <span className="sr-only">
                        {t("playlist.share", "Share")}
                      </span>
                    </Button>

                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="outline" size="icon">
                          <MoreHorizontal className="h-5 w-5" />
                          <span className="sr-only">
                            {t("playlist.more", "More")}
                          </span>
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem>
                          {t("playlist.addToQueue", "Add to Queue")}
                        </DropdownMenuItem>
                        {playlist.isCreatedByUser && (
                          <>
                            <DropdownMenuSeparator />
                            <DropdownMenuItem>
                              {t("playlist.editPlaylist", "Edit Playlist")}
                            </DropdownMenuItem>
                            <DropdownMenuItem className="text-destructive">
                              {t("playlist.deletePlaylist", "Delete Playlist")}
                            </DropdownMenuItem>
                          </>
                        )}
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Playlist Content Tabs */}
      <div className="container py-8">
        <Tabs
          defaultValue="tracks"
          value={activeTab}
          onValueChange={setActiveTab}
        >
          <TabsList className="mb-6">
            <TabsTrigger value="tracks" className="gap-2">
              <Music className="h-4 w-4" />
              Tracks
            </TabsTrigger>
            {playlist.isCollaborative && (
              <TabsTrigger value="activity" className="gap-2">
                <History className="h-4 w-4" />
                Activity
              </TabsTrigger>
            )}
          </TabsList>

          {/* Tracks Tab */}
          <TabsContent value="tracks">
            {playlist.tracks.length > 0 ? (
              <DndContext
                sensors={sensors}
                collisionDetection={closestCenter}
                onDragEnd={handleDragEnd}
              >
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="w-[60px]">
                        {isEditMode ? (
                          <span className="sr-only">Drag handle</span>
                        ) : (
                          <span>#</span>
                        )}
                      </TableHead>
                      <TableHead>Title</TableHead>
                      <TableHead className="hidden md:table-cell">
                        {t("playlist.album", "Album")}
                      </TableHead>
                      {playlist.isCollaborative && (
                        <TableHead className="hidden lg:table-cell">
                          {t("playlist.addedBy", "Added By")}
                        </TableHead>
                      )}
                      <TableHead className="hidden lg:table-cell">
                        {t("playlist.dateAdded", "Date Added")}
                      </TableHead>
                      <TableHead className="text-right">
                        <Clock className="ml-auto h-4 w-4" />
                        <span className="sr-only">
                          {t("playlist.duration", "Duration")}
                        </span>
                      </TableHead>
                      <TableHead className="w-[70px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    <SortableContext
                      items={playlist.tracks.map((track) => track.id)}
                      strategy={verticalListSortingStrategy}
                    >
                      {playlist.tracks.map((track, index) => (
                        <SortableTrackRow
                          key={track.id}
                          track={track}
                          index={index}
                          toggleLike={toggleLike}
                          isEditMode={isEditMode}
                          showAddedBy={playlist.isCollaborative}
                        />
                      ))}
                    </SortableContext>
                  </TableBody>
                </Table>
              </DndContext>
            ) : (
              <div className="flex flex-col items-center justify-center py-16 text-center">
                <div className="mb-4 rounded-full bg-muted p-6">
                  <Music className="h-12 w-12 text-muted-foreground" />
                </div>
                <h3 className="mb-2 text-xl font-semibold">
                  {t("playlist.noTracks", "No tracks in this playlist")}
                </h3>
                {playlist.isCreatedByUser && (
                  <Button className="mt-4 gap-2">
                    <Plus className="h-4 w-4" />
                    {t("playlist.addTracks", "Add Tracks")}
                  </Button>
                )}
              </div>
            )}
          </TabsContent>

          {/* Activity Tab */}
          {playlist.isCollaborative && (
            <TabsContent value="activity">
              <ActivityFeed playlistId={playlist.id} />
            </TabsContent>
          )}
        </Tabs>
      </div>

      {/* Collaborators Dialog */}
      <CollaboratorsDialog
        open={isCollaboratorsDialogOpen}
        onOpenChange={setIsCollaboratorsDialogOpen}
        playlist={playlist}
        onCollaboratorsUpdate={handleCollaboratorsUpdate}
      />
    </main>
  );
}
