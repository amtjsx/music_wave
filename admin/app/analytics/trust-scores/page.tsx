"use client";
import { BarChart, LineChart, DonutChart } from "@tremor/react";
import {
  Filter,
  Download,
  Users,
  TrendingUp,
  AlertTriangle,
  Shield,
  Map,
  Activity,
} from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { DatePickerWithRange } from "@/app/components/date-range-picker";

// Mock data - would be replaced with real API calls
const trustLevelDistribution = [
  { name: "New (0-20)", value: 1254 },
  { name: "Basic (21-50)", value: 3842 },
  { name: "Trusted (51-75)", value: 2156 },
  { name: "Core (76-90)", value: 987 },
  { name: "Exceptional (91-100)", value: 432 },
];

const trustScoreTrend = [
  { date: "Jan 2023", average: 42, new: 22, returning: 58 },
  { date: "Feb 2023", average: 45, new: 24, returning: 59 },
  { date: "Mar 2023", average: 47, new: 25, returning: 61 },
  { date: "Apr 2023", average: 48, new: 26, returning: 62 },
  { date: "May 2023", average: 51, new: 28, returning: 64 },
  { date: "Jun 2023", average: 53, new: 29, returning: 65 },
  { date: "Jul 2023", average: 55, new: 31, returning: 67 },
  { date: "Aug 2023", average: 56, new: 32, returning: 68 },
  { date: "Sep 2023", average: 58, new: 33, returning: 70 },
  { date: "Oct 2023", average: 59, new: 35, returning: 71 },
  { date: "Nov 2023", average: 61, new: 36, returning: 73 },
  { date: "Dec 2023", average: 62, new: 38, returning: 74 },
];

const actionImpact = [
  { action: "Content Upload", impact: 8.4, volume: 12567 },
  { action: "Receiving Likes", impact: 6.2, volume: 45982 },
  { action: "Commenting", impact: 4.7, volume: 28734 },
  { action: "Playlist Creation", impact: 3.9, volume: 8921 },
  { action: "Valid Reports", impact: 2.8, volume: 3245 },
  { action: "Content Removal", impact: -7.6, volume: 1243 },
  { action: "Warnings", impact: -5.2, volume: 2876 },
  { action: "Comment Reports", impact: -3.1, volume: 4532 },
];

const regionData = [
  { region: "North America", average: 58, users: 12567 },
  { region: "Europe", average: 62, users: 10234 },
  { region: "Asia", average: 54, users: 8765 },
  { region: "South America", average: 51, users: 4532 },
  { region: "Africa", average: 49, users: 2345 },
  { region: "Oceania", average: 64, users: 1876 },
];

const TrustScoreOverview = () => {
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">
            Average Trust Score
          </CardTitle>
          <Shield className="h-4 w-4 text-purple-600" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">58.4</div>
          <p className="text-xs text-muted-foreground">+2.3 from last month</p>
          <div className="mt-4 h-1 w-full bg-gray-200 rounded-full">
            <div
              className="h-1 bg-purple-600 rounded-full"
              style={{ width: "58.4%" }}
            ></div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">
            Total Users Tracked
          </CardTitle>
          <Users className="h-4 w-4 text-purple-600" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">8,671</div>
          <p className="text-xs text-muted-foreground">+342 from last month</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">
            Trust Score Growth
          </CardTitle>
          <TrendingUp className="h-4 w-4 text-green-600" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">+4.2%</div>
          <p className="text-xs text-muted-foreground">Platform-wide average</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">
            Trust Violations
          </CardTitle>
          <AlertTriangle className="h-4 w-4 text-amber-600" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">187</div>
          <p className="text-xs text-muted-foreground">-23 from last month</p>
        </CardContent>
      </Card>
    </div>
  );
};

const TrustDistributionChart = () => {
  return (
    <Card className="col-span-1">
      <CardHeader>
        <CardTitle>Trust Level Distribution</CardTitle>
        <CardDescription>Breakdown of users by trust level</CardDescription>
      </CardHeader>
      <CardContent>
        <DonutChart
          data={trustLevelDistribution}
          category="value"
          index="name"
          colors={["slate", "purple", "indigo", "violet", "fuchsia"]}
          className="h-80"
        />
      </CardContent>
      <CardFooter className="flex justify-between">
        <div className="flex flex-wrap gap-2">
          {trustLevelDistribution.map((level, index) => (
            <Badge
              key={index}
              variant="outline"
              className="flex gap-2 items-center"
            >
              <div
                className={`w-2 h-2 rounded-full bg-${
                  index === 0
                    ? "slate"
                    : index === 1
                    ? "purple"
                    : index === 2
                    ? "indigo"
                    : index === 3
                    ? "violet"
                    : "fuchsia"
                }-500`}
              ></div>
              {level.name}: {level.value}
            </Badge>
          ))}
        </div>
      </CardFooter>
    </Card>
  );
};

