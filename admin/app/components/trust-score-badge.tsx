import { cn } from "@/lib/utils";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { Shield, ShieldCheck, ShieldAlert, ShieldQuestion } from "lucide-react";

export type TrustLevel = "new" | "basic" | "trusted" | "core" | "exceptional";

interface TrustScoreBadgeProps {
  score: number;
  size?: "sm" | "md" | "lg";
  showLabel?: boolean;
  className?: string;
}

export function getTrustLevel(score: number): TrustLevel {
  if (score < 20) return "new";
  if (score < 50) return "basic";
  if (score < 75) return "trusted";
  if (score < 90) return "core";
  return "exceptional";
}

export function getTrustLevelLabel(level: TrustLevel): string {
  switch (level) {
    case "new":
      return "New User";
    case "basic":
      return "Basic User";
    case "trusted":
      return "Trusted User";
    case "core":
      return "Core Member";
    case "exceptional":
      return "Exceptional Member";
  }
}

export function getTrustLevelColor(level: TrustLevel): string {
  switch (level) {
    case "new":
      return "text-slate-400";
    case "basic":
      return "text-blue-500";
    case "trusted":
      return "text-green-500";
    case "core":
      return "text-purple-500";
    case "exceptional":
      return "text-amber-500";
  }
}

export function getTrustLevelDescription(level: TrustLevel): string {
  switch (level) {
    case "new":
      return "Recently joined or has limited activity. Building reputation.";
    case "basic":
      return "Regular user with consistent positive behavior.";
    case "trusted":
      return "Established member with significant positive contributions.";
    case "core":
      return "Highly valued community member with exceptional track record.";
    case "exceptional":
      return "Outstanding community member with exemplary contributions and behavior.";
  }
}

export function getTrustLevelIcon(level: TrustLevel, className?: string) {
  const baseClass = cn("inline-block", className);

  switch (level) {
    case "new":
      return <ShieldQuestion className={baseClass} />;
    case "basic":
      return <Shield className={baseClass} />;
    case "trusted":
      return <ShieldCheck className={baseClass} />;
    case "core":
      return <ShieldCheck className={baseClass} />;
    case "exceptional":
      return <ShieldAlert className={baseClass} />;
  }
}

export function TrustScoreBadge({
  score,
  size = "md",
  showLabel = false,
  className,
}: TrustScoreBadgeProps) {
  const level = getTrustLevel(score);
  const label = getTrustLevelLabel(level);
  const color = getTrustLevelColor(level);
  const description = getTrustLevelDescription(level);

  const sizeClasses = {
    sm: "text-xs",
    md: "text-sm",
    lg: "text-base",
  };

  const iconSizes = {
    sm: "h-3.5 w-3.5",
    md: "h-4 w-4",
    lg: "h-5 w-5",
  };

  return (
    <TooltipProvider>
      <Tooltip>
        <TooltipTrigger asChild>
          <div
            className={cn(
              "inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 font-medium",
              sizeClasses[size],
              color === "text-slate-400"
                ? "bg-slate-100"
                : `bg-${color.split("-")[1]}-50`,
              className
            )}
          >
            {getTrustLevelIcon(level, iconSizes[size])}
            {showLabel && <span>{label}</span>}
            <span className="font-semibold">{score}</span>
          </div>
        </TooltipTrigger>
        <TooltipContent side="top" className="max-w-xs">
          <div className="space-y-1">
            <p className="font-semibold">
              {label} (Score: {score})
            </p>
            <p className="text-sm text-muted-foreground">{description}</p>
          </div>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}
