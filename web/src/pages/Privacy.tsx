import { PageHeader, SiteLayout } from "@/components/SiteLayout";
import { PERMISSIONS, PROCESSORS, SITE } from "@/lib/site";

const Privacy = () => {
  return (
    <SiteLayout>
      <PageHeader
        eyebrow={`Effective ${SITE.effectiveDate}`}
        title="Privacy Policy"
        intro="Kudao holds some of the most personal things a phone can hold: dates, photographs of people you love, notes about a friend, a grief that has a name. Here is exactly where all of it goes."
      />

      <article className="legal-prose mx-auto w-full max-w-3xl px-5 py-14">
        <p>
          This policy covers the Kudao app for iPhone and this website. It is written to be read, not to be
          skimmed past. If anything here is unclear, write to{" "}
          <a href={`mailto:${SITE.supportEmail}`}>{SITE.supportEmail}</a> and ask.
        </p>

        <h2>The short version</h2>
        <p>
          Everything you create in Kudao — profiles, dates, diary notes, plans, photos — is stored on your
          iPhone. It leaves the device in only three cases: you invite someone to a shared plan, you switch on
          cloud backup, or you ask the app to write a greeting or suggest a gift. Nothing is sold. Nothing is
          published. There is no feed.
        </p>

        <h2>Who is responsible</h2>
        <p>
          Kudao is an independent app. The person who operates it is reachable at{" "}
          <a href={`mailto:${SITE.supportEmail}`}>{SITE.supportEmail}</a> and acts as the data controller for
          the information described below.
        </p>

        <h2>What stays on your phone</h2>
        <p>
          By default the app works entirely offline. The following never reaches a server unless you take one
          of the actions described in the next section:
        </p>
        <ul>
          <li>Profiles: names, dates, relationship, occasion, photo</li>
          <li>Diary notes and the tags derived from them</li>
          <li>Party plans, checklists, gift ideas and their status</li>
          <li>Photos and videos added to a gallery</li>
          <li>Archived past events in your library</li>
          <li>Reminder settings and scheduled notifications</li>
        </ul>
        <p>
          Deleting the app deletes all of it. There is no hidden copy, and no way for us to recover it for you.
        </p>

        <h2>What leaves your phone, and when</h2>

        <h3>When you create an account</h3>
        <p>
          An account is optional and only needed for cloud backup and shared galleries. It stores your email
          address and a password you choose. The password is hashed by our authentication provider and is never
          visible to us.
        </p>

        <h3>When you invite someone</h3>
        <p>
          Sharing a plan creates an invitation link. The profile name, occasion, date, the plan, and any shared
          notes or photos are then held on our servers so the other person can see them. You choose what each
          participant is allowed to do, and you can revoke the link at any time, which stops further access.
        </p>

        <h3>When you turn on cloud backup</h3>
        <p>
          Backup uploads a copy of your profiles and notes so you can restore them on a new phone. It is off
          until you switch it on, and deleting the backup from the app removes it from the server.
        </p>

        <h3>When you ask for a greeting or a gift idea</h3>
        <p>
          These features send the relevant details — the person's first name, your relationship, the occasion,
          and the interests you recorded — to an AI provider that generates the text, and the reply comes
          straight back to your phone. The provider does not use it to train models. If you would rather nothing
          be sent, simply do not use those two features; the rest of the app works without them.
        </p>

        <h2>Permissions the app may ask for</h2>
        <p>Each one is requested only at the moment it is needed, and refusing it never locks you out.</p>
        <ul>
          {PERMISSIONS.map((permission) => (
            <li key={permission.name}>
              <strong>{permission.name}.</strong> {permission.use}
            </li>
          ))}
        </ul>

        <h2>Purchases</h2>
        <p>
          Kudao Premium is sold through Apple. Payment details are handled entirely by Apple and never reach
          us. We receive an anonymous identifier telling the app whether your subscription is active, so the
          features you paid for unlock on every device you sign in to.
        </p>

        <h2>Advertising</h2>
        <p>
          The free version shows a small banner on the home screen and, occasionally, a full-screen ad between
          actions. Ads never appear while you are writing a diary note, creating a profile or sending a
          message, and they never appear anywhere inside a remembrance profile. Subscribers see none at all.
        </p>
        <p>
          Ads are served by Google AdMob. On first launch iOS asks whether you allow tracking. If you say no —
          or ignore it — ads are still shown but are not personalised, and no advertising identifier is shared.
          You can change that answer at any time in the iPhone Settings app, under Privacy &amp; Security,
          Tracking. In Europe you will also be asked for advertising consent, and you can reopen those choices
          from the app's privacy screen.
        </p>

        <h2>Amazon links</h2>
        <p>
          Gift suggestions can open a search on Amazon in your browser. Those links carry an affiliate tag,
          which means we may earn a small commission if you buy something, at no extra cost to you. We are not
          told what you looked at or what you bought. Once the link opens, Amazon's own privacy policy applies.
        </p>

        <h2>Who else is involved</h2>
        <p>These are the only companies that can receive any of your information, and only for these reasons:</p>
        <ul>
          {PROCESSORS.map((processor) => (
            <li key={processor.name}>
              <strong>{processor.name}.</strong> {processor.role}{" "}
              <a href={processor.policy} target="_blank" rel="noreferrer noopener">
                Their privacy policy
              </a>
            </li>
          ))}
        </ul>
        <p>
          Some of these companies operate servers outside your country, including in the United States. Where
          that happens, the transfer relies on the standard contractual clauses those providers publish.
        </p>

        <h2>What we never do</h2>
        <ul>
          <li>We do not sell your information, to anyone, for any price</li>
          <li>We do not read your diary notes or your photographs</li>
          <li>We do not build a profile of you for advertising</li>
          <li>We do not send anything on your behalf — every message waits for your tap</li>
        </ul>

        <h2>How long anything is kept</h2>
        <p>
          Data on your phone stays until you delete it or remove the app. Backups stay until you delete them.
          Shared plans stay while the invitation is active, and are removed after the event is archived or the
          link is revoked. Account records are erased when you ask us to close the account.
        </p>

        <h2>Your rights</h2>
        <p>
          You can ask for a copy of what we hold, ask us to correct it, or ask us to delete it. If you are in
          the European Union or the United Kingdom you also have the right to object to processing and to
          complain to your national data protection authority. The{" "}
          <a href="/privacy-choices">privacy choices page</a> explains how to make each request.
        </p>

        <h2>Children</h2>
        <p>
          Kudao is not designed for children and is not directed at anyone under 13. We do not knowingly
          collect information from children. If you believe a child has created an account, write to us and we
          will remove it.
        </p>

        <h2>Changes to this policy</h2>
        <p>
          If this policy changes in a way that affects you, the effective date at the top changes and the app
          tells you at next launch. Continuing to use Kudao after that means the new version applies.
        </p>

        <h2>Contact</h2>
        <p>
          <a href={`mailto:${SITE.supportEmail}`}>{SITE.supportEmail}</a>
        </p>
      </article>
    </SiteLayout>
  );
};

export default Privacy;