const TrustScoreTrendChart = () => {
  return (
    <Card className="col-span-2">
      <CardHeader>
        <CardTitle>Trust Score Trends</CardTitle>
        <CardDescription>Average trust score over time</CardDescription>
      </CardHeader>
      <CardContent>
        <LineChart
          data={trustScoreTrend}
          index="date"
          categories={["average", "new", "returning"]}
          colors={["purple", "slate", "indigo"]}
          valueFormatter={(value) => `${value}`}
          yAxisWidth={40}
          className="h-80"
        />
      </CardContent>
      <CardFooter className="flex justify-between">
        <div className="flex gap-4">
          <Badge variant="outline" className="flex gap-2 items-center">
            <div className="w-2 h-2 rounded-full bg-purple-500"></div>
            Platform Average
          </Badge>
          <Badge variant="outline" className="flex gap-2 items-center">
            <div className="w-2 h-2 rounded-full bg-slate-500"></div>
            New Users
          </Badge>
          <Badge variant="outline" className="flex gap-2 items-center">
            <div className="w-2 h-2 rounded-full bg-indigo-500"></div>
            Returning Users
          </Badge>
        </div>
      </CardFooter>
    </Card>
  );
};

const ActionImpactChart = () => {
  return (
    <Card className="col-span-2">
      <CardHeader>
        <CardTitle>Action Impact Analysis</CardTitle>
        <CardDescription>
          How different actions affect trust scores
        </CardDescription>
      </CardHeader>
      <CardContent>
        <BarChart
          data={actionImpact}
          index="action"
          categories={["impact"]}
          colors={["purple"]}
          valueFormatter={(value) =>
            `${value > 0 ? "+" : ""}${value.toFixed(1)}`
          }
          yAxisWidth={48}
          className="h-80"
        />
      </CardContent>
      <CardFooter>
        <p className="text-sm text-muted-foreground">
          Positive values increase trust score, negative values decrease it
        </p>
      </CardFooter>
    </Card>
  );
};

