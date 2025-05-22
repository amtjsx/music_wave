import { getAllDictionaries } from "@/lib/i18n-utils";
import { type NextRequest } from "next/server";

export async function GET(req: NextRequest) {
  try {
    const searchParams = req.nextUrl.searchParams;
    const locale = searchParams.get("locale") as string;

    const initialTranslations = await getAllDictionaries(locale);
    return new Response(JSON.stringify(initialTranslations));
  } catch (error) {
    console.error("Error fetching translations:", error);
    return new Response(
      JSON.stringify({ error: "Failed to load translations" }),
      { status: 500 }
    );
  }
}
