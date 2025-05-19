"use client";

import {
  BarChart3,
  DollarSign,
  Home,
  Music,
  Music2,
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

const navItems = [
  {
    name: "Overview",
    href: "/artist",
    icon: Home,
  },
  {
    name: "Music",
    href: "/artist/music",
    icon: Music,
  },
  {
    name: "Upload",
    href: "/artist/upload",
    icon: Upload,
  },
  {
    name: "Analytics",
    href: "/artist/analytics",
    icon: BarChart3,
  },
  {
    name: "Earnings",
    href: "/artist/earnings",
    icon: DollarSign,
  },
  {
    name: "Profile",
    href: "/artist/profile",
    icon: User,
  },
  {
    name: "Settings",
    href: "/artist/settings",
    icon: Settings,
  },
];

export function ArtistDashboardNav() {
  const { t } = useTranslation("sidebar");

  return (
    <Sidebar>
      <SidebarHeader>
        <SidebarMenuItem>
          <SidebarMenuButton>
            <Music2 className="h-4 w-4" />
            <span>Artist</span>
          </SidebarMenuButton>
        </SidebarMenuItem>
      </SidebarHeader>
      <SidebarContent>
        <SidebarMenu>
          {navItems.map((item) => (
            <SidebarMenuItem key={item.href}>
              <Link href={item.href}>
                <SidebarMenuButton>
                  <item.icon className="h-4 w-4" />
                  <span>{t(item.name, item.name)}</span>
                </SidebarMenuButton>
              </Link>
            </SidebarMenuItem>
          ))}
        </SidebarMenu>
      </SidebarContent>
    </Sidebar>
  );
}