const RegionalAnalysis = () => {
  return (
    <Card className="col-span-1">
      <CardHeader>
        <CardTitle>Regional Analysis</CardTitle>
        <CardDescription>Trust scores by geographic region</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {regionData.map((region, index) => (
            <div key={index} className="flex items-center justify-between">
              <div className="flex flex-col">
                <span className="text-sm font-medium">{region.region}</span>
                <span className="text-xs text-muted-foreground">
                  {region.users.toLocaleString()} users
                </span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-24 h-2 bg-gray-100 rounded-full">
                  <div
                    className="h-2 bg-purple-600 rounded-full"
                    style={{ width: `${region.average}%` }}
                  ></div>
                </div>
                <span className="text-sm font-medium">{region.average}</span>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
      <CardFooter>
        <Button variant="outline" size="sm" className="w-full">
          <Map className="mr-2 h-4 w-4" />
          View Full Map
        </Button>
      </CardFooter>
    </Card>
  );
};

const InsightCard = ({
  title,
  description,
  impact,
  icon,
}: {
  title: string;
  description: string;
  impact: string;
  icon: React.ReactNode;
}) => {
  return (
    <Card>
      <CardHeader className="flex flex-row items-start justify-between space-y-0">
        <div>
          <CardTitle className="text-base">{title}</CardTitle>
          <CardDescription className="mt-1">{description}</CardDescription>
        </div>
        {icon}
      </CardHeader>
      <CardFooter>
        <Badge
          variant={
            impact === "positive"
              ? "success"
              : impact === "negative"
              ? "destructive"
              : "outline"
          }
        >
          {impact === "positive"
            ? "Positive Impact"
            : impact === "negative"
            ? "Negative Impact"
            : "Neutral Impact"}
        </Badge>
      </CardFooter>
    </Card>
  );
};

const TrustInsights = () => {
  return (
    <Card className="col-span-3">
      <CardHeader>
        <CardTitle>Trust Score Insights</CardTitle>
        <CardDescription>
          Automatically generated insights based on trust score data
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          <InsightCard
            title="Content Creation Correlation"
            description="Users who upload at least 5 tracks have 68% higher trust scores on average"
            impact="positive"
            icon={<Activity className="h-4 w-4 text-purple-600" />}
          />
          <InsightCard
            title="Comment Quality Impact"
            description="Users with reported comments see a 23% drop in trust score within 30 days"
            impact="negative"
            icon={<AlertTriangle className="h-4 w-4 text-amber-600" />}
          />
          <InsightCard
            title="Trust Level Progression"
            description="Average time to reach 'Trusted' level has decreased by 12 days since last quarter"
            impact="positive"
            icon={<TrendingUp className="h-4 w-4 text-green-600" />}
          />
        </div>
      </CardContent>
    </Card>
  );
};

export default function TrustScoreAnalytics() {
  return (
    <div className="container mx-auto py-10">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Trust Score Analytics
          </h1>
          <p className="text-muted-foreground">
            Monitor and analyze trust metrics across the MusicWave platform
          </p>
        </div>
        <div className="flex items-center gap-4">
          <DatePickerWithRange className="w-[300px]" />
          <Button variant="outline" size="icon">
            <Filter className="h-4 w-4" />
          </Button>
          <Button variant="outline" size="icon">
            <Download className="h-4 w-4" />
          </Button>
        </div>
      </div>

      <Tabs defaultValue="overview" className="space-y-8">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="distribution">Distribution</TabsTrigger>
          <TabsTrigger value="trends">Trends</TabsTrigger>
          <TabsTrigger value="actions">Actions</TabsTrigger>
          <TabsTrigger value="insights">Insights</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-8">
          <TrustScoreOverview />

          <div className="grid gap-4 md:grid-cols-3">
            <TrustDistributionChart />
            <TrustScoreTrendChart />
          </div>

          <TrustInsights />
        </TabsContent>

        <TabsContent value="distribution" className="space-y-8">
          <div className="grid gap-4 md:grid-cols-2">
            <TrustDistributionChart />
            <RegionalAnalysis />
          </div>

          <Card>
            <CardHeader>
              <CardTitle>Trust Score Distribution</CardTitle>
              <CardDescription>
                Detailed breakdown of trust scores across the platform
              </CardDescription>
            </CardHeader>
            <CardContent>
              <BarChart
                data={[
                  { score: "0-10", users: 245 },
                  { score: "11-20", users: 1009 },
                  { score: "21-30", users: 1456 },
                  { score: "31-40", users: 1234 },
                  { score: "41-50", users: 1152 },
                  { score: "51-60", users: 987 },
                  { score: "61-70", users: 876 },
                  { score: "71-80", users: 654 },
                  { score: "81-90", users: 333 },
                  { score: "91-100", users: 99 },
                ]}
                index="score"
                categories={["users"]}
                colors={["purple"]}
                valueFormatter={(value) => value.toLocaleString()}
                yAxisWidth={48}
                className="h-80"
              />
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="trends" className="space-y-8">
          <TrustScoreTrendChart />

          <Card>
            <CardHeader>
              <CardTitle>Trust Level Transitions</CardTitle>
              <CardDescription>
                Movement between trust levels over time
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="h-80 flex items-center justify-center">
                <p className="text-muted-foreground">
                  Detailed transition visualization would be implemented here
                </p>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="actions" className="space-y-8">
          <ActionImpactChart />

          <Card>
            <CardHeader>
              <CardTitle>Action Volume Analysis</CardTitle>
              <CardDescription>
                Volume of trust-affecting actions over time
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="h-80 flex items-center justify-center">
                <p className="text-muted-foreground">
                  Detailed action volume visualization would be implemented here
                </p>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="insights" className="space-y-8">
          <TrustInsights />

          <Card>
            <CardHeader>
              <CardTitle>Trust Score Recommendations</CardTitle>
              <CardDescription>
                Platform-wide recommendations to improve trust scores
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-start gap-4">
                  <div className="bg-purple-100 p-2 rounded-full">
                    <Shield className="h-5 w-5 text-purple-600" />
                  </div>
                  <div>
                    <h4 className="text-sm font-medium">
                      Improve New User Onboarding
                    </h4>
                    <p className="text-sm text-muted-foreground mt-1">
                      New users have 42% lower trust scores. Implementing a
                      guided onboarding process could help users understand how
                      to build trust faster.
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="bg-purple-100 p-2 rounded-full">
                    <Users className="h-5 w-5 text-purple-600" />
                  </div>
                  <div>
                    <h4 className="text-sm font-medium">
                      Encourage Community Engagement
                    </h4>
                    <p className="text-sm text-muted-foreground mt-1">
                      Users who follow at least 10 other users have 37% higher
                      trust scores. Consider adding follow suggestions to
                      increase engagement.
                    </p>
                  </div>
                </div>

                <div className="flex items-start gap-4">
                  <div className="bg-purple-100 p-2 rounded-full">
                    <Activity className="h-5 w-5 text-purple-600" />
                  </div>
                  <div>
                    <h4 className="text-sm font-medium">
                      Highlight Trust Benefits
                    </h4>
                    <p className="text-sm text-muted-foreground mt-1">
                      Only 23% of users understand the benefits of higher trust
                      levels. Creating clearer documentation could improve
                      motivation.
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}

// Loading state component
export function Loading() {
  return (
    <div className="container mx-auto py-10 space-y-8">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div className="space-y-2">
          <Skeleton className="h-8 w-[250px]" />
          <Skeleton className="h-4 w-[350px]" />
        </div>
        <div className="flex items-center gap-4">
          <Skeleton className="h-10 w-[300px]" />
          <Skeleton className="h-10 w-10 rounded" />
          <Skeleton className="h-10 w-10 rounded" />
        </div>
      </div>

      <div className="space-y-2">
        <Skeleton className="h-10 w-[400px]" />
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {Array(4)
            .fill(0)
            .map((_, i) => (
              <Skeleton key={i} className="h-[150px] rounded-lg" />
            ))}
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <Skeleton className="h-[400px] rounded-lg" />
        <Skeleton className="h-[400px] rounded-lg md:col-span-2" />
      </div>

      <Skeleton className="h-[300px] rounded-lg" />
    </div>
  );
}
