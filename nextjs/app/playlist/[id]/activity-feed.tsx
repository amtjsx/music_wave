"use client";

import { useState } from "react";
import { formatDistanceToNow } from "date-fns";
import {
  Clock,
  Filter,
  Music,
  Plus,
  Trash,
  Edit,
  Users,
  MoveVertical,
  Lock,
  ImageIcon,
  RefreshCw,
} from "lucide-react";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuCheckboxItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";

// Activity types
type ActivityType =
  | "track_added"
  | "track_removed"
  | "track_reordered"
  | "details_edited"
  | "collaborator_added"
  | "collaborator_removed"
  | "privacy_changed"
  | "cover_changed";

interface ActivityItem {
  id: string;
  type: ActivityType;
  userId: string;
  userName: string;
  userAvatar: string;
  timestamp: Date;
  details: {
    trackId?: string;
    trackName?: string;
    trackArtist?: string;
    collaboratorId?: string;
    collaboratorName?: string;
    oldValue?: string;
    newValue?: string;
    fieldName?: string;
  };
}

// Sample activity data
const generateSampleActivities = (): ActivityItem[] => {
  const now = new Date();

  return [
    {
      id: "act1",
      type: "track_added",
      userId: "user1",
      userName: "Alex Johnson",
      userAvatar: "/placeholder.svg?height=40&width=40&text=AJ",
      timestamp: new Date(now.getTime() - 15 * 60000), // 15 minutes ago
      details: {
        trackId: "track101",
        trackName: "Midnight City",
        trackArtist: "M83",
      },
    },
    {
      id: "act2",
      type: "collaborator_added",
      userId: "user2",
      userName: "Sam Smith",
      userAvatar: "/placeholder.svg?height=40&width=40&text=SS",
      timestamp: new Date(now.getTime() - 2 * 3600000), // 2 hours ago
      details: {
        collaboratorId: "user3",
        collaboratorName: "Emily Wilson",
      },
    },
    {
      id: "act3",
      type: "track_removed",
      userId: "user3",
      userName: "Emily Wilson",
      userAvatar: "/placeholder.svg?height=40&width=40&text=EW",
      timestamp: new Date(now.getTime() - 5 * 3600000), // 5 hours ago
      details: {
        trackId: "track102",
        trackName: "Starboy",
        trackArtist: "The Weeknd",
      },
    },
    {
      id: "act4",
      type: "details_edited",
      userId: "user1",
      userName: "Alex Johnson",
      userAvatar: "/placeholder.svg?height=40&width=40&text=AJ",
      timestamp: new Date(now.getTime() - 8 * 3600000), // 8 hours ago
      details: {
        fieldName: "title",
        oldValue: "My Playlist",
        newValue: "Summer Vibes 2023",
      },
    },
    {
      id: "act5",
      type: "track_reordered",
      userId: "user2",
      userName: "Sam Smith",
      userAvatar: "/placeholder.svg?height=40&width=40&text=SS",
      timestamp: new Date(now.getTime() - 1 * 86400000), // 1 day ago
      details: {
        trackId: "track103",
        trackName: "Blinding Lights",
        trackArtist: "The Weeknd",
      },
    },
    {
      id: "act6",
      type: "privacy_changed",
      userId: "user1",
      userName: "Alex Johnson",
      userAvatar: "/placeholder.svg?height=40&width=40&text=AJ",
      timestamp: new Date(now.getTime() - 2 * 86400000), // 2 days ago
      details: {
        oldValue: "private",
        newValue: "public",
      },
    },
    {
      id: "act7",
      type: "cover_changed",
      userId: "user1",
      userName: "Alex Johnson",
      userAvatar: "/placeholder.svg?height=40&width=40&text=AJ",
      timestamp: new Date(now.getTime() - 3 * 86400000), // 3 days ago
      details: {},
    },
    {
      id: "act8",
      type: "track_added",
      userId: "user3",
      userName: "Emily Wilson",
      userAvatar: "/placeholder.svg?height=40&width=40&text=EW",
      timestamp: new Date(now.getTime() - 4 * 86400000), // 4 days ago
      details: {
        trackId: "track104",
        trackName: "As It Was",
        trackArtist: "Harry Styles",
      },
    },
    {
      id: "act9",
      type: "collaborator_removed",
      userId: "user1",
      userName: "Alex Johnson",
      userAvatar: "/placeholder.svg?height=40&width=40&text=AJ",
      timestamp: new Date(now.getTime() - 5 * 86400000), // 5 days ago
      details: {
        collaboratorId: "user4",
        collaboratorName: "Michael Brown",
      },
    },
    {
      id: "act10",
      type: "track_added",
      userId: "user2",
      userName: "Sam Smith",
      userAvatar: "/placeholder.svg?height=40&width=40&text=SS",
      timestamp: new Date(now.getTime() - 6 * 86400000), // 6 days ago
      details: {
        trackId: "track105",
        trackName: "Bad Habits",
        trackArtist: "Ed Sheeran",
      },
    },
  ];
};

