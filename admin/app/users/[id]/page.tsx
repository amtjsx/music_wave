import { TrustScoreBadge } from "@/app/components/trust-score-badge";
import { TrustScoreCard } from "@/app/components/trust-score-card";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import {
  AlertTriangle,
  Flag,
  ListMusic,
  MessageSquare,
  Music,
  Shield,
  ThumbsUp,
  User,
  UserCheck,
  UserX,
} from "lucide-react";

// Mock data for demonstration
const mockUserData = {
  user123: {
    userId: "user123",
    username: "johndoe",
    email: "john.doe@example.com",
    name: "John Doe",
    joinDate: "2023-01-15",
    score: 45,
    accountAge: 120,
    factors: {
      comments: {
        count: 45,
        likes: 78,
        reports: 1,
      },
      content: {
        tracks: 8,
        playlists: 3,
      },
      community: {
        followers: 32,
        following: 64,
        shares: 12,
      },
      moderation: {
        validReports: 4,
        warnings: 0,
      },
    },
    history: [
      { date: "2023-05-01", score: 35, change: 0, reason: "Initial score" },
      {
        date: "2023-05-15",
        score: 38,
        change: 3,
        reason: "Uploaded new track",
      },
      { date: "2023-06-02", score: 40, change: 2, reason: "Gained followers" },
      {
        date: "2023-06-18",
        score: 42,
        change: 2,
        reason: "Positive comment engagement",
      },
      { date: "2023-07-05", score: 41, change: -1, reason: "Comment reported" },
      {
        date: "2023-07-20",
        score: 45,
        change: 4,
        reason: "Created popular playlist",
      },
    ],
    recentActivity: [
      {
        type: "track_upload",
        date: "2023-07-18",
        details: "Uploaded 'Summer Vibes'",
      },
      {
        type: "comment",
        date: "2023-07-15",
        details: "Commented on 'Midnight Jazz'",
      },
      {
        type: "playlist",
        date: "2023-07-10",
        details: "Created playlist 'Chill Beats'",
      },
      {
        type: "follow",
        date: "2023-07-05",
        details: "Followed artist JazzMaster",
      },
      { type: "like", date: "2023-07-01", details: "Liked 'Urban Rhythms'" },
    ],
    reportHistory: [
      {
        date: "2023-06-25",
        status: "resolved",
        reason: "Inappropriate comment",
        outcome: "Warning issued",
      },
    ],
  },
  user456: {
    userId: "user456",
    username: "musicmaster",
    email: "music.master@example.com",
    name: "Music Master",
    joinDate: "2022-05-10",
    score: 82,
    accountAge: 365,
    factors: {
      comments: {
        count: 156,
        likes: 423,
        reports: 0,
      },
      content: {
        tracks: 25,
        playlists: 12,
      },
      community: {
        followers: 245,
        following: 187,
        shares: 78,
      },
      moderation: {
        validReports: 10,
        warnings: 0,
      },
    },
    history: [
      { date: "2022-05-10", score: 30, change: 0, reason: "Initial score" },
      { date: "2022-06-15", score: 35, change: 5, reason: "Regular activity" },
      {
        date: "2022-08-22",
        score: 45,
        change: 10,
        reason: "Track featured in editorial",
      },
      {
        date: "2022-10-30",
        score: 55,
        change: 10,
        reason: "Consistent positive engagement",
      },
      {
        date: "2023-01-12",
        score: 65,
        change: 10,
        reason: "Helpful community reports",
      },
      {
        date: "2023-03-25",
        score: 75,
        change: 10,
        reason: "Reached 200 followers",
      },
      {
        date: "2023-05-18",
        score: 82,
        change: 7,
        reason: "High-quality content creation",
      },
    ],
    recentActivity: [
      {
        type: "track_upload",
        date: "2023-07-20",
        details: "Uploaded 'Electronic Dreams'",
      },
      {
        type: "comment",
        date: "2023-07-19",
        details: "Commented on 'Bass Drop'",
      },
      {
        type: "playlist",
        date: "2023-07-15",
        details: "Created playlist 'EDM Essentials'",
      },
      {
        type: "follow",
        date: "2023-07-12",
        details: "Followed artist BeatMaker",
      },
      { type: "like", date: "2023-07-10", details: "Liked 'Techno Fusion'" },
    ],
    reportHistory: [],
  },
  user789: {
    userId: "user789",
    username: "newuser",
    email: "new.user@example.com",
    name: "New User",
    joinDate: "2023-04-05",
    score: 15,
    accountAge: 30,
    factors: {
      comments: {
        count: 12,
        likes: 5,
        reports: 3,
      },
      content: {
        tracks: 1,
        playlists: 0,
      },
      community: {
        followers: 4,
        following: 15,
        shares: 1,
      },
      moderation: {
        validReports: 0,
        warnings: 1,
      },
    },
    history: [
      { date: "2023-04-05", score: 20, change: 0, reason: "Initial score" },
      {
        date: "2023-04-12",
        score: 22,
        change: 2,
        reason: "First track upload",
      },
      { date: "2023-04-20", score: 18, change: -4, reason: "Comment reported" },
      { date: "2023-04-28", score: 13, change: -5, reason: "Warning received" },
      {
        date: "2023-05-10",
        score: 15,
        change: 2,
        reason: "Positive engagement",
      },
    ],
    recentActivity: [
      {
        type: "comment",
        date: "2023-05-08",
        details: "Commented on 'First Steps'",
      },
      {
        type: "track_upload",
        date: "2023-04-10",
        details: "Uploaded 'My First Track'",
      },
      {
        type: "follow",
        date: "2023-04-08",
        details: "Followed artist PopStar",
      },
      { type: "like", date: "2023-04-07", details: "Liked 'Welcome to Music'" },
    ],
    reportHistory: [
      {
        date: "2023-04-18",
        status: "resolved",
        reason: "Spam comment",
        outcome: "Comment removed",
      },
      {
        date: "2023-04-25",
        status: "resolved",
        reason: "Abusive language",
        outcome: "Warning issued",
      },
    ],
  },
};

