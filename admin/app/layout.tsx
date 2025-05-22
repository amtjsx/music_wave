import { SiteHeader } from "@/components/site-header";
import { SidebarInset, SidebarProvider } from "@/components/ui/sidebar";
import { AudioProvider } from "@/contexts/audio-context";
import { I18nProvider } from "@/contexts/translation.context";
import { getAllDictionaries, getLocaleFromCookies } from "@/lib/i18n-utils";
import { cookies } from "next/headers";
import { ArtistDashboardSidebar } from "./components/artist-dashboard-nav";
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
          <AudioProvider>
            <SidebarProvider
              style={
                {
                  "--sidebar-width": "18rem",
                } as React.CSSProperties
              }
            >
              <ArtistDashboardSidebar />
              <SidebarInset>
                <SiteHeader />
                {children}
              </SidebarInset>
            </SidebarProvider>
          </AudioProvider>
        </I18nProvider>
      </body>
    </html>
  );
}

export default RootLayout;
