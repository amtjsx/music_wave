import { TrustScoreCard } from "../../components/trust-score-card";

// Mock data for demonstration
const mockUserData = {
  johndoe: {
    userId: "user123",
    username: "johndoe",
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
  },
  musicmaster: {
    userId: "user456",
    username: "musicmaster",
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
  },
  newuser: {
    userId: "user789",
    username: "newuser",
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
  },
};

export default async function UserProfilePage({
  params,
}: {
  params: Promise<{ username: string }>;
}) {
  const { username } = await params;
  const userData = mockUserData[username] || mockUserData["johndoe"]; // Fallback to default user

  return (
    <div className="container mx-auto py-8">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div className="md:col-span-2">
          <h1 className="text-2xl font-bold mb-4">
            User Profile: {userData.username}
          </h1>
          <div className="h-64 bg-slate-100 rounded-lg mb-8 flex items-center justify-center">
            <p className="text-slate-500">
              User profile content would appear here
            </p>
          </div>
        </div>

        <div className="md:col-span-1">
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
