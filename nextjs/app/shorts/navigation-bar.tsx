"use client"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { Home, Search, Disc3, Video, User } from "lucide-react"
import { cn } from "@/lib/utils"

export default function NavigationBar() {
  const pathname = usePathname()

  const routes = [
    {
      name: "Home",
      path: "/",
      icon: Home,
    },
    {
      name: "Discover",
      path: "/discover",
      icon: Search,
    },
    {
      name: "Library",
      path: "/library",
      icon: Disc3,
    },
    {
      name: "Shorts",
      path: "/shorts",
      icon: Video,
    },
    {
      name: "Profile",
      path: "/profile/username",
      icon: User,
    },
  ]

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 bg-black/90 backdrop-blur-lg border-t border-white/10">
      <div className="flex items-center justify-around h-16 px-2">
        {routes.map((route) => {
          const isActive = pathname === route.path

          return (
            <Link
              key={route.path}
              href={route.path}
              className={cn(
                "flex flex-col items-center justify-center w-16 h-full",
                isActive ? "text-purple-500" : "text-gray-400",
              )}
            >
              <route.icon className={cn("h-6 w-6", isActive ? "text-purple-500" : "text-gray-400")} />
              <span className="text-xs mt-1">{route.name}</span>
              {isActive && <div className="absolute bottom-0 w-6 h-1 bg-purple-500 rounded-t-md" />}
            </Link>
          )
        })}
      </div>
    </div>
  )
}
