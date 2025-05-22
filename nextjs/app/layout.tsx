import { AppSidebar } from "@/components/app-sidebar";
import { MusicPlayer } from "@/components/music-player";
import { AppHeader } from "@/components/site-header";
import { ThemeProvider } from "@/components/theme-provider";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { AudioProvider } from "@/contexts/audio-context";
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
          <ThemeProvider
            attribute="class"
            defaultTheme="system"
            enableSystem
            disableTransitionOnChange
          >
            <AudioProvider>
              <SidebarProvider>
                <AppSidebar />
                <SidebarInset>
                  <AppHeader />
                  {children}
                  <MusicPlayer />
                </SidebarInset>
              </SidebarProvider>
            </AudioProvider>
          </ThemeProvider>
        </I18nProvider>
      </body>
    </html>
  );
}

export default RootLayout;
