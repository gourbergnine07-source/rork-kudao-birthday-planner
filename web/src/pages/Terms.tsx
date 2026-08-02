import { PageHeader, SiteLayout } from "@/components/SiteLayout";
import { SITE } from "@/lib/site";

const Terms = () => {
  return (
    <SiteLayout>
      <PageHeader
        eyebrow={`Effective ${SITE.effectiveDate}`}
        title="Terms of Use"
        intro="The agreement between you and Kudao. Short, and in plain words, because terms nobody can read protect nobody."
      />

      <article className="legal-prose mx-auto w-full max-w-3xl px-5 py-14">
        <h2>Accepting these terms</h2>
        <p>
          By downloading or using Kudao you agree to what follows. If you do not agree, please do not use the
          app. If you are using it on behalf of someone else, you confirm you may accept these terms for them.
        </p>

        <h2>What you are allowed to do</h2>
        <p>
          You get a personal, non-exclusive, non-transferable licence to use Kudao on devices you own or
          control, for your own purposes. The app itself, its design and its name remain ours.
        </p>

        <h2>Your account</h2>
        <p>
          An account is optional. If you create one, keep your password to yourself and tell us promptly if you
          think someone else has it. You are responsible for what happens under your account.
        </p>

        <h2>What you write and upload</h2>
        <p>
          Your profiles, notes and photographs are yours. You keep every right in them. By using the sharing
          features you give us permission to store and transmit that content strictly so it can reach the
          people you invited — nothing more. We do not display it anywhere else and we do not use it to
          advertise.
        </p>
        <p>
          Kudao stores information about other people: their birthdays, their preferences, sometimes their
          photographs. Please only add what those people would be comfortable with, and only share it with
          people who should see it. If someone asks you to remove their details, remove them.
        </p>

        <h2>Behaviour we cannot allow</h2>
        <ul>
          <li>Uploading content that is unlawful, hateful, harassing, or sexual content involving minors</li>
          <li>Sharing someone else's private information without their agreement</li>
          <li>Using shared galleries or plans to harass, threaten or impersonate anyone</li>
          <li>Trying to break, overload, reverse engineer or circumvent payment for the service</li>
          <li>Using the app for anything unlawful where you live</li>
        </ul>
        <p>
          Shared content can be reported by writing to <a href={`mailto:${SITE.supportEmail}`}>{SITE.supportEmail}</a>. We
          review reports and can remove content or block an account. Anyone who invited a participant can also
          revoke that person's access from inside the app at any time.
        </p>

        <h2>Text written by AI</h2>
        <p>
          Greeting suggestions and gift ideas are generated automatically. They can be wrong, clumsy, or
          occasionally strange. Read them before you use them — they are drafts, not advice, and you are
          responsible for anything you choose to send. Kudao never sends a message on your behalf.
        </p>

        <h2>Subscription</h2>
        <p>
          Birthday and remembrance profiles are free, with no time limit. Wedding and other event profiles
          require Kudao Premium, available as a monthly or a yearly subscription. Prices are shown in the app,
          in your local currency, before you confirm.
        </p>
        <ul>
          <li>Payment is charged to your Apple ID when you confirm the purchase</li>
          <li>
            The subscription renews automatically unless you cancel at least 24 hours before the current period
            ends
          </li>
          <li>Renewal is charged within 24 hours of the end of the period, at the price then shown</li>
          <li>
            You can manage or cancel it at any time in the iPhone Settings app, under your name, then
            Subscriptions
          </li>
          <li>Refunds are handled by Apple under its own terms; we cannot issue them ourselves</li>
        </ul>
        <p>
          If your subscription ends, nothing is deleted. Wedding and other event profiles simply become
          inaccessible until you subscribe again, and everything is waiting where you left it.
        </p>

        <h2>Affiliate links</h2>
        <p>
          Some gift suggestions link to Amazon and carry an affiliate tag, so we may earn a small commission on
          a purchase. This never changes the price you pay, and it never influences which ideas the app shows
          you. Anything you buy is a contract between you and the retailer.
        </p>

        <h2>Availability</h2>
        <p>
          We try to keep everything running, but we cannot promise the app or the sharing service will always
          be available or free of faults. Features can change or be withdrawn as the app develops. Keep a copy
          of anything you would be upset to lose.
        </p>

        <h2>Ending the agreement</h2>
        <p>
          You can stop at any time by deleting the app and, if you made one, asking us to close your account.
          We can suspend or close an account that breaks these terms, and will explain why unless the law
          prevents us.
        </p>

        <h2>Liability</h2>
        <p>
          Kudao is provided as it is. To the fullest extent the law allows, we are not liable for indirect or
          consequential loss, for a reminder that failed to arrive, or for a date you missed. Nothing here
          limits liability that cannot lawfully be limited, including for death, personal injury, or fraud.
          Some consumer rights in your country cannot be excluded and are unaffected by these terms.
        </p>

        <h2>Changes</h2>
        <p>
          If these terms change, the effective date at the top changes with them. Continuing to use Kudao after
          that means the new version applies.
        </p>

        <h2>Contact</h2>
        <p>
          <a href={`mailto:${SITE.supportEmail}`}>{SITE.supportEmail}</a>
        </p>
      </article>
    </SiteLayout>
  );
};

export default Terms;
