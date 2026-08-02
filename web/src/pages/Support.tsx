import { CreditCard, Mail, Trash2, TriangleAlert } from "lucide-react";
import { Link } from "react-router-dom";

import { PageHeader, SiteLayout } from "@/components/SiteLayout";
import { SITE } from "@/lib/site";

const WHAT_TO_INCLUDE: readonly string[] = [
  "The app version, shown at the bottom of Settings",
  "Your iPhone model and iOS version",
  "The email address of your Kudao account, if you created one",
  "What you expected to happen, and what happened instead",
  "A screenshot, if the problem is something you can see",
];

const TOPICS: readonly {
  icon: typeof Mail;
  title: string;
  body: string;
  action?: { label: string; to: string };
}[] = [
  {
    icon: TriangleAlert,
    title: "Something is not working",
    body: "Reminders that do not arrive, a photo that will not upload, an invitation link that fails. Tell us what you were doing when it happened — that is usually enough to find it.",
  },
  {
    icon: CreditCard,
    title: "Subscription and billing",
    body: "Kudao Premium is billed by Apple, not by us. To cancel or request a refund, open Settings on your iPhone, tap your name, then Subscriptions. If a purchase did not unlock, tap Restore purchases on the Kudao paywall first, then write to us.",
  },
  {
    icon: Trash2,
    title: "Delete your account or your data",
    body: "Deleting the app removes everything held on your phone. If you created an account for backup or a shared gallery, we can erase the copy on our side as well.",
    action: { label: "How to request deletion", to: "/privacy-choices" },
  },
];

const Support = () => {
  return (
    <SiteLayout>
      <PageHeader
        eyebrow="Support"
        title="Something not working? Write to us."
        intro={`Kudao is made for ${SITE.platform}. There is no ticket system and no bot — messages go to a person, and you will get an answer ${SITE.responseWindow}.`}
      />

      <div className="mx-auto w-full max-w-3xl px-5 py-14">
        <a
          href={`mailto:${SITE.supportEmail}?subject=Kudao%20support`}
          className="flex items-center gap-4 rounded-3xl bg-primary p-6 text-primary-foreground shadow-lg shadow-primary/25 transition-transform hover:-translate-y-0.5"
        >
          <Mail className="h-7 w-7 shrink-0" strokeWidth={2.2} />
          <span>
            <span className="block text-xs font-bold uppercase tracking-[0.16em] opacity-80">Email us</span>
            <span className="mt-1 block break-all font-[Fraunces] text-xl font-semibold">
              {SITE.supportEmail}
            </span>
          </span>
        </a>

        <div className="mt-12 space-y-4">
          {TOPICS.map((topic) => (
            <div key={topic.title} className="rounded-3xl border border-border bg-card p-6">
              <div className="flex items-center gap-3">
                <topic.icon className="h-5 w-5 text-primary" strokeWidth={2.2} />
                <h2 className="font-[Fraunces] text-xl font-semibold tracking-tight">{topic.title}</h2>
              </div>
              <p className="mt-3 text-[0.95rem] leading-relaxed text-muted-foreground">{topic.body}</p>
              {topic.action && (
                <Link
                  to={topic.action.to}
                  className="mt-4 inline-block text-sm font-semibold text-primary underline decoration-primary/30 underline-offset-4 hover:decoration-primary"
                >
                  {topic.action.label}
                </Link>
              )}
            </div>
          ))}
        </div>

        <section className="mt-14">
          <h2 className="font-[Fraunces] text-2xl font-semibold tracking-tight">
            What to put in your message
          </h2>
          <p className="mt-3 text-[0.95rem] leading-relaxed text-muted-foreground">
            None of this is required, but each line saves a round trip.
          </p>
          <ul className="mt-6 space-y-3">
            {WHAT_TO_INCLUDE.map((item) => (
              <li key={item} className="flex items-start gap-3 text-[0.95rem] leading-relaxed">
                <span className="mt-[0.55rem] h-1.5 w-1.5 shrink-0 rounded-full bg-primary/60" />
                <span className="text-foreground/80">{item}</span>
              </li>
            ))}
          </ul>
        </section>

        <section className="mt-14 rounded-3xl bg-secondary/60 p-7">
          <h2 className="font-[Fraunces] text-xl font-semibold tracking-tight">Before you write</h2>
          <p className="mt-3 text-[0.95rem] leading-relaxed text-muted-foreground">
            Two things fix most reports on their own. If reminders never arrive, check that notifications are
            allowed for Kudao in the iPhone Settings app. If a shared gallery looks empty, make sure the person
            who invited you has not revoked the link — invitations can be turned off at any time by whoever
            created them.
          </p>
        </section>
      </div>
    </SiteLayout>
  );
};

export default Support;
