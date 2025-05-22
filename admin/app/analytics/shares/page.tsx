"use client";

import {
    Download,
    Facebook,
    Filter,
    Instagram,
    LinkIcon,
    Music,
    RefreshCw,
    Share,
    TrendingUp,
    Twitter,
    Users,
} from "lucide-react";
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
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from "@/components/ui/table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { DatePickerWithRange } from "./date-range-picker";
import { PlatformDistributionChart } from "./platform-distribution-chart";
import { ShareGrowthChart } from "./share-growth-chart";
import { ShareMetricsChart } from "./share-metrics-chart";

export default function ShareAnalysisPage() {
  const [isLoading, setIsLoading] = useState(false);

  const refreshData = () => {
    setIsLoading(true);
    // Simulate API call
    setTimeout(() => {
      setIsLoading(false);
    }, 1000);
  };

  return (
    <div className="flex flex-col gap-6 p-4 md:p-8">
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-bold tracking-tight">Share Analysis</h1>
        <p className="text-muted-foreground">
          Track and analyze how users are sharing content across platforms.
        </p>
      </div>

      {/* Dashboard Controls */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <DatePickerWithRange />
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" size="sm" className="h-8 gap-1">
            <Filter className="h-3.5 w-3.5" />
            <span>Filter</span>
          </Button>
          <Button
            variant="outline"
            size="sm"
            className="h-8 gap-1"
            onClick={refreshData}
            disabled={isLoading}
          >
            <RefreshCw
              className={`h-3.5 w-3.5 ${isLoading ? "animate-spin" : ""}`}
            />
            <span>{isLoading ? "Refreshing..." : "Refresh"}</span>
          </Button>
          <Button variant="outline" size="sm" className="h-8 gap-1">
            <Download className="h-3.5 w-3.5" />
            <span>Export</span>
          </Button>
          <Select defaultValue="all">
            <SelectTrigger className="h-8 w-[130px]">
              <SelectValue placeholder="Platform" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Platforms</SelectItem>
              <SelectItem value="facebook">Facebook</SelectItem>
              <SelectItem value="twitter">Twitter</SelectItem>
              <SelectItem value="instagram">Instagram</SelectItem>
              <SelectItem value="direct">Direct Link</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* Overview Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">Total Shares</CardTitle>
            <Share className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">24,781</div>
            <p className="text-xs text-muted-foreground">
              +12.4% from last month
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">
              Share Conversion
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">8.7%</div>
            <p className="text-xs text-muted-foreground">
              +1.2% from last month
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">
              Shares per User
            </CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">3.6</div>
            <p className="text-xs text-muted-foreground">
              +0.8 from last month
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium">
              Most Shared Platform
            </CardTitle>
            <Twitter className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">Twitter</div>
            <p className="text-xs text-muted-foreground">42% of total shares</p>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="platforms">Platforms</TabsTrigger>
          <TabsTrigger value="content">Content</TabsTrigger>
          <TabsTrigger value="growth">Growth</TabsTrigger>
        </TabsList>
        <TabsContent value="overview" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
            <Card className="lg:col-span-4">
              <CardHeader>
                <CardTitle>Share Metrics</CardTitle>
                <CardDescription>
                  Daily share activity over the last 30 days
                </CardDescription>
              </CardHeader>
              <CardContent className="pl-2">
                <ShareMetricsChart />
              </CardContent>
            </Card>
            <Card className="lg:col-span-3">
              <CardHeader>
                <CardTitle>Platform Distribution</CardTitle>
                <CardDescription>
                  Share distribution across platforms
                </CardDescription>
              </CardHeader>
              <CardContent>
                <PlatformDistributionChart />
              </CardContent>
            </Card>
          </div>
        </TabsContent>
        <TabsContent value="platforms" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Platform Performance</CardTitle>
              <CardDescription>
                Compare share metrics across different platforms
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                {/* Platform cards */}
                <div className="flex items-center gap-4 rounded-lg border p-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-blue-100 text-blue-600 dark:bg-blue-900 dark:text-blue-200">
                    <Facebook className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm font-medium">Facebook</p>
                    <p className="text-2xl font-bold">5,283</p>
                    <p className="text-xs text-muted-foreground">
                      21.3% of shares
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4 rounded-lg border p-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-sky-100 text-sky-600 dark:bg-sky-900 dark:text-sky-200">
                    <Twitter className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm font-medium">Twitter</p>
                    <p className="text-2xl font-bold">10,408</p>
                    <p className="text-xs text-muted-foreground">
                      42.0% of shares
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4 rounded-lg border p-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-pink-100 text-pink-600 dark:bg-pink-900 dark:text-pink-200">
                    <Instagram className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm font-medium">Instagram</p>
                    <p className="text-2xl font-bold">4,652</p>
                    <p className="text-xs text-muted-foreground">
                      18.8% of shares
                    </p>
                  </div>
                </div>
                <div className="flex items-center gap-4 rounded-lg border p-4">
                  <div className="flex h-12 w-12 items-center justify-center rounded-full bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-200">
                    <LinkIcon className="h-6 w-6" />
                  </div>
                  <div>
                    <p className="text-sm font-medium">Direct Link</p>
                    <p className="text-2xl font-bold">4,438</p>
                    <p className="text-xs text-muted-foreground">
                      17.9% of shares
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
        <TabsContent value="content" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Most Shared Content</CardTitle>
              <CardDescription>
                Top tracks and playlists being shared by users
              </CardDescription>
            </CardHeader>
            <CardContent>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Content</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Shares</TableHead>
                    <TableHead>Top Platform</TableHead>
                    <TableHead>Trend</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  <TableRow>
                    <TableCell className="font-medium">
                      <div className="flex items-center gap-2">
                        <div className="h-8 w-8 rounded bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                          <Music className="h-4 w-4 text-purple-600 dark:text-purple-300" />
                        </div>
                        <div>
                          <p className="font-medium">Summer Vibes</p>
                          <p className="text-xs text-muted-foreground">
                            by MusicWave Editorial
                          </p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">Playlist</Badge>
                    </TableCell>
                    <TableCell>2,845</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Twitter className="h-3.5 w-3.5 text-sky-500" />
                        <span>Twitter</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className="bg-green-500">+24%</Badge>
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell className="font-medium">
                      <div className="flex items-center gap-2">
                        <div className="h-8 w-8 rounded bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                          <Music className="h-4 w-4 text-purple-600 dark:text-purple-300" />
                        </div>
                        <div>
                          <p className="font-medium">Midnight Dreams</p>
                          <p className="text-xs text-muted-foreground">
                            by Luna Sky
                          </p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">Track</Badge>
                    </TableCell>
                    <TableCell>1,932</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Instagram className="h-3.5 w-3.5 text-pink-500" />
                        <span>Instagram</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className="bg-green-500">+18%</Badge>
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell className="font-medium">
                      <div className="flex items-center gap-2">
                        <div className="h-8 w-8 rounded bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                          <Music className="h-4 w-4 text-purple-600 dark:text-purple-300" />
                        </div>
                        <div>
                          <p className="font-medium">Workout Essentials</p>
                          <p className="text-xs text-muted-foreground">
                            by FitBeats
                          </p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">Playlist</Badge>
                    </TableCell>
                    <TableCell>1,756</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Facebook className="h-3.5 w-3.5 text-blue-500" />
                        <span>Facebook</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className="bg-green-500">+12%</Badge>
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell className="font-medium">
                      <div className="flex items-center gap-2">
                        <div className="h-8 w-8 rounded bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                          <Music className="h-4 w-4 text-purple-600 dark:text-purple-300" />
                        </div>
                        <div>
                          <p className="font-medium">Electric Dreams</p>
                          <p className="text-xs text-muted-foreground">
                            by Neon Pulse
                          </p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">Album</Badge>
                    </TableCell>
                    <TableCell>1,543</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <Twitter className="h-3.5 w-3.5 text-sky-500" />
                        <span>Twitter</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className="bg-amber-500">+5%</Badge>
                    </TableCell>
                  </TableRow>
                  <TableRow>
                    <TableCell className="font-medium">
                      <div className="flex items-center gap-2">
                        <div className="h-8 w-8 rounded bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                          <Music className="h-4 w-4 text-purple-600 dark:text-purple-300" />
                        </div>
                        <div>
                          <p className="font-medium">Acoustic Sessions</p>
                          <p className="text-xs text-muted-foreground">
                            by Harmony Collective
                          </p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">Playlist</Badge>
                    </TableCell>
                    <TableCell>1,287</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-1">
                        <LinkIcon className="h-3.5 w-3.5 text-gray-500" />
                        <span>Direct</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge className="bg-red-500">-3%</Badge>
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </CardContent>
            <CardFooter>
              <Button variant="outline" size="sm" className="ml-auto">
                View All
              </Button>
            </CardFooter>
          </Card>
        </TabsContent>
        <TabsContent value="growth" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Share Growth</CardTitle>
              <CardDescription>
                Monthly share growth over the past year
              </CardDescription>
            </CardHeader>
            <CardContent className="pl-2">
              <ShareGrowthChart />
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Share Activity</CardTitle>
          <CardDescription>
            Latest user sharing activity across platforms
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>User</TableHead>
                <TableHead>Content</TableHead>
                <TableHead>Platform</TableHead>
                <TableHead>Time</TableHead>
                <TableHead>Clicks</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-full bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                      <span className="text-xs font-medium text-purple-600 dark:text-purple-300">
                        JD
                      </span>
                    </div>
                    <div>
                      <p className="font-medium">John Doe</p>
                      <p className="text-xs text-muted-foreground">Premium</p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>Summer Vibes (Playlist)</TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    <Twitter className="h-3.5 w-3.5 text-sky-500" />
                    <span>Twitter</span>
                  </div>
                </TableCell>
                <TableCell>5 minutes ago</TableCell>
                <TableCell>12</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-full bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                      <span className="text-xs font-medium text-purple-600 dark:text-purple-300">
                        AS
                      </span>
                    </div>
                    <div>
                      <p className="font-medium">Alice Smith</p>
                      <p className="text-xs text-muted-foreground">Free</p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>Midnight Dreams (Track)</TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    <Instagram className="h-3.5 w-3.5 text-pink-500" />
                    <span>Instagram</span>
                  </div>
                </TableCell>
                <TableCell>12 minutes ago</TableCell>
                <TableCell>8</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-full bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                      <span className="text-xs font-medium text-purple-600 dark:text-purple-300">
                        RJ
                      </span>
                    </div>
                    <div>
                      <p className="font-medium">Robert Johnson</p>
                      <p className="text-xs text-muted-foreground">Premium</p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>Workout Essentials (Playlist)</TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    <Facebook className="h-3.5 w-3.5 text-blue-500" />
                    <span>Facebook</span>
                  </div>
                </TableCell>
                <TableCell>28 minutes ago</TableCell>
                <TableCell>24</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-full bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                      <span className="text-xs font-medium text-purple-600 dark:text-purple-300">
                        EW
                      </span>
                    </div>
                    <div>
                      <p className="font-medium">Emma Wilson</p>
                      <p className="text-xs text-muted-foreground">Premium</p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>Electric Dreams (Album)</TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    <LinkIcon className="h-3.5 w-3.5 text-gray-500" />
                    <span>Direct</span>
                  </div>
                </TableCell>
                <TableCell>45 minutes ago</TableCell>
                <TableCell>6</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <div className="h-8 w-8 rounded-full bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                      <span className="text-xs font-medium text-purple-600 dark:text-purple-300">
                        MB
                      </span>
                    </div>
                    <div>
                      <p className="font-medium">Michael Brown</p>
                      <p className="text-xs text-muted-foreground">Free</p>
                    </div>
                  </div>
                </TableCell>
                <TableCell>Acoustic Sessions (Playlist)</TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    <Twitter className="h-3.5 w-3.5 text-sky-500" />
                    <span>Twitter</span>
                  </div>
                </TableCell>
                <TableCell>1 hour ago</TableCell>
                <TableCell>18</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </CardContent>
        <CardFooter>
          <Button variant="outline" size="sm" className="ml-auto">
            View All Activity
          </Button>
        </CardFooter>
      </Card>
    </div>
  );
}
