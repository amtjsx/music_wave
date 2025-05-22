"use client";

import type React from "react";

import { useRef, useEffect } from "react";
import { cn } from "@/lib/utils";

interface WaveformVisualizerProps {
  isPlaying: boolean;
  progress: number;
  onProgressChange?: (value: number[]) => void;
  className?: string;
}

export function WaveformVisualizer({
  isPlaying,
  progress,
  onProgressChange,
  className,
}: WaveformVisualizerProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);

  // Generate waveform data (in a real app, this would come from audio analysis)
  const generateWaveformData = () => {
    const data = [];
    const numBars = 100;

    // Create a pattern that resembles a realistic audio waveform
    for (let i = 0; i < numBars; i++) {
      // Base amplitude that creates a general shape
      let amplitude = Math.sin((i / numBars) * Math.PI) * 0.5 + 0.3;

      // Add some randomness for a more natural look
      amplitude += Math.random() * 0.3 - 0.15;

      // Ensure amplitude is between 0.1 and 0.9
      amplitude = Math.max(0.1, Math.min(0.9, amplitude));

      data.push(amplitude);
    }

    return data;
  };

  const waveformData = generateWaveformData();

  // Draw the waveform
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const container = containerRef.current;
    if (!container) return;

    // Set canvas dimensions
    const dpr = window.devicePixelRatio || 1;
    const rect = container.getBoundingClientRect();

    canvas.width = rect.width * dpr;
    canvas.height = rect.height * dpr;

    ctx.scale(dpr, dpr);
    canvas.style.width = `${rect.width}px`;
    canvas.style.height = `${rect.height}px`;

    // Clear canvas
    ctx.clearRect(0, 0, rect.width, rect.height);

    // Calculate bar width and spacing
    const numBars = waveformData.length;
    const barWidth = (rect.width / numBars) * 0.8;
    const spacing = (rect.width / numBars) * 0.2;
    const barWidthWithSpacing = barWidth + spacing;

    // Draw each bar
    for (let i = 0; i < numBars; i++) {
      const x = i * barWidthWithSpacing;
      const barHeight = waveformData[i] * rect.height;
      const y = (rect.height - barHeight) / 2;

      // Determine if this bar is before or after the progress point
      const progressX = (progress / 100) * rect.width;
      const isPlayed = x < progressX;

      // Set color based on whether the bar has been "played"
      if (isPlayed) {
        ctx.fillStyle = "rgb(147, 51, 234)"; // Purple for played portion
      } else {
        ctx.fillStyle = "rgb(161, 161, 170)"; // Gray for unplayed portion
      }

      // Draw the bar
      ctx.fillRect(x, y, barWidth, barHeight);
    }

    // Draw progress line
    if (progress > 0) {
      const progressX = (progress / 100) * rect.width;
      ctx.strokeStyle = "rgb(255, 255, 255)";
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(progressX, 0);
      ctx.lineTo(progressX, rect.height);
      ctx.stroke();
    }
  }, [progress, waveformData, isPlaying]);

  // Handle click on waveform to change position
  const handleClick = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!containerRef.current || !onProgressChange) return;

    const rect = containerRef.current.getBoundingClientRect();
    const clickX = e.clientX - rect.left;
    const newProgress = (clickX / rect.width) * 100;

    onProgressChange([newProgress]);
  };

  return (
    <div
      ref={containerRef}
      className={cn("relative h-full w-full cursor-pointer", className)}
      onClick={handleClick}
    >
      <canvas ref={canvasRef} className="h-full w-full" />
    </div>
  );
}
