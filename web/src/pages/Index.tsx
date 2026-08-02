import {
  CalendarHeart,
  Gift,
  Heart,
  LifeBuoy,
  Lock,
  NotebookPen,
  ScrollText,
  ShieldCheck,
  Sparkles,
  Timer,
  Users,
} from "lucide-react";
import { Link } from "react-router-dom";

import { KudaoMark, SiteLayout } from "@/components/SiteLayout";
import { SITE } from "@/lib/site";

const FEATURES: readonly { icon: typeof Timer; title: string; body: string }[] = [
  {
    icon: Timer,
    title: "A countdown for everyone",
    body: "Birthdays, anniversaries, weddings and remembrances, each with the days ticking down on the home screen and in a widget.",
  },
  {
    icon: NotebookPen,
    title: "A diary that pays off",
    body: "Jot down what someone mentions in March. In December the app hands it back to you as a gift idea.",
  },
  {
    icon: Gift,
    title: "Ideas, not guesswork",
    body: "Suggestions built from what you actually know about the person, with a shop link or a map of nearby stores.",
  },
  {
    icon: Users,
    title: "Plan it with others",
    body: "Invite someone with a link. You share the plan, the photo gallery and the running joke, not your whole account.",
  },
  {
    icon: Heart,
    title: "A gentler kind of date",
    body: "Remembrance profiles stay quiet: no ads, no nudging, no suggestions. Just the day and what you want to keep of it.",
  },
  {
    icon: Sparkles,
    title: "A message ready to send",
    body: "A greeting written in your tone, waiting for the final tap. Kudao never sends anything by itself.",
  },
];

const LINK_CARDS: readonly { to: string; icon: typeof LifeBuoy; title: string; body: string }[] = [
  {
    to: "/support",
    icon: LifeBuoy,
    title: "Support",
    body: "Something broken, a question about billing, or an account you want deleted.",
  },
  {
    to: "/privacy",
    icon: ShieldCheck,
    title: "Privacy Policy",
    body: "What the app keeps, what never leaves your phone, and who else is involved.",
  },
  {
    to: "/terms",
    icon: ScrollText,
    title: "Terms of Use",
    body: "The agreement covering the app, the subscription and anything you write in it.",
  },
  {
    to: "/privacy-choices",
    icon: Lock,
    title: "Your privacy choices",
    body: "Get a copy of your data, delete it, or turn off personalised ads.",
  },
];

