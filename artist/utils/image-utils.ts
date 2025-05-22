// Generate a placeholder image with a specific color
export function getColoredPlaceholder(width: number, height: number, color = "4f46e5") {
  return `/placeholder.svg?height=${height}&width=${width}&text=&color=${color}`
}

// Generate a random color for placeholders
export function getRandomColor() {
  const colors = [
    "4f46e5", // indigo
    "8b5cf6", // violet
    "ec4899", // pink
    "f43f5e", // rose
    "f97316", // orange
    "eab308", // yellow
    "22c55e", // green
    "06b6d4", // cyan
    "3b82f6", // blue
  ]
  return colors[Math.floor(Math.random() * colors.length)]
}

// Generate album art placeholder with artist initial
export function getAlbumArtPlaceholder(width: number, height: number, title: string, color?: string) {
  const initial = title.charAt(0).toUpperCase()
  const bgColor = color || getRandomColor()
  return `/placeholder.svg?height=${height}&width=${width}&text=${initial}&color=${bgColor}`
}

