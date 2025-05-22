"use client"

import { Music } from "lucide-react"
import { useTranslation } from "@/hooks/use-translation"

export function LibraryEmptyState() {
  const { t } = useTranslation("library")

  return (
    <div className="flex flex-col items-center justify-center py-16 text-center">
      <div className="mb-4 rounded-full bg-muted p-6">
        <Music className="h-12 w-12 text-muted-foreground" />
      </div>
      <h3 className="mb-2 text-xl font-semibold">{t("library.empty")}</h3>
      <p className="max-w-md text-muted-foreground">{t("library.empty.description")}</p>
    </div>
  )
}

