import { Download, EyeOff, Settings2, Trash2 } from "lucide-react";

import { PageHeader, SiteLayout } from "@/components/SiteLayout";
import { SITE } from "@/lib/site";

const REQUESTS: readonly {
  icon: typeof Download;
  title: string;
  body: string;
  subject: string;
}[] = [
  {
    icon: Download,
    title: "Get a copy of your data",
    body: "We will send you everything held under your account — the account record itself, any backup, and any shared plan you created. Notes that never left your phone are not included, because we have never had them.",
    subject: "Kudao data access request",
  },
  {
    icon: Trash2,
    title: "Delete your account and data",
    body: "This erases your account, your backup and the shared plans you own. It cannot be undone, and shared galleries you created will disappear for everyone you invited. Content kept only on your phone is removed by deleting the app.",
    subject: "Kudao deletion request",
  },
  {
    icon: Settings2,
    title: "Correct something",
    body: "If an email address or any other detail we hold is wrong, tell us what it should say and we will change it.",
    subject: "Kudao correction request",
  },
];

const IN_APP_CONTROLS: readonly { title: string; body: string }[] = [
  {
    title: "Turn off personalised ads",
    body: "Open the iPhone Settings app, then Privacy & Security, then Tracking, and switch Kudao off. Ads keep funding the free version but stop being personalised. In Europe you can also reopen the consent choices from Settings, Privacy information, inside the app.",
  },
  {
    title: "Remove ads entirely",
    body: "Kudao Premium removes every ad. Remembrance profiles never show one, subscribed or not.",
  },
  {
    title: "Take back a permission",
    body: "Contacts, photos, camera, microphone, location and notifications can each be withdrawn in the iPhone Settings app under Kudao. The rest of the app keeps working.",
  },
  {
    title: "Stop sharing with someone",
    body: "Open the profile, go to the participants list and revoke the person's access. Their copy stops updating immediately.",
  },
  {
    title: "Delete a cloud backup",
    body: "Open Settings, then Cloud backup, and delete it. The copy on our servers is removed with it.",
  },
];

const PrivacyChoices = () => {
  return (
    <SiteLayout>
      <PageHeader
        eyebrow="Your choices"
        title="Take your information back."
        intro="Most of what Kudao knows never leaves your phone, so most of these controls live in the app itself. For anything we hold on a server, one email is enough."
      />

      <div className="mx-auto w-full max-w-3xl px-5 py-14">
        <section>
          <h2 className="font-[Fraunces] text-2xl font-semibold tracking-tight">Requests you can make to us</h2>
          <p className="mt-3 text-[0.95rem] leading-relaxed text-muted-foreground">
            Write from the email address on your Kudao account, so we know the request is really yours. We
            answer {SITE.responseWindow} and complete the request within one month.
          </p>

          <div className="mt-8 space-y-4">
            {REQUESTS.map((request) => (
              <div key={request.title} className="rounded-3xl border border-border bg-card p-6">
                <div className="flex items-center gap-3">
                  <request.icon className="h-5 w-5 text-primary" strokeWidth={2.2} />
                  <h3 className="font-[Fraunces] text-lg font-semibold tracking-tight">{request.title}</h3>
                </div>
                <p className="mt-3 text-[0.95rem] leading-relaxed text-muted-foreground">{request.body}</p>
                <a
                  href={`mailto:${SITE.supportEmail}?subject=${encodeURIComponent(request.subject)}`}
                  className="mt-4 inline-block rounded-full bg-primary/12 px-4 py-2 text-sm font-bold text-primary transition-colors hover:bg-primary/20"
                >
                  Send this request
                </a>
              </div>
            ))}
          </div>
        </section>

        <section className="mt-16">
          <div className="flex items-center gap-3">
            <EyeOff className="h-5 w-5 text-primary" strokeWidth={2.2} />
            <h2 className="font-[Fraunces] text-2xl font-semibold tracking-tight">Controls you hold yourself</h2>
          </div>
          <p className="mt-3 text-[0.95rem] leading-relaxed text-muted-foreground">
            These do not need us at all.
          </p>

          <dl className="mt-8 divide-y divide-border rounded-3xl border border-border bg-card px-6">
            {IN_APP_CONTROLS.map((control) => (
              <div key={control.title} className="py-5">
                <dt className="font-semibold">{control.title}</dt>
                <dd className="mt-1.5 text-[0.95rem] leading-relaxed text-muted-foreground">{control.body}</dd>
              </div>
            ))}
          </dl>
        </section>

        <section className="mt-14 rounded-3xl bg-secondary/60 p-7">
          <h2 className="font-[Fraunces] text-xl font-semibold tracking-tight">If you are not satisfied</h2>
          <p className="mt-3 text-[0.95rem] leading-relaxed text-muted-foreground">
            If we handle a request badly, you can complain to the data protection authority where you live. In
            Italy that is the Garante per la protezione dei dati personali. We would rather you tell us first,
            at <a href={`mailto:${SITE.supportEmail}`} className="font-semibold text-primary underline decoration-primary/30 underline-offset-4 hover:decoration-primary">{SITE.supportEmail}</a>, so we can put it right.
          </p>
        </section>
      </div>
    </SiteLayout>
  );
};

export default PrivacyChoices;
