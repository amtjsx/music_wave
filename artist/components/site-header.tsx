"use client";

import { Search } from "lucide-react";
import Link from "next/link";

import { LanguageSwitcher } from "@/components/language-switcher";
import { ThemeToggle } from "@/components/theme-toggle";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { useTranslation } from "@/hooks/use-translation";

export function SiteHeader() {
  const { t } = useTranslation("sidebar");

  return (
    <header className="sticky bg-red-500 top-0 z-40 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 items-center space-x-4 justify-between sm:space-x-0">
        <SidebarTrigger />
        <div className="flex items-center space-x-4 justify-between">
          <div className="relative">
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              type="search"
              placeholder={t("nav.search", "What do you want to play?")}
              className="w-[200px] pl-8 md:w-[300px] lg:w-[400px]"
            />
          </div>
          <div className="md:flex hidden items-center space-x-2">
            <LanguageSwitcher />
            <ThemeToggle />
          </div>
          <Link href="/signin">
            <Button>{t("nav.signin", "Sign In")}</Button>
          </Link>
        </div>
      </div>
    </header>
  );
}
