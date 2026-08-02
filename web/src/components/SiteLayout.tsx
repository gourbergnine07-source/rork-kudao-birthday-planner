import { Menu } from "lucide-react";
import { memo, useEffect, useState, type ReactNode } from "react";
import { Link, NavLink, useLocation } from "react-router-dom";

import { SITE } from "@/lib/site";
import { cn } from "@/lib/utils";

const NAV_ITEMS: readonly { to: string; label: string }[] = [
  { to: "/", label: "Home" },
  { to: "/support", label: "Support" },
  { to: "/privacy", label: "Privacy" },
  { to: "/terms", label: "Terms" },
  { to: "/privacy-choices", label: "Your choices" },
];

/** The knotted thread and balloon from the app icon, drawn as a mark. */
export const KudaoMark = memo(function KudaoMark({ className }: { className?: string }) {
  return (
    <svg viewBox="0 0 40 40" className={className} aria-hidden="true">
      <circle cx="20" cy="20" r="20" fill="hsl(var(--primary))" />
      <path
        d="M11 29c3.2-1.6 5-4.2 5.4-7.6.4-3.6 2.4-5.9 6-6.9"
        fill="none"
        stroke="hsl(var(--amber))"
        strokeWidth="2.1"
        strokeLinecap="round"
      />
      <ellipse cx="26.4" cy="12.4" rx="4.3" ry="4.9" fill="hsl(var(--amber))" />
      <path d="M26.4 17.3l-1.5 2.1h3z" fill="hsl(var(--amber))" />
    </svg>
  );
});

/** Shared chrome: header, navigation, footer, and scroll reset between pages. */
export function SiteLayout({ children }: { children: ReactNode }) {
  const { pathname } = useLocation();
  const [isMenuOpen, setIsMenuOpen] = useState<boolean>(false);

  useEffect(() => {
    window.scrollTo({ top: 0, behavior: "auto" });
    setIsMenuOpen(false);
  }, [pathname]);

  return (
    <div className="paper-grain flex min-h-screen flex-col">
      <header className="sticky top-0 z-40 border-b border-border/70 bg-background/85 backdrop-blur-md">
        <div className="mx-auto flex h-16 w-full max-w-5xl items-center justify-between px-5">
          <Link to="/" className="flex items-center gap-2.5" aria-label="Kudao home">
            <KudaoMark className="h-8 w-8" />
            <span className="font-[Fraunces] text-xl font-semibold tracking-tight">{SITE.appName}</span>
          </Link>

          <nav className="hidden items-center gap-1 md:flex">
            {NAV_ITEMS.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === "/"}
                className={({ isActive }) =>
                  cn(
                    "rounded-full px-3.5 py-2 text-sm font-medium transition-colors",
                    isActive
                      ? "bg-primary/12 text-primary"
                      : "text-muted-foreground hover:bg-secondary hover:text-foreground",
                  )
                }
              >
                {item.label}
              </NavLink>
            ))}
          </nav>

          <button
            type="button"
            onClick={() => setIsMenuOpen((open) => !open)}
            className="rounded-full p-2 text-muted-foreground transition-colors hover:bg-secondary hover:text-foreground md:hidden"
            aria-label="Open menu"
            aria-expanded={isMenuOpen}
          >
            <Menu className="h-5 w-5" />
          </button>
        </div>

        {isMenuOpen && (
          <nav className="border-t border-border/70 bg-background px-5 pb-4 pt-2 md:hidden">
            {NAV_ITEMS.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === "/"}
                className={({ isActive }) =>
                  cn(
                    "block rounded-xl px-3 py-2.5 text-sm font-medium transition-colors",
                    isActive ? "bg-primary/12 text-primary" : "text-muted-foreground hover:bg-secondary",
                  )
                }
              >
                {item.label}
              </NavLink>
            ))}
          </nav>
        )}
      </header>

      <main className="flex-1">{children}</main>

      <footer className="border-t border-border/70 bg-secondary/40">
        <div className="mx-auto w-full max-w-5xl px-5 py-12">
          <div className="flex flex-col gap-8 sm:flex-row sm:items-start sm:justify-between">
            <div className="max-w-xs">
              <div className="flex items-center gap-2.5">
                <KudaoMark className="h-7 w-7" />
                <span className="font-[Fraunces] text-lg font-semibold">{SITE.appName}</span>
              </div>
              <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
                An app that remembers the people who matter, so you never arrive empty handed.
              </p>
            </div>

            <div className="grid grid-cols-2 gap-x-10 gap-y-2.5 text-sm sm:grid-cols-2">
              {NAV_ITEMS.slice(1).map((item) => (
                <Link
                  key={item.to}
                  to={item.to}
                  className="text-muted-foreground transition-colors hover:text-primary"
                >
                  {item.label}
                </Link>
              ))}
              <a
                href={`mailto:${SITE.supportEmail}`}
                className="text-muted-foreground transition-colors hover:text-primary"
              >
                Contact
              </a>
            </div>
          </div>

          <p className="mt-10 border-t border-border/70 pt-6 text-xs text-muted-foreground">{SITE.copyright}</p>
        </div>
      </footer>
    </div>
  );
}

/** Consistent heading block for the legal and support pages. */
export function PageHeader({
  eyebrow,
  title,
  intro,
}: {
  eyebrow: string;
  title: string;
  intro: string;
}) {
  return (
    <div className="border-b border-border/70 bg-gradient-to-b from-accent/60 to-transparent">
      <div className="mx-auto w-full max-w-3xl px-5 pb-12 pt-14 sm:pt-20">
        <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">{eyebrow}</p>
        <h1 className="mt-3 text-balance text-4xl font-semibold leading-[1.08] tracking-tight sm:text-5xl">
          {title}
        </h1>
        <p className="mt-5 max-w-2xl text-[1.05rem] leading-relaxed text-muted-foreground">{intro}</p>
      </div>
    </div>
  );
}