// Helper function to group activities by date
const groupActivitiesByDate = (activities: ActivityItem[]) => {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);

  const groups: { [key: string]: ActivityItem[] } = {
    today: [],
    yesterday: [],
    thisWeek: [],
    thisMonth: [],
    older: [],
  };

  activities.forEach((activity) => {
    const activityDate = new Date(activity.timestamp);
    const activityDay = new Date(
      activityDate.getFullYear(),
      activityDate.getMonth(),
      activityDate.getDate()
    );

    if (activityDay.getTime() === today.getTime()) {
      groups.today.push(activity);
    } else if (activityDay.getTime() === yesterday.getTime()) {
      groups.yesterday.push(activity);
    } else if (activityDay >= new Date(today.getTime() - 6 * 86400000)) {
      groups.thisWeek.push(activity);
    } else if (activityDate.getMonth() === now.getMonth()) {
      groups.thisMonth.push(activity);
    } else {
      groups.older.push(activity);
    }
  });

  return groups;
};

// Activity icon mapping
const getActivityIcon = (type: ActivityType) => {
  switch (type) {
    case "track_added":
      return <Plus className="h-4 w-4" />;
    case "track_removed":
      return <Trash className="h-4 w-4" />;
    case "track_reordered":
      return <MoveVertical className="h-4 w-4" />;
    case "details_edited":
      return <Edit className="h-4 w-4" />;
    case "collaborator_added":
      return <Users className="h-4 w-4" />;
    case "collaborator_removed":
      return <Users className="h-4 w-4" />;
    case "privacy_changed":
      return <Lock className="h-4 w-4" />;
    case "cover_changed":
      return <ImageIcon className="h-4 w-4" />;
    default:
      return <Music className="h-4 w-4" />;
  }
};

// Activity color mapping
const getActivityColor = (type: ActivityType) => {
  switch (type) {
    case "track_added":
      return "bg-green-500";
    case "track_removed":
      return "bg-red-500";
    case "track_reordered":
      return "bg-amber-500";
    case "details_edited":
      return "bg-blue-500";
    case "collaborator_added":
      return "bg-purple-500";
    case "collaborator_removed":
      return "bg-purple-500";
    case "privacy_changed":
      return "bg-slate-500";
    case "cover_changed":
      return "bg-pink-500";
    default:
      return "bg-gray-500";
  }
};

// Activity description mapping
const getActivityDescription = (activity: ActivityItem) => {
  const { type, details } = activity;

  switch (type) {
    case "track_added":
      return (
        <span>
          Added <span className="font-medium">{details.trackName}</span> by{" "}
          {details.trackArtist}
        </span>
      );
    case "track_removed":
      return (
        <span>
          Removed <span className="font-medium">{details.trackName}</span> by{" "}
          {details.trackArtist}
        </span>
      );
    case "track_reordered":
      return (
        <span>
          Reordered <span className="font-medium">{details.trackName}</span> in
          the playlist
        </span>
      );
    case "details_edited":
      return (
        <span>
          Changed playlist {details.fieldName} from "{details.oldValue}" to "
          {details.newValue}"
        </span>
      );
    case "collaborator_added":
      return (
        <span>
          Added <span className="font-medium">{details.collaboratorName}</span>{" "}
          as a collaborator
        </span>
      );
    case "collaborator_removed":
      return (
        <span>
          Removed{" "}
          <span className="font-medium">{details.collaboratorName}</span> as a
          collaborator
        </span>
      );
    case "privacy_changed":
      return (
        <span>
          Changed playlist privacy from {details.oldValue} to {details.newValue}
        </span>
      );
    case "cover_changed":
      return <span>Updated the playlist cover image</span>;
    default:
      return <span>Unknown activity</span>;
  }
};

