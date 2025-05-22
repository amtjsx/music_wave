"use client";

import { I18nContext } from "@/contexts/translation.context";
import { TranslationModule } from "@/lib/i18n-utils";
import { useCallback, useContext, useEffect, useState } from "react";

// Supported locales
export const locales = ["en", "my"];
export const defaultLocale = "en";

export function useI18n() {
  const context = useContext(I18nContext);

  if (context === undefined) {
    throw new Error("useI18n must be used within an I18nProvider");
  }

  return context;
}

// Specialized hook for a specific module
export function useTranslation(module: TranslationModule) {
  const { locale, isLoading, loadModule, t, translations } = useI18n();
  const [moduleLoading, setModuleLoading] = useState(!translations[module]);

  useEffect(() => {
    if (!translations[module]) {
      setModuleLoading(true);
      loadModule(module).then(() => {
        setModuleLoading(false);
      });
    } else {
      setModuleLoading(false);
    }
  }, [module, translations, loadModule]);

  const translate = useCallback(
    (
      key: string,
      defaultValue?: string,
      variables?: Record<string, string | number>
    ) => {
      return t(module, key, defaultValue, variables);
    },
    [t, module]
  );

  return {
    t: translate,
    loading: moduleLoading || isLoading,
    locale,
  };
}
