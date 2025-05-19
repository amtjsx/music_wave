"use client";

import {
  BarChart3,
  Calendar,
  Download,
  Play,
  TrendingUp,
  Users,
} from "lucide-react";
import { useState } from "react";

import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useTranslation } from "@/hooks/use-translation";

export default function ArtistAnalyticsPage() {
  const { t } = useTranslation("common");
  const [timeRange, setTimeRange] = useState("30days");
  const [activeTab, setActiveTab] = useState("overview");

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            {t("artist.analytics")}
          </h1>
          <p className="text-muted-foreground">
            {t("artist.analyticsDescription")}
          </p>
        </div>
        <Button variant="outline">
          <Download className="mr-2 h-4 w-4" />
          {t("artist.exportData")}
        </Button>
      </div>

      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <Tabs
          defaultValue="overview"
          value={activeTab}
          onValueChange={setActiveTab}
          className="w-full max-w-md"
        >
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="overview">{t("artist.overview")}</TabsTrigger>
            <TabsTrigger value="audience">{t("artist.audience")}</TabsTrigger>
            <TabsTrigger value="tracks">{t("artist.tracks")}</TabsTrigger>
          </TabsList>
        </Tabs>
        <Select value={timeRange} onValueChange={setTimeRange}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder={t("artist.selectTimeRange")} />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="7days">{t("artist.last7Days")}</SelectItem>
            <SelectItem value="30days">{t("artist.last30Days")}</SelectItem>
            <SelectItem value="90days">{t("artist.last90Days")}</SelectItem>
            <SelectItem value="year">{t("artist.lastYear")}</SelectItem>
            <SelectItem value="alltime">{t("artist.allTime")}</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <TabsContent value="overview" className="mt-0 space-y-6">
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {t("artist.totalPlays")}
              </CardTitle>
              <Play className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">45,231</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="mr-1 h-3 w-3 text-green-500" />
                <span className="text-green-500">+12.5%</span>
                <span className="ml-1">{t("artist.fromPrevious")}</span>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {t("artist.uniqueListeners")}
              </CardTitle>
              <Users className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">18,614</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="mr-1 h-3 w-3 text-green-500" />
                <span className="text-green-500">+8.2%</span>
                <span className="ml-1">{t("artist.fromPrevious")}</span>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {t("artist.newFollowers")}
              </CardTitle>
              <Users className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">1,352</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="mr-1 h-3 w-3 text-green-500" />
                <span className="text-green-500">+15.3%</span>
                <span className="ml-1">{t("artist.fromPrevious")}</span>
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">
                {t("artist.avgDailyPlays")}
              </CardTitle>
              <Calendar className="h-4 w-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">1,508</div>
              <div className="flex items-center text-xs text-muted-foreground">
                <TrendingUp className="mr-1 h-3 w-3 text-green-500" />
                <span className="text-green-500">+5.7%</span>
                <span className="ml-1">{t("artist.fromPrevious")}</span>
              </div>
            </CardContent>
          </Card>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>{t("artist.playsOverTime")}</CardTitle>
            <CardDescription>
              {t("artist.playsOverTimeDescription")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-[300px] w-full rounded-md bg-muted flex items-center justify-center">
              <BarChart3 className="h-16 w-16 text-muted-foreground/50" />
            </div>
          </CardContent>
        </Card>

        <div className="grid gap-4 md:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>{t("artist.topTracks")}</CardTitle>
              <CardDescription>
                {t("artist.topTracksDescription")}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {[1, 2, 3, 4, 5].map((i) => (
                  <div key={i} className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <div className="text-muted-foreground">{i}.</div>
                      <div>
                        <div className="font-medium">Track Title {i}</div>
                        <div className="text-sm text-muted-foreground">
                          Album Name
                        </div>
                      </div>
                    </div>
                    <div className="text-sm text-muted-foreground">
                      {Math.floor(
                        Math.random() * 10000 + 5000
                      ).toLocaleString()}{" "}
                      plays
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader>
              <CardTitle>{t("artist.geographicDistribution")}</CardTitle>
              <CardDescription>
                {t("artist.geographicDistributionDescription")}
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {[
                  "United States",
                  "United Kingdom",
                  "Germany",
                  "Canada",
                  "Australia",
                ].map((country, i) => (
                  <div key={i} className="flex items-center justify-between">
                    <div>{country}</div>
                    <div className="text-sm text-muted-foreground">
                      {Math.floor(Math.random() * 30 + 10)}%
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      </TabsContent>

      <TabsContent value="audience" className="mt-0">
        <Card>
          <CardHeader>
            <CardTitle>{t("artist.audienceInsights")}</CardTitle>
            <CardDescription>
              {t("artist.audienceInsightsDescription")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-[400px] w-full rounded-md bg-muted flex items-center justify-center">
              <Users className="h-16 w-16 text-muted-foreground/50" />
            </div>
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="tracks" className="mt-0">
        <Card>
          <CardHeader>
            <CardTitle>{t("artist.trackPerformance")}</CardTitle>
            <CardDescription>
              {t("artist.trackPerformanceDescription")}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-[400px] w-full rounded-md bg-muted flex items-center justify-center">
              <BarChart3 className="h-16 w-16 text-muted-foreground/50" />
            </div>
          </CardContent>
        </Card>
      </TabsContent>
    </div>
  );
}
