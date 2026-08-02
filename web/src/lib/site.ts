/**
 * Single source of truth for the facts repeated across the legal pages.
 *
 * Every value here is checked against the iOS codebase. If something changes in
 * the app — a new permission, a new processor — change it here first, then make
 * sure the privacy policy body still tells the truth.
 */

export const SITE = {
  appName: "Kudao",
  platform: "iPhone, iOS 18 or later",
  supportEmail: "gourbergnine07@gmail.com",
  effectiveDate: "2 August 2026",
  copyright: "© 2026 Kudao",
  responseWindow: "within 3 working days",
} as const;

/** Third parties that can receive data, and exactly why. */
export const PROCESSORS: readonly { name: string; role: string; policy: string }[] = [
  {
    name: "Apple",
    role: "Handles every payment, subscription renewal and refund. Kudao never sees your card.",
    policy: "https://www.apple.com/legal/privacy/",
  },
  {
    name: "RevenueCat",
    role: "Tells the app whether your subscription is active. Receives an anonymous purchase identifier.",
    policy: "https://www.revenuecat.com/privacy",
  },
  {
    name: "Supabase",
    role: "Stores your account, your encrypted backup and shared party galleries — only if you turn them on.",
    policy: "https://supabase.com/privacy",
  },
  {
    name: "Cloudflare",
    role: "Runs the invitation links that let someone join a plan you shared.",
    policy: "https://www.cloudflare.com/privacypolicy/",
  },
  {
    name: "Google AdMob",
    role: "Serves the banner ads that fund the free version. Never shown to subscribers.",
    policy: "https://policies.google.com/privacy",
  },
  {
    name: "Amazon",
    role: "Receives nothing from us. Gift links open in your browser with an affiliate tag attached.",
    policy: "https://www.amazon.com/privacy",
  },
] as const;

/** iOS permissions the app can ask for, and what each one is actually used for. */
export const PERMISSIONS: readonly { name: string; use: string }[] = [
  {
    name: "Contacts",
    use: "Reads birthdays already saved on your phone so you can create a profile without typing. The contact list is never uploaded.",
  },
  {
    name: "Photos",
    use: "Adds pictures you pick to a profile or a party gallery.",
  },
  {
    name: "Camera and microphone",
    use: "Takes photos and records video of the party, when you choose to.",
  },
  {
    name: "Location",
    use: "Finds gift shops near you. Your position is used for that search and never stored.",
  },
  {
    name: "Face ID",
    use: "Locks profiles kept in surprise mode, so the person cannot read them from your phone.",
  },
  {
    name: "Notifications",
    use: "Reminds you before a date and nudges you to write a note. Reminders are scheduled on the device.",
  },
] as const;