// Activity item component
const ActivityItem = ({ activity }: { activity: ActivityItem }) => {
  return (
    <div className="flex items-start gap-4 py-3">
      <Avatar className="h-8 w-8">
        <AvatarImage
          src={activity.userAvatar || "/placeholder.svg"}
          alt={activity.userName}
        />
        <AvatarFallback>
          {activity.userName
            .split(" ")
            .map((n) => n[0])
            .join("")}
        </AvatarFallback>
      </Avatar>

      <div className="flex-1 space-y-1">
        <div className="flex items-center gap-2">
          <span className="font-medium">{activity.userName}</span>
          <span className="text-xs text-muted-foreground">
            {formatDistanceToNow(activity.timestamp, { addSuffix: true })}
          </span>
        </div>

        <div className="flex items-center gap-2">
          <div
            className={cn(
              "rounded-full p-1.5",
              getActivityColor(activity.type)
            )}
          >
            {getActivityIcon(activity.type)}
          </div>
          <span className="text-sm">{getActivityDescription(activity)}</span>
        </div>
      </div>
    </div>
  );
};

// Empty state component
const EmptyState = () => {
  return (
    <div className="flex flex-col items-center justify-center py-12 text-center">
      <div className="mb-4 rounded-full bg-muted p-6">
        <Clock className="h-10 w-10 text-muted-foreground" />
      </div>
      <h3 className="mb-2 text-xl font-semibold">No activity yet</h3>
      <p className="text-muted-foreground mb-4 max-w-md">
        Activity will appear here when you or your collaborators make changes to
        this playlist.
      </p>
    </div>
  );
};

