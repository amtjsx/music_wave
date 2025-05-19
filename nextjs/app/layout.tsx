import { I18nProvider } from "@/contexts/translation.context";
import { getAllDictionaries, getLocaleFromCookies } from "@/lib/i18n-utils";
import { cookies } from "next/headers";
import "./globals.css";

async function RootLayout({ children }: { children: React.ReactNode }) {
  const cookie = await cookies();
  const locale = await getLocaleFromCookies();
  const initialTranslations = await getAllDictionaries(locale);
  const defaultTheme = cookie.get("theme")?.value;
  return (
    <html lang="en" suppressHydrationWarning>
      <body
        className={`antialiased ${defaultTheme ?? ""}`}
        cz-shortcut-listen="true"
      >
        <I18nProvider
          initialLocale={locale}
          initialTranslations={initialTranslations}
        >
          {children}
        </I18nProvider>
      </body>
    </html>
  );
}

export default RootLayout;
