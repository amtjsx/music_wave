import { Shield, CheckCircle } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

interface VerifiedBadgeProps {
  size?: "sm" | "md" | "lg";
  variant?: "default" | "subtle" | "minimal";
  className?: string;
  showTooltip?: boolean;
  tooltipSide?: "top" | "right" | "bottom" | "left";
  verificationDate?: string;
}

export function VerifiedBadge({
  size = "md",
  variant = "default",
  className,
  showTooltip = true,
  tooltipSide = "top",
  verificationDate,
}: VerifiedBadgeProps) {
  const sizeClasses = {
    sm: "h-4 w-4",
    md: "h-5 w-5",
    lg: "h-6 w-6",
  };

  const variantClasses = {
    default: "bg-purple-600 text-white border-transparent hover:bg-purple-700",
    subtle:
      "bg-purple-100 text-purple-600 border-purple-200 dark:bg-purple-900/50 dark:text-purple-300 dark:border-purple-800",
    minimal:
      "bg-transparent text-purple-600 border-transparent dark:text-purple-300",
  };

  const badge = (
    <div
      className={cn(
        "inline-flex items-center justify-center rounded-full border",
        variantClasses[variant],
        {
          "h-4 w-4 p-0.5": size === "sm",
          "h-5 w-5 p-0.5": size === "md",
          "h-6 w-6 p-1": size === "lg",
        },
        className
      )}
      aria-label="Verified Artist"
    >
      <CheckCircle className={cn("h-full w-full", sizeClasses[size])} />
    </div>
  );

  if (!showTooltip) {
    return badge;
  }

  return (
    <TooltipProvider>
      <Tooltip delayDuration={300}>
        <TooltipTrigger asChild>{badge}</TooltipTrigger>
        <TooltipContent side={tooltipSide} className="max-w-xs">
          <div className="flex flex-col gap-1 p-1 text-sm">
            <div className="flex items-center gap-1.5 font-medium">
              <Shield className="h-3.5 w-3.5 text-purple-600" />
              Verified Artist
            </div>
            <p className="text-xs text-muted-foreground">
              This artist has been verified by MusicWave as authentic.
              {verificationDate && ` Verified on ${verificationDate}.`}
            </p>
          </div>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}
