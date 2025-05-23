import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { AlertTriangle, Clock, Flag, MessageSquare, Music, UserCheck } from "lucide-react"
import React from "react"
import {
    getTrustLevel,
    getTrustLevelColor,
    getTrustLevelDescription,
    getTrustLevelIcon,
    getTrustLevelLabel,
    type TrustLevel,
} from "./trust-score-badge"

interface TrustScoreCardProps {
  userId: string
  username: string
  score: number
  accountAge: number // in days
  factors: {
    comments: {
      count: number
      likes: number
      reports: number
    }
    content: {
      tracks: number
      playlists: number
    }
    community: {
      followers: number
      following: number
      shares: number
    }
    moderation: {
      validReports: number
      warnings: number
    }
  }
  history: Array<{
    date: string
    score: number
    change: number
    reason: string
  }>
}

export function TrustScoreCard({ userId, username, score, accountAge, factors, history }: TrustScoreCardProps) {
  const level = getTrustLevel(score)
  const label = getTrustLevelLabel(level)
  const color = getTrustLevelColor(level)
  const description = getTrustLevelDescription(level)

  // Calculate next level threshold
  const getNextLevelThreshold = (currentLevel: TrustLevel): number => {
    switch (currentLevel) {
      case "new":
        return 20
      case "basic":
        return 50
      case "trusted":
        return 75
      case "core":
        return 90
      case "exceptional":
        return 100
    }
  }

  const nextThreshold = getNextLevelThreshold(level)
  const prevThreshold =
    level === "new"
      ? 0
      : getNextLevelThreshold(
          level === "basic" ? "new" : level === "trusted" ? "basic" : level === "core" ? "trusted" : "core",
        )

  const progressToNextLevel = Math.round(((score - prevThreshold) / (nextThreshold - prevThreshold)) * 100)

  // Get next level if not already at max
  const nextLevel =
    level === "exceptional"
      ? null
      : getTrustLevelLabel(
          level === "new" ? "basic" : level === "basic" ? "trusted" : level === "trusted" ? "core" : "exceptional",
        )

  return (
    <Card className="w-full">
      <CardHeader>
        <div className="flex items-center justify-between">
          <div>
            <CardTitle className="text-xl flex items-center gap-2">
              Trust Score
              <span className={cn("font-bold", color)}>{score}</span>
            </CardTitle>
            <CardDescription>User reputation based on platform activity and behavior</CardDescription>
          </div>
          <div className="flex items-center gap-2">
            {getTrustLevelIcon(level, "h-6 w-6 " + color)}
            <span className={cn("font-semibold", color)}>{label}</span>
          </div>
        </div>
      </CardHeader>
      <CardContent className="space-y-6">
        {/* Progress to next level */}
        {level !== "exceptional" && (
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span>Progress to {nextLevel}</span>
              <span>{progressToNextLevel}%</span>
            </div>
            <Progress value={progressToNextLevel} className="h-2" />
            <p className="text-sm text-muted-foreground">
              {nextThreshold - score} more points needed to reach {nextLevel}
            </p>
          </div>
        )}

        <Tabs defaultValue="factors">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="factors">Score Factors</TabsTrigger>
            <TabsTrigger value="history">Score History</TabsTrigger>
            <TabsTrigger value="benefits">Level Benefits</TabsTrigger>
          </TabsList>

          <TabsContent value="factors" className="space-y-4 pt-4">
            <div className="grid grid-cols-2 gap-4">
              <ScoreFactorCard
                title="Account Age"
                icon={<Clock className="h-4 w-4" />}
                value={`${accountAge} days`}
                impact="positive"
                description="Older accounts gain trust over time"
              />

              <ScoreFactorCard
                title="Content Creation"
                icon={<Music className="h-4 w-4" />}
                value={`${factors.content.tracks} tracks, ${factors.content.playlists} playlists`}
                impact="positive"
                description="Creating quality content increases trust"
              />

              <ScoreFactorCard
                title="Comments"
                icon={<MessageSquare className="h-4 w-4" />}
                value={`${factors.comments.count} (${factors.comments.likes} likes)`}
                impact={factors.comments.reports > 5 ? "negative" : "positive"}
                description={`${factors.comments.reports} reports received`}
              />

              <ScoreFactorCard
                title="Community"
                icon={<UserCheck className="h-4 w-4" />}
                value={`${factors.community.followers} followers`}
                impact="positive"
                description={`Following ${factors.community.following} users, ${factors.community.shares} shares`}
              />

              <ScoreFactorCard
                title="Reporting"
                icon={<Flag className="h-4 w-4" />}
                value={`${factors.moderation.validReports} valid reports`}
                impact="positive"
                description="Helping keep the community safe"
              />

              <ScoreFactorCard
                title="Warnings"
                icon={<AlertTriangle className="h-4 w-4" />}
                value={`${factors.moderation.warnings} received`}
                impact={factors.moderation.warnings > 0 ? "negative" : "neutral"}
                description="Moderation actions against this user"
              />
            </div>
          </TabsContent>

          <TabsContent value="history" className="pt-4">
            <div className="space-y-4">
              {history.map((entry, i) => (
                <div key={i} className="flex items-center justify-between border-b pb-2">
                  <div>
                    <p className="font-medium">{entry.reason}</p>
                    <p className="text-sm text-muted-foreground">{entry.date}</p>
                  </div>
                  <div className={cn("font-semibold", entry.change > 0 ? "text-green-500" : "text-red-500")}>
                    {entry.change > 0 ? "+" : ""}
                    {entry.change}
                  </div>
                </div>
              ))}
            </div>
          </TabsContent>

          <TabsContent value="benefits" className="pt-4">
            <div className="space-y-4">
              <BenefitItem
                level="new"
                benefits={["Basic commenting privileges", "Limited track uploads", "Standard playback features"]}
                currentLevel={level}
              />

              <BenefitItem
                level="basic"
                benefits={["Increased upload limits", "Ability to create playlists", "Comment with links"]}
                currentLevel={level}
              />

              <BenefitItem
                level="trusted"
                benefits={[
                  "Comments appear without delay",
                  "Higher visibility in recommendations",
                  "Access to beta features",
                  "Reduced reporting threshold",
                ]}
                currentLevel={level}
              />

              <BenefitItem
                level="core"
                benefits={[
                  "Comments highlighted in discussions",
                  "Priority support",
                  "Eligible for community moderator",
                  "Special profile customization",
                ]}
                currentLevel={level}
              />

              <BenefitItem
                level="exceptional"
                benefits={[
                  "Featured artist opportunities",
                  "Influence on platform features",
                  "Exclusive community events",
                  "Special recognition badges",
                ]}
                currentLevel={level}
              />
            </div>
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  )
}

