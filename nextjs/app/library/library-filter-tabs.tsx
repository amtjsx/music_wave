"use client";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useTranslation } from "@/hooks/use-translation";

interface LibraryFilterTabsProps {
  activeFilter: string;
  onFilterChange: (value: string) => void;
}

export function LibraryFilterTabs({
  activeFilter,
  onFilterChange,
}: LibraryFilterTabsProps) {
  const { t } = useTranslation("library");

  return (
    <Tabs
      value={activeFilter}
      onValueChange={onFilterChange}
      className="w-full"
    >
      <TabsList className="grid w-full max-w-md grid-cols-5">
        <TabsTrigger value="all">{t("library.filter.all", "All")}</TabsTrigger>
        <TabsTrigger value="playlists">
          {t("library.filter.playlists", "Playlists")}
        </TabsTrigger>
        <TabsTrigger value="artists">
          {t("library.filter.artists", "Artists")}
        </TabsTrigger>
        <TabsTrigger value="albums">
          {t("library.filter.albums", "Albums")}
        </TabsTrigger>
        <TabsTrigger value="songs">
          {t("library.filter.songs", "Songs")}
        </TabsTrigger>
      </TabsList>
    </Tabs>
  );
}
