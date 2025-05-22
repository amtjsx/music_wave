"use client"

import { Play, Pause, Volume2, VolumeX } from "lucide-react"

interface VideoControlsProps {
  isPlaying: boolean
  isMuted: boolean
  progress: number
  togglePlay: () => void
  toggleMute: () => void
}

export default function VideoControls({ isPlaying, isMuted, progress, togglePlay, toggleMute }: VideoControlsProps) {
  return (
    <div className="absolute bottom-4 left-4 right-16 flex items-center space-x-3 text-white">
      {/* Play/Pause button */}
      <button
        onClick={(e) => {
          e.stopPropagation()
          togglePlay()
        }}
        className="h-8 w-8 flex items-center justify-center rounded-full bg-black/40 hover:bg-black/60"
      >
        {isPlaying ? <Pause className="h-4 w-4" /> : <Play className="h-4 w-4" />}
      </button>

      {/* Progress bar */}
      <div className="flex-1 h-1 bg-white/30 rounded-full overflow-hidden">
        <div className="h-full bg-purple-500" style={{ width: `${progress}%` }} />
      </div>

      {/* Mute/Unmute button */}
      <button
        onClick={(e) => {
          e.stopPropagation()
          toggleMute()
        }}
        className="h-8 w-8 flex items-center justify-center rounded-full bg-black/40 hover:bg-black/60"
      >
        {isMuted ? <VolumeX className="h-4 w-4" /> : <Volume2 className="h-4 w-4" />}
      </button>
    </div>
  )
}
