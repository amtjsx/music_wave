"use client";

import {
  Calendar,
  ChevronDown,
  DollarSign,
  Download,
  Music,
  TrendingUp,
  Users,
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Progress } from "@/components/ui/progress";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { GeographicMap } from "./geographic-map";
import { RevenueChart } from "./revenue-chart";
import { StreamsChart } from "./streams-chart";

export default function EarningsDashboard() {
  const [timeframe, setTimeframe] = useState("month");

  return (
    <main className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Earnings Dashboard
          </h1>
          <p className="text-muted-foreground">
            Track your revenue, streams, and performance metrics
          </p>
        </div>
        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" className="flex items-center gap-2">
                <Calendar className="h-4 w-4" />
                {timeframe === "week" && "This Week"}
                {timeframe === "month" && "This Month"}
                {timeframe === "year" && "This Year"}
                <ChevronDown className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => setTimeframe("week")}>
                This Week
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => setTimeframe("month")}>
                This Month
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => setTimeframe("year")}>
                This Year
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
          <Button className="gap-2 bg-purple-600 hover:bg-purple-700">
            <Download className="h-4 w-4" /> Export
          </Button>
        </div>
      </div>

      {/* Overview Cards */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Total Earnings
            </CardTitle>
            <DollarSign className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">$12,546.78</div>
            <p className="text-xs text-muted-foreground">
              +18.2% from last {timeframe}
            </p>
            <div className="mt-4 h-1 w-full bg-muted">
              <div className="h-1 w-3/4 bg-purple-600" />
            </div>
            <p className="mt-1 text-xs text-muted-foreground">
              75% of your goal
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Streams</CardTitle>
            <Music className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">2.4M</div>
            <p className="text-xs text-muted-foreground">
              +24.5% from last {timeframe}
            </p>
            <div className="mt-4 flex items-center gap-2">
              <Badge
                variant="outline"
                className="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-100"
              >
                Spotify: 1.2M
              </Badge>
              <Badge
                variant="outline"
                className="bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-100"
              >
                Apple: 850K
              </Badge>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Listeners</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">482.5K</div>
            <p className="text-xs text-muted-foreground">
              +12.3% from last {timeframe}
            </p>
            <div className="mt-4 flex items-center gap-1">
              <div className="flex -space-x-2">
                <Avatar className="h-6 w-6 border-2 border-background">
                  <AvatarFallback>US</AvatarFallback>
                </Avatar>
                <Avatar className="h-6 w-6 border-2 border-background">
                  <AvatarFallback>UK</AvatarFallback>
                </Avatar>
                <Avatar className="h-6 w-6 border-2 border-background">
                  <AvatarFallback>DE</AvatarFallback>
                </Avatar>
              </div>
              <span className="text-xs text-muted-foreground">
                +12 countries
              </span>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Growth Rate</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">+22.4%</div>
            <p className="text-xs text-muted-foreground">
              +4.1% from last {timeframe}
            </p>
            <div className="mt-4">
              <Badge className="bg-purple-600">Trending Artist</Badge>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="lg:col-span-4">
          <CardHeader>
            <CardTitle>Revenue Overview</CardTitle>
            <CardDescription>Your earnings breakdown over time</CardDescription>
          </CardHeader>
          <CardContent className="px-2">
            <RevenueChart timeframe={timeframe} />
          </CardContent>
        </Card>
        <Card className="lg:col-span-3">
          <CardHeader>
            <CardTitle>Streams by Platform</CardTitle>
            <CardDescription>
              Distribution across streaming services
            </CardDescription>
          </CardHeader>
          <CardContent className="px-2">
            <StreamsChart />
          </CardContent>
        </Card>
      </div>

      {/* Top Tracks & Geographic Distribution */}
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
        <Card className="lg:col-span-3">
          <CardHeader>
            <CardTitle>Top Performing Tracks</CardTitle>
            <CardDescription>
              Your most streamed songs this {timeframe}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Track</TableHead>
                  <TableHead className="text-right">Streams</TableHead>
                  <TableHead className="text-right">Revenue</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                <TableRow>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-2">
                      <div className="h-8 w-8 rounded bg-purple-100 dark:bg-purple-900" />
                      <div>
                        <div className="font-medium">Midnight Dreams</div>
                        <div className="text-xs text-muted-foreground">
                          Album: Echoes
                        </div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="text-right">845.2K</TableCell>
                  <TableCell className="text-right">$3,380.80</TableCell>
                </TableRow>
                <TableRow>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-2">
                      <div className="h-8 w-8 rounded bg-blue-100 dark:bg-blue-900" />
                      <div>
                        <div className="font-medium">Ocean Waves</div>
                        <div className="text-xs text-muted-foreground">
                          Album: Echoes
                        </div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="text-right">632.7K</TableCell>
                  <TableCell className="text-right">$2,530.80</TableCell>
                </TableRow>
                <TableRow>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-2">
                      <div className="h-8 w-8 rounded bg-green-100 dark:bg-green-900" />
                      <div>
                        <div className="font-medium">Starlight</div>
                        <div className="text-xs text-muted-foreground">
                          Album: Cosmos
                        </div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="text-right">521.3K</TableCell>
                  <TableCell className="text-right">$2,085.20</TableCell>
                </TableRow>
                <TableRow>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-2">
                      <div className="h-8 w-8 rounded bg-orange-100 dark:bg-orange-900" />
                      <div>
                        <div className="font-medium">Electric Soul</div>
                        <div className="text-xs text-muted-foreground">
                          Album: Voltage
                        </div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="text-right">412.8K</TableCell>
                  <TableCell className="text-right">$1,651.20</TableCell>
                </TableRow>
                <TableRow>
                  <TableCell className="font-medium">
                    <div className="flex items-center gap-2">
                      <div className="h-8 w-8 rounded bg-red-100 dark:bg-red-900" />
                      <div>
                        <div className="font-medium">Neon Lights</div>
                        <div className="text-xs text-muted-foreground">
                          Album: Voltage
                        </div>
                      </div>
                    </div>
                  </TableCell>
                  <TableCell className="text-right">387.5K</TableCell>
                  <TableCell className="text-right">$1,550.00</TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </CardContent>
        </Card>
        <Card className="lg:col-span-4">
          <CardHeader>
            <CardTitle>Geographic Distribution</CardTitle>
            <CardDescription>Where your listeners are located</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full">
              <GeographicMap />
            </div>
            <div className="mt-4 space-y-2">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="h-3 w-3 rounded-full bg-purple-600" />
                  <span className="text-sm">United States</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">42%</span>
                  <Progress value={42} className="h-2 w-20" />
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="h-3 w-3 rounded-full bg-blue-600" />
                  <span className="text-sm">United Kingdom</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">18%</span>
                  <Progress value={18} className="h-2 w-20" />
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="h-3 w-3 rounded-full bg-green-600" />
                  <span className="text-sm">Germany</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">12%</span>
                  <Progress value={12} className="h-2 w-20" />
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="h-3 w-3 rounded-full bg-orange-600" />
                  <span className="text-sm">Canada</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">8%</span>
                  <Progress value={8} className="h-2 w-20" />
                </div>
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="h-3 w-3 rounded-full bg-gray-600" />
                  <span className="text-sm">Other</span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-sm font-medium">20%</span>
                  <Progress value={20} className="h-2 w-20" />
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Payment History */}
      <Card>
        <CardHeader>
          <CardTitle>Payment History</CardTitle>
          <CardDescription>
            Your recent payments and transactions
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Date</TableHead>
                <TableHead>Description</TableHead>
                <TableHead>Type</TableHead>
                <TableHead className="text-right">Amount</TableHead>
                <TableHead className="text-right">Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow>
                <TableCell>May 15, 2025</TableCell>
                <TableCell>April 2025 Royalty Payment</TableCell>
                <TableCell>Streaming Royalties</TableCell>
                <TableCell className="text-right">$3,245.67</TableCell>
                <TableCell className="text-right">
                  <Badge className="bg-green-600">Completed</Badge>
                </TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Apr 15, 2025</TableCell>
                <TableCell>March 2025 Royalty Payment</TableCell>
                <TableCell>Streaming Royalties</TableCell>
                <TableCell className="text-right">$2,987.32</TableCell>
                <TableCell className="text-right">
                  <Badge className="bg-green-600">Completed</Badge>
                </TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Mar 15, 2025</TableCell>
                <TableCell>February 2025 Royalty Payment</TableCell>
                <TableCell>Streaming Royalties</TableCell>
                <TableCell className="text-right">$3,102.45</TableCell>
                <TableCell className="text-right">
                  <Badge className="bg-green-600">Completed</Badge>
                </TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Feb 15, 2025</TableCell>
                <TableCell>January 2025 Royalty Payment</TableCell>
                <TableCell>Streaming Royalties</TableCell>
                <TableCell className="text-right">$2,756.89</TableCell>
                <TableCell className="text-right">
                  <Badge className="bg-green-600">Completed</Badge>
                </TableCell>
              </TableRow>
              <TableRow>
                <TableCell>Jan 15, 2025</TableCell>
                <TableCell>December 2024 Royalty Payment</TableCell>
                <TableCell>Streaming Royalties</TableCell>
                <TableCell className="text-right">$3,521.78</TableCell>
                <TableCell className="text-right">
                  <Badge className="bg-green-600">Completed</Badge>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </main>
  );
}
