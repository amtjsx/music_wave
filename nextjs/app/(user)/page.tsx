import { FeaturedArtists } from "@/components/featured-artists";
import { HeroSection } from "@/components/hero-section";
import { NewReleases } from "@/components/new-releases";
import { TrackList } from "@/components/track-list";

export default function HomePage() {
  return (
    <main className="flex-1 relative">
      <section className="container py-6">
        <HeroSection />
      </section>
      <section className="container py-8">
        <TrackList />
      </section>
      <section className="container py-8">
        <FeaturedArtists />
      </section>
      <section className="container py-8">
        <NewReleases />
      </section>
    </main>
  );
}