const Index = () => {
  return (
    <SiteLayout>
      {/* Hero */}
      <section className="relative overflow-hidden">
        <div
          className="pointer-events-none absolute -right-32 -top-40 h-[30rem] w-[30rem] rounded-full opacity-60 blur-3xl"
          style={{ background: "radial-gradient(circle, hsl(var(--primary) / 0.28), transparent 70%)" }}
        />
        <div
          className="pointer-events-none absolute -left-40 top-40 h-[26rem] w-[26rem] rounded-full opacity-50 blur-3xl"
          style={{ background: "radial-gradient(circle, hsl(var(--amber) / 0.26), transparent 70%)" }}
        />

        <div className="relative mx-auto w-full max-w-5xl px-5 pb-20 pt-20 sm:pt-28">
          <div className="flex items-center gap-3">
            <KudaoMark className="h-12 w-12" />
            <span className="rounded-full bg-primary/12 px-3 py-1 text-xs font-bold uppercase tracking-[0.14em] text-primary">
              For iPhone
            </span>
          </div>

          <h1 className="mt-8 max-w-3xl text-balance text-[2.75rem] font-semibold leading-[1.03] tracking-tight sm:text-6xl">
            Never forget the people who matter.
          </h1>

          <p className="mt-6 max-w-xl text-lg leading-relaxed text-muted-foreground">
            Kudao holds every birthday, anniversary, wedding and remembrance in one warm place — with a
            countdown, a gift idea and a diary of the little things you noticed during the year.
          </p>

          <div className="mt-9 flex flex-wrap items-center gap-3">
            <Link
              to="/support"
              className="rounded-full bg-primary px-6 py-3 text-sm font-bold text-primary-foreground shadow-lg shadow-primary/25 transition-transform hover:-translate-y-0.5 active:translate-y-0"
            >
              Get support
            </Link>
            <Link
              to="/privacy"
              className="rounded-full border border-border bg-card px-6 py-3 text-sm font-bold text-foreground transition-colors hover:border-primary/50 hover:text-primary"
            >
              Read the privacy policy
            </Link>
          </div>

          <div className="mt-14 flex flex-wrap items-center gap-x-8 gap-y-3 text-sm text-muted-foreground">
            <span className="flex items-center gap-2">
              <CalendarHeart className="h-4 w-4 text-primary" />
              Birthdays free forever
            </span>
            <span className="flex items-center gap-2">
              <ShieldCheck className="h-4 w-4 text-primary" />
              Your notes stay on your phone
            </span>
            <span className="flex items-center gap-2">
              <Heart className="h-4 w-4 text-primary" />
              No ads in remembrances
            </span>
          </div>
        </div>
      </section>

      {/* What it does */}
      <section className="border-y border-border/70 bg-card/60">
        <div className="mx-auto w-full max-w-5xl px-5 py-20">
          <h2 className="max-w-2xl text-balance text-3xl font-semibold tracking-tight sm:text-4xl">
            Showing up is a small thing that takes a year of attention.
          </h2>
          <p className="mt-4 max-w-2xl leading-relaxed text-muted-foreground">
            Kudao is the place that keeps that attention for you.
          </p>

          <div className="mt-12 grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
            {FEATURES.map((feature) => (
              <div
                key={feature.title}
                className="rounded-3xl border border-border bg-background p-6 transition-shadow hover:shadow-md"
              >
                <feature.icon className="h-6 w-6 text-primary" strokeWidth={2.2} />
                <h3 className="mt-4 font-[Fraunces] text-lg font-semibold tracking-tight">{feature.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{feature.body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Legal + support directory */}
      <section className="mx-auto w-full max-w-5xl px-5 py-20">
        <h2 className="text-3xl font-semibold tracking-tight sm:text-4xl">Help and legal</h2>
        <p className="mt-4 max-w-2xl leading-relaxed text-muted-foreground">
          These pages exist so you can always reach a person, understand what happens to your information, and
          ask for it back. They are public and need no account.
        </p>

        <div className="mt-10 grid gap-4 sm:grid-cols-2">
          {LINK_CARDS.map((card) => (
            <Link
              key={card.to}
              to={card.to}
              className="group flex items-start gap-4 rounded-3xl border border-border bg-card p-6 transition-all hover:-translate-y-0.5 hover:border-primary/50 hover:shadow-md"
            >
              <span className="rounded-2xl bg-primary/12 p-2.5">
                <card.icon className="h-5 w-5 text-primary" strokeWidth={2.2} />
              </span>
              <span>
                <span className="block font-[Fraunces] text-lg font-semibold tracking-tight group-hover:text-primary">
                  {card.title}
                </span>
                <span className="mt-1.5 block text-sm leading-relaxed text-muted-foreground">{card.body}</span>
              </span>
            </Link>
          ))}
        </div>

        <div className="mt-12 rounded-3xl bg-secondary/60 p-7">
          <p className="text-sm leading-relaxed text-muted-foreground">
            Questions about the app, an order, or your account? Write to{" "}
            <a
              href={`mailto:${SITE.supportEmail}`}
              className="font-semibold text-primary underline decoration-primary/30 underline-offset-4 hover:decoration-primary"
            >
              {SITE.supportEmail}
            </a>{" "}
            and you will hear back {SITE.responseWindow}.
          </p>
        </div>
      </section>
    </SiteLayout>
  );
};

export default Index;
