"use client";

import Cookies from "js-cookie";
import { createContext, useCallback, useState, type ReactNode } from "react";
import { TranslationModule } from "../lib/i18n-utils";

// Supported locales
export const locales = ["en", "my"];
export const defaultLocale = "en";

interface I18nContextType {
  locale: string;
  setLocale: (locale: string) => void;
  isLoading: boolean;
  translations: Record<TranslationModule, any>;
  t: (
    module: TranslationModule,
    key: string,
    defaultValue?: string,
    variables?: Record<string, string | number>
  ) => string;
  loadModule: (module: TranslationModule) => Promise<void>;
}

export const I18nContext = createContext<I18nContextType>({
  locale: defaultLocale,
  setLocale: () => {},
  isLoading: false,
  translations: {} as Record<TranslationModule, any>,
  t: () => "",
  loadModule: async () => {},
});

export function I18nProvider({
  children,
  initialLocale,
  initialTranslations,
}: {
  children: ReactNode;
  initialLocale: string;
  initialTranslations: Record<TranslationModule, any>;
}) {
  const [locale, setLocaleState] = useState(initialLocale);
  const [isLoading, setIsLoading] = useState(false);
  const [translations, setTranslations] = useState<
    Record<TranslationModule, any>
  >(initialTranslations || {});

  // Function to load a specific translation module
  const loadModule = useCallback(
    async (module: TranslationModule) => {
      console.log("start loading translations");
      // Skip if already loaded
      if (translations[module]) return;

      setIsLoading(true);
      try {
        console.log("localhst", locale, module);
        const response = await fetch(
          `/api/translations?locale=${locale}&module=${module}`
        );

        if (!response.ok) {
          throw new Error(`Failed to load translations for ${module}`);
        }

        const moduleTranslations = await response.json();
        console.log("response translations", moduleTranslations);

        setTranslations((prev) => ({
          ...prev,
          [module]: moduleTranslations,
        }));
      } catch (error) {
        console.error(`Error loading translation module ${module}:`, error);

        // Try to load fallback from default locale if needed
        if (locale !== defaultLocale) {
          try {
            const fallbackResponse = await fetch(
              `/api/translations?locale=${defaultLocale}&module=${module}`
            );

            if (fallbackResponse.ok) {
              const fallbackTranslations = await fallbackResponse.json();
              setTranslations((prev) => ({
                ...prev,
                [module]: fallbackTranslations,
              }));
            }
          } catch (fallbackError) {
            console.error(
              "Error loading fallback translations:",
              fallbackError
            );
          }
        }
      } finally {
        setIsLoading(false);
      }
    },
    [locale, translations]
  );

  // Translation helper function with dot notation support
  // Enhanced translation helper function with template variable support
  const t = useCallback(
    (
      module: TranslationModule,
      key: string,
      defaultValue = "",
      variables?: Record<string, string | number>
    ) => {
      if (!translations[module]) {
        return replaceVariables(defaultValue, variables);
      }

      // Support for nested keys using dot notation
      const keys = key.split(".");
      let result = translations[module];

      for (const k of keys) {
        if (result && typeof result === "object" && k in result) {
          result = result[k];
        } else {
          return replaceVariables(defaultValue, variables);
        }
      }

      // If we found a translation but it's not a string, use default
      if (typeof result !== "string") {
        return replaceVariables(defaultValue, variables);
      }

      // Replace template variables in the translation
      return replaceVariables(result, variables);
    },
    [translations]
  );

  // Helper function to replace template variables
  const replaceVariables = (
    text: string,
    variables?: Record<string, string | number>
  ) => {
    if (!variables) return text;

    return text.replace(/\{\{(\w+)\}\}/g, (match, key) => {
      return variables[key] !== undefined ? String(variables[key]) : match;
    });
  };

  // Function to change locale
  const setLocale = useCallback(
    async (newLocale: string) => {
      if (!locales.includes(newLocale)) {
        console.error(`Locale ${newLocale} is not supported`);
        return;
      }

      // Set the cookie
      Cookies.set("NEXT_LOCALE", newLocale, { expires: 365 });

      // Update state
      setLocaleState(newLocale);

      const response = await fetch(`/api/translations?locale=${newLocale}`);

      if (!response.ok) {
        throw new Error(`Failed to load translations for ${newLocale}`);
      }

      const moduleTranslations = await response.json();
      console.log("response translations", moduleTranslations);
      setTranslations(moduleTranslations);
    },
    [locale]
  );

  if (isLoading) {
    return (
      <div className="flex items-center justify-center">
        Loading your language...
      </div>
    );
  }

  return (
    <I18nContext.Provider
      value={{
        locale,
        setLocale,
        isLoading,
        translations,
        t,
        loadModule,
      }}
    >
      {children}
    </I18nContext.Provider>
  );
}
