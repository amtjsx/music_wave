"use client";

import {
  BarChart3,
  DollarSign,
  Home,
  Music,
  Settings,
  Upload,
  User,
} from "lucide-react";

import {
  Sidebar,
  SidebarContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { useTranslation } from "@/hooks/use-translation";
import Link from "next/link";
import { usePathname } from "next/navigation";

const navItems = [
  {
    name: "Analytics",
    href: "/analytics",
    icon: Home,
  },
  {
    name: "Users",
    href: "/users",
    icon: Music,
  },
  {
    name: "Verification",
    href: "/verification",
    icon: Upload,
  },
  {
    name: "Profile",
    href: "/profile",
    icon: BarChart3,
  },
  {
    name: "Moderation",
    href: "/moderation",
    icon: DollarSign,
  },
  {
    name: "Profile",
    href: "/profile",
    icon: User,
  },
  {
    name: "Settings",
    href: "/settings",
    icon: Settings,
  },
];

export function ArtistDashboardSidebar() {
  const { t } = useTranslation("sidebar");
  const pathname = usePathname();

  return (
    <Sidebar collapsible="icon">
      <SidebarHeader className="flex h-14 items-center border-b px-4">
        <SidebarMenuButton size="lg" className="flex items-center gap-2">
          <Music className="h-5 w-5 text-purple-600" />
          <span className="font-semibold">MusicWave</span>
        </SidebarMenuButton>
      </SidebarHeader>
      <SidebarContent className="p-2">
        <SidebarMenu>
          {navItems.map((item, index) => (
            <SidebarMenuItem key={index}>
              <SidebarMenuButton isActive={item.href === pathname} asChild>
                <Link href={item.href}>
                  <item.icon className="h-4 w-4" />
                  <span>{t(item.name, item.name)}</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          ))}
        </SidebarMenu>
      </SidebarContent>
    </Sidebar>
  );
}