interface ScoreFactorCardProps {
  title: string
  icon: React.ReactNode
  value: string
  impact: "positive" | "negative" | "neutral"
  description: string
}

function ScoreFactorCard({ title, icon, value, impact, description }: ScoreFactorCardProps) {
  return (
    <div className="rounded-lg border p-3 flex flex-col">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          {icon}
          <span className="font-medium">{title}</span>
        </div>
        <div
          className={cn(
            "text-xs px-2 py-0.5 rounded-full",
            impact === "positive"
              ? "bg-green-100 text-green-700"
              : impact === "negative"
                ? "bg-red-100 text-red-700"
                : "bg-slate-100 text-slate-700",
          )}
        >
          {impact === "positive" ? "Positive" : impact === "negative" ? "Negative" : "Neutral"}
        </div>
      </div>
      <div className="mt-2">
        <p className="font-semibold">{value}</p>
        <p className="text-xs text-muted-foreground">{description}</p>
      </div>
    </div>
  )
}

interface BenefitItemProps {
  level: TrustLevel
  benefits: string[]
  currentLevel: TrustLevel
}

function BenefitItem({ level, benefits, currentLevel }: BenefitItemProps) {
  const levelValue = {
    new: 0,
    basic: 1,
    trusted: 2,
    core: 3,
    exceptional: 4,
  }

  const isUnlocked = levelValue[currentLevel] >= levelValue[level]
  const label = getTrustLevelLabel(level)
  const color = getTrustLevelColor(level)

  return (
    <div className={cn("rounded-lg border p-3", isUnlocked ? "border-green-200 bg-green-50" : "opacity-70")}>
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          {getTrustLevelIcon(level, "h-4 w-4 " + color)}
          <span className={cn("font-medium", color)}>{label}</span>
        </div>
        {isUnlocked ? (
          <div className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full">Unlocked</div>
        ) : (
          <div className="text-xs bg-slate-100 text-slate-700 px-2 py-0.5 rounded-full">Locked</div>
        )}
      </div>
      <div className="mt-2 space-y-1">
        <ul className="text-sm space-y-1">
          {benefits.map((benefit, i) => (
            <li key={i} className="flex items-start gap-2">
              <div className={cn("mt-0.5 h-2 w-2 rounded-full", isUnlocked ? "bg-green-500" : "bg-slate-300")} />
              <span>{benefit}</span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}

function cn(...classes: any[]) {
  return classes.filter(Boolean).join(" ")
}