export default async function UserAdminPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const userData = mockUserData[id] || mockUserData["user123"]; // Fallback to default user

  return (
    <div className="container mx-auto py-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold flex items-center gap-2">
            <User className="h-6 w-6" />
            User Management
          </h1>
          <p className="text-muted-foreground">
            Manage user details, trust score, and moderation actions
          </p>
        </div>
        <div className="flex items-center gap-2">
          <TrustScoreBadge score={userData.score} showLabel size="lg" />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>User Information</CardTitle>
              <CardDescription>
                Basic details and account information
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="username">Username</Label>
                  <Input id="username" value={userData.username} readOnly />
                </div>
                <div>
                  <Label htmlFor="email">Email</Label>
                  <Input id="email" value={userData.email} readOnly />
                </div>
                <div>
                  <Label htmlFor="name">Full Name</Label>
                  <Input id="name" value={userData.name} readOnly />
                </div>
                <div>
                  <Label htmlFor="joinDate">Join Date</Label>
                  <Input id="joinDate" value={userData.joinDate} readOnly />
                </div>
              </div>
            </CardContent>
          </Card>

          <Tabs defaultValue="activity">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="activity">Recent Activity</TabsTrigger>
              <TabsTrigger value="reports">Report History</TabsTrigger>
              <TabsTrigger value="actions">Admin Actions</TabsTrigger>
            </TabsList>

            <TabsContent value="activity" className="space-y-4 pt-4">
              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-lg">User Activity</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {userData.recentActivity.map((activity, i) => (
                      <div
                        key={i}
                        className="flex items-start gap-3 pb-3 border-b last:border-0"
                      >
                        <div className="mt-0.5">
                          {activity.type === "track_upload" && (
                            <Music className="h-5 w-5 text-purple-500" />
                          )}
                          {activity.type === "comment" && (
                            <MessageSquare className="h-5 w-5 text-blue-500" />
                          )}
                          {activity.type === "playlist" && (
                            <ListMusic className="h-5 w-5 text-green-500" />
                          )}
                          {activity.type === "follow" && (
                            <UserCheck className="h-5 w-5 text-amber-500" />
                          )}
                          {activity.type === "like" && (
                            <ThumbsUp className="h-5 w-5 text-red-500" />
                          )}
                        </div>
                        <div>
                          <p className="font-medium">{activity.details}</p>
                          <p className="text-sm text-muted-foreground">
                            {activity.date}
                          </p>
                        </div>
                      </div>
                    ))}

                    {userData.recentActivity.length === 0 && (
                      <p className="text-muted-foreground text-center py-4">
                        No recent activity
                      </p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="reports" className="space-y-4 pt-4">
              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-lg">Report History</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    {userData.reportHistory.map((report, i) => (
                      <div
                        key={i}
                        className="flex items-start gap-3 pb-3 border-b last:border-0"
                      >
                        <div className="mt-0.5">
                          <Flag className="h-5 w-5 text-red-500" />
                        </div>
                        <div className="flex-1">
                          <div className="flex items-center justify-between">
                            <p className="font-medium">{report.reason}</p>
                            <span className="text-xs bg-amber-100 text-amber-800 px-2 py-0.5 rounded-full">
                              {report.status}
                            </span>
                          </div>
                          <p className="text-sm">{report.outcome}</p>
                          <p className="text-sm text-muted-foreground">
                            {report.date}
                          </p>
                        </div>
                      </div>
                    ))}

                    {userData.reportHistory.length === 0 && (
                      <p className="text-muted-foreground text-center py-4">
                        No report history
                      </p>
                    )}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="actions" className="space-y-4 pt-4">
              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-lg">
                    Trust Score Adjustment
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="grid grid-cols-3 gap-4">
                      <div className="col-span-2">
                        <Label htmlFor="adjustment">Score Adjustment</Label>
                        <Input
                          id="adjustment"
                          type="number"
                          placeholder="-10 to +10"
                        />
                      </div>
                      <div>
                        <Label>&nbsp;</Label>
                        <div className="grid grid-cols-2 gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            className="w-full"
                          >
                            -5
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            className="w-full"
                          >
                            +5
                          </Button>
                        </div>
                      </div>
                    </div>

                    <div>
                      <Label htmlFor="reason">Reason for Adjustment</Label>
                      <Textarea
                        id="reason"
                        placeholder="Explain why you're adjusting this user's trust score"
                      />
                    </div>

                    <div className="flex justify-end gap-2">
                      <Button variant="outline">Cancel</Button>
                      <Button>Apply Adjustment</Button>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-lg">Moderation Actions</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <Button variant="outline" className="justify-start">
                        <AlertTriangle className="mr-2 h-4 w-4 text-amber-500" />
                        Issue Warning
                      </Button>

                      <Button variant="outline" className="justify-start">
                        <Shield className="mr-2 h-4 w-4 text-blue-500" />
                        Reset Trust Score
                      </Button>

                      <Button variant="outline" className="justify-start">
                        <UserX className="mr-2 h-4 w-4 text-red-500" />
                        Temporary Suspension
                      </Button>

                      <Button
                        variant="outline"
                        className="justify-start text-red-500 hover:text-red-600 hover:bg-red-50"
                      >
                        <AlertTriangle className="mr-2 h-4 w-4" />
                        Permanent Ban
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </div>

        <div className="lg:col-span-1">
          <TrustScoreCard
            userId={userData.userId}
            username={userData.username}
            score={userData.score}
            accountAge={userData.accountAge}
            factors={userData.factors}
            history={userData.history}
          />
        </div>
      </div>
    </div>
  );
}