// Loading state component
const LoadingState = () => {
  return (
    <div className="space-y-4">
      {Array.from({ length: 5 }).map((_, i) => (
        <div key={i} className="flex items-start gap-4 py-3">
          <Skeleton className="h-8 w-8 rounded-full" />
          <div className="flex-1 space-y-2">
            <div className="flex items-center gap-2">
              <Skeleton className="h-4 w-24" />
              <Skeleton className="h-3 w-16" />
            </div>
            <div className="flex items-center gap-2">
              <Skeleton className="h-6 w-6 rounded-full" />
              <Skeleton className="h-4 w-48" />
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

// Main activity feed component
export function ActivityFeed({ playlistId }: { playlistId: string }) {
  const [isLoading, setIsLoading] = useState(true);
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [filteredActivities, setFilteredActivities] = useState<ActivityItem[]>(
    []
  );
  const [activeFilters, setActiveFilters] = useState<ActivityType[]>([]);
  const [activeTab, setActiveTab] = useState<string>("all");

  // Fetch activities on component mount
  useState(() => {
    // Simulate API call
    setTimeout(() => {
      const sampleActivities = generateSampleActivities();
      setActivities(sampleActivities);
      setFilteredActivities(sampleActivities);
      setIsLoading(false);
    }, 1500);
  });

  // Filter activities by type
  const toggleFilter = (type: ActivityType) => {
    setActiveFilters((prev) => {
      if (prev.includes(type)) {
        const newFilters = prev.filter((t) => t !== type);
        setFilteredActivities(
          newFilters.length === 0
            ? activities
            : activities.filter((activity) =>
                newFilters.includes(activity.type)
              )
        );
        return newFilters;
      } else {
        const newFilters = [...prev, type];
        setFilteredActivities(
          activities.filter((activity) => newFilters.includes(activity.type))
        );
        return newFilters;
      }
    });
  };

  // Filter activities by user
  const filterByUser = (userId: string) => {
    if (userId === "all") {
      setFilteredActivities(
        activeFilters.length === 0
          ? activities
          : activities.filter((activity) =>
              activeFilters.includes(activity.type)
            )
      );
    } else {
      setFilteredActivities(
        activities.filter(
          (activity) =>
            activity.userId === userId &&
            (activeFilters.length === 0 ||
              activeFilters.includes(activity.type))
        )
      );
    }
    setActiveTab(userId);
  };

  // Group activities by date
  const groupedActivities = groupActivitiesByDate(filteredActivities);

  // Get unique users from activities
  const users = Array.from(
    new Set(activities.map((activity) => activity.userId))
  ).map((userId) => {
    const user = activities.find((activity) => activity.userId === userId);
    return {
      id: userId,
      name: user?.userName || "",
      avatar: user?.userAvatar || "",
    };
  });

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <div>
          <CardTitle>Activity Feed</CardTitle>
          <CardDescription>Recent changes to this playlist</CardDescription>
        </div>

        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm" className="h-8 gap-1">
                <Filter className="h-3.5 w-3.5" />
                <span>Filter</span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuCheckboxItem
                checked={activeFilters.includes("track_added")}
                onCheckedChange={() => toggleFilter("track_added")}
              >
                Tracks Added
              </DropdownMenuCheckboxItem>
              <DropdownMenuCheckboxItem
                checked={activeFilters.includes("track_removed")}
                onCheckedChange={() => toggleFilter("track_removed")}
              >
                Tracks Removed
              </DropdownMenuCheckboxItem>
              <DropdownMenuCheckboxItem
                checked={activeFilters.includes("track_reordered")}
                onCheckedChange={() => toggleFilter("track_reordered")}
              >
                Tracks Reordered
              </DropdownMenuCheckboxItem>
              <DropdownMenuCheckboxItem
                checked={activeFilters.includes("details_edited")}
                onCheckedChange={() => toggleFilter("details_edited")}
              >
                Details Edited
              </DropdownMenuCheckboxItem>
              <DropdownMenuCheckboxItem
                checked={
                  activeFilters.includes("collaborator_added") ||
                  activeFilters.includes("collaborator_removed")
                }
                onCheckedChange={() => {
                  toggleFilter("collaborator_added");
                  toggleFilter("collaborator_removed");
                }}
              >
                Collaborator Changes
              </DropdownMenuCheckboxItem>
              <DropdownMenuCheckboxItem
                checked={activeFilters.includes("privacy_changed")}
                onCheckedChange={() => toggleFilter("privacy_changed")}
              >
                Privacy Changes
              </DropdownMenuCheckboxItem>
              <DropdownMenuCheckboxItem
                checked={activeFilters.includes("cover_changed")}
                onCheckedChange={() => toggleFilter("cover_changed")}
              >
                Cover Changes
              </DropdownMenuCheckboxItem>
            </DropdownMenuContent>
          </DropdownMenu>

          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8"
            onClick={() => window.location.reload()}
          >
            <RefreshCw className="h-4 w-4" />
            <span className="sr-only">Refresh</span>
          </Button>
        </div>
      </CardHeader>

      <CardContent>
        <Tabs
          defaultValue="all"
          value={activeTab}
          onValueChange={filterByUser}
          className="w-full"
        >
          <TabsList className="mb-4 w-full justify-start overflow-x-auto">
            <TabsTrigger value="all">All</TabsTrigger>
            {users.map((user) => (
              <TabsTrigger
                key={user.id}
                value={user.id}
                className="flex items-center gap-2"
              >
                <Avatar className="h-4 w-4">
                  <AvatarImage
                    src={user.avatar || "/placeholder.svg"}
                    alt={user.name}
                  />
                  <AvatarFallback className="text-[8px]">
                    {user.name
                      .split(" ")
                      .map((n) => n[0])
                      .join("")}
                  </AvatarFallback>
                </Avatar>
                <span>{user.name}</span>
              </TabsTrigger>
            ))}
          </TabsList>

          <ScrollArea className="h-[500px] pr-4">
            {isLoading ? (
              <LoadingState />
            ) : filteredActivities.length === 0 ? (
              <EmptyState />
            ) : (
              <div className="space-y-6">
                {groupedActivities.today.length > 0 && (
                  <div>
                    <h3 className="mb-2 text-sm font-medium text-muted-foreground">
                      Today
                    </h3>
                    <div className="divide-y">
                      {groupedActivities.today.map((activity) => (
                        <ActivityItem key={activity.id} activity={activity} />
                      ))}
                    </div>
                  </div>
                )}

                {groupedActivities.yesterday.length > 0 && (
                  <div>
                    <h3 className="mb-2 text-sm font-medium text-muted-foreground">
                      Yesterday
                    </h3>
                    <div className="divide-y">
                      {groupedActivities.yesterday.map((activity) => (
                        <ActivityItem key={activity.id} activity={activity} />
                      ))}
                    </div>
                  </div>
                )}

                {groupedActivities.thisWeek.length > 0 && (
                  <div>
                    <h3 className="mb-2 text-sm font-medium text-muted-foreground">
                      This Week
                    </h3>
                    <div className="divide-y">
                      {groupedActivities.thisWeek.map((activity) => (
                        <ActivityItem key={activity.id} activity={activity} />
                      ))}
                    </div>
                  </div>
                )}

                {groupedActivities.thisMonth.length > 0 && (
                  <div>
                    <h3 className="mb-2 text-sm font-medium text-muted-foreground">
                      This Month
                    </h3>
                    <div className="divide-y">
                      {groupedActivities.thisMonth.map((activity) => (
                        <ActivityItem key={activity.id} activity={activity} />
                      ))}
                    </div>
                  </div>
                )}

                {groupedActivities.older.length > 0 && (
                  <div>
                    <h3 className="mb-2 text-sm font-medium text-muted-foreground">
                      Older
                    </h3>
                    <div className="divide-y">
                      {groupedActivities.older.map((activity) => (
                        <ActivityItem key={activity.id} activity={activity} />
                      ))}
                    </div>
                  </div>
                )}
              </div>
            )}
          </ScrollArea>
        </Tabs>
      </CardContent>
    </Card>
  );
}
