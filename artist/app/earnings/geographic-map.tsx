"use client";

import { useState, useEffect } from "react";

export function GeographicMap() {
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
  }, []);

  if (!isClient) {
    return (
      <div className="flex h-[300px] w-full items-center justify-center bg-muted/20">
        <p className="text-sm text-muted-foreground">Loading map...</p>
      </div>
    );
  }

  return (
    <div className="relative h-[300px] w-full overflow-hidden rounded-md bg-slate-950">
      {/* This is a placeholder for a real map component */}
      <div className="absolute inset-0 flex items-center justify-center">
        <svg
          width="100%"
          height="100%"
          viewBox="0 0 800 400"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
          className="opacity-70"
        >
          {/* World map simplified outline */}
          <path
            d="M110,120 Q160,80 200,120 T290,120 T380,150 T480,120 T570,120 T660,160 T720,120"
            stroke="#374151"
            strokeWidth="1"
            fill="none"
          />
          <path
            d="M100,180 Q150,150 200,180 T300,160 T400,190 T500,160 T600,180 T700,150"
            stroke="#374151"
            strokeWidth="1"
            fill="none"
          />
          <path
            d="M120,240 Q170,210 220,240 T320,220 T420,250 T520,220 T620,240 T720,210"
            stroke="#374151"
            strokeWidth="1"
            fill="none"
          />
          {/* Hotspots for different regions */}
          <circle cx="200" cy="150" r="20" fill="#9333EA" opacity="0.7" />{" "}
          {/* USA */}
          <circle cx="350" cy="130" r="12" fill="#3B82F6" opacity="0.7" />{" "}
          {/* UK */}
          <circle cx="380" cy="150" r="10" fill="#10B981" opacity="0.7" />{" "}
          {/* Germany */}
          <circle cx="180" cy="170" r="8" fill="#F97316" opacity="0.7" />{" "}
          {/* Canada */}
          <circle cx="500" cy="200" r="6" fill="#6B7280" opacity="0.7" />{" "}
          {/* Asia */}
          <circle cx="450" cy="250" r="5" fill="#6B7280" opacity="0.7" />{" "}
          {/* Australia */}
          <circle cx="300" cy="220" r="4" fill="#6B7280" opacity="0.7" />{" "}
          {/* South America */}
        </svg>
      </div>
    </div>
  );
}
