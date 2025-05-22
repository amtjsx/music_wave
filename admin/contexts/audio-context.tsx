"use client"

import { createContext, useContext, type ReactNode } from "react"
import { useAudioPlayer, type Track } from "@/hooks/use-audio-player"

interface AudioContextType {
  tracks: Track[]
  setTracks: (tracks: Track[]) => void
  currentTrack: Track | undefined
  currentTrackIndex: number
  isPlaying: boolean
  duration: number
  currentTime: number
  volume: number
  isMuted: boolean
  togglePlayPause: () => void
  playTrack: (index: number) => void
  nextTrack: () => void
  previousTrack: () => void
  seek: (time: number) => void
  setVolume: (value: number) => void
  toggleMute: () => void
}

const AudioContext = createContext<AudioContextType | undefined>(undefined)

export function AudioProvider({ children }: { children: ReactNode }) {
  const audioPlayer = useAudioPlayer()

  return <AudioContext.Provider value={audioPlayer}>{children}</AudioContext.Provider>
}

export function useAudio() {
  const context = useContext(AudioContext)
  if (context === undefined) {
    throw new Error("useAudio must be used within an AudioProvider")
  }
  return context
}

