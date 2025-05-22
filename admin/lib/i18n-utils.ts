"use server";
import { cookies } from "next/headers";
import { cache } from "react";

export type TranslationModule =
  | "common"
  | "sidebar"
  | "dashboard"
  | "artist"
  | "player"
  | "hero"
  | "playlist"
  | "explore"
  | "library"

// Dictionary loaders with module support
const dictionaries: Record<
  string,
  Record<TranslationModule, () => Promise<any>>
> = {
  en: {
    common: () =>
      import("./dictionaries/en/common.json").then((module) => module.default),
    sidebar: () =>
      import("./dictionaries/en/sidebar.json").then((module) => module.default),
    dashboard: () =>
      import("./dictionaries/en/dashboard.json").then(
        (module) => module.default
      ),
    artist: () =>
      import("./dictionaries/en/artist.json").then((module) => module.default),
    player: () =>
      import("./dictionaries/en/player.json").then((module) => module.default),
    hero: () =>
      import("./dictionaries/en/hero.json").then((module) => module.default),
    playlist: () =>
      import("./dictionaries/en/playlist.json").then((module) => module.default),
    explore: () =>
      import("./dictionaries/en/explore.json").then((module) => module.default),
    library: () =>
      import("./dictionaries/en/library.json").then((module) => module.default),
  },
  my: {
    common: () =>
      import("./dictionaries/my/common.json").then((module) => module.default),
    sidebar: () =>
      import("./dictionaries/my/sidebar.json").then((module) => module.default),
    dashboard: () =>
      import("./dictionaries/my/dashboard.json").then(
        (module) => module.default
      ),
    artist: () =>
      import("./dictionaries/my/artist.json").then((module) => module.default),
    player: () =>
      import("./dictionaries/my/player.json").then((module) => module.default),
    hero: () =>
      import("./dictionaries/my/hero.json").then((module) => module.default),
    playlist: () =>
      import("./dictionaries/my/playlist.json").then((module) => module.default),
    explore: () =>
      import("./dictionaries/my/explore.json").then((module) => module.default),
    library: () =>
      import("./dictionaries/my/library.json").then((module) => module.default),
  },
};

// Use React's cache to prevent redundant loads in server components
export const getDictionary = cache(
  async (locale: string, module: TranslationModule) => {
    try {
      // Ensure we have a valid locale
      const validLocale = locale in dictionaries ? locale : "en";
      return await dictionaries[validLocale][module]();
    } catch (error) {
      console.error(
        `Failed to load dictionary for locale: ${locale}, module: ${module}`,
        error
      );
      // Fallback to English
      return await dictionaries.en[module]();
    }
  }
);

// Helper to get all modules for a locale (useful for initial SSR)
export const getAllDictionaries = cache(async (locale: string) => {
  const modules = Object.keys(dictionaries.en) as TranslationModule[];
  const result: Record<TranslationModule, any> = {} as any;

  for (const module of modules) {
    result[module] = await getDictionary(locale, module);
  }

  return result;
});

// Get locale from cookies on the server
export const getLocaleFromCookies = async () => {
  const cookieStore = await cookies();
  const localeCookie = cookieStore.get("NEXT_LOCALE");
  return localeCookie?.value || "en";
};
