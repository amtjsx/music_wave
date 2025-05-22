"use client";

import { Check, Globe } from "lucide-react";

import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useI18n, useTranslation } from "@/hooks/use-translation";

export function LanguageSwitcher() {
  const { t } = useTranslation("sidebar");

  const { setLocale, locale } = useI18n();

  const handleLanguageChange = (language: "en" | "my") => {
    setLocale(language);
  };

  const languages: { value: string; label: string }[] = [
    { value: "en", label: t("language.en", "English") },
    { value: "my", label: t("language.my", "မြန်မာ") },
  ];

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon">
          <Globe className="h-[1.2rem] w-[1.2rem]" />
          <span className="sr-only">{t("language")}</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end">
        {languages.map((lang) => (
          <DropdownMenuItem
            key={lang.value}
            onClick={() => {
              handleLanguageChange(lang.value as "en" | "my");
            }}
            className="flex items-center justify-between"
          >
            <span>{lang.label}</span>
            {locale === lang.value && <Check className="h-4 w-4 ml-2" />}
          </DropdownMenuItem>
        ))}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
