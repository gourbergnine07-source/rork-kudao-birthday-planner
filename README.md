# Kudao

Kudao remembers the people who matter and helps you show up for them: birthdays,
anniversaries, weddings and remembrances, each with a countdown, a plan, a shared
diary and a gallery of what actually happened.

Native iOS app written in SwiftUI, with a Cloudflare Worker for invitations and a
Supabase project for the shared party gallery.

## What is in this repository

| Folder | What it holds |
| --- | --- |
| `ios-kudao/` | The iOS app (Xcode project, Swift 6, SwiftUI, SwiftData) and the Home Screen widget |
| `functions/` | Cloudflare Worker + Durable Objects that mint invite codes and host each share room |
| `backend/` | Supabase artefacts for the shared gallery (Postgres + Storage) |

Inside `ios-kudao/Kudao/`:

- `Models/` — SwiftData models: profiles, party plans, diary entries, event history
- `Views/` — one screen per file, plus reusable pieces in `Views/Components/`
- `Services/` — subscriptions, ads, notifications, sharing, backup, suggestions, contacts import
- `Utilities/` — palette, settings, small helpers
- `Localization/` — every user-facing string in Italian, English, French and Spanish

## Requirements

- Xcode 26 or newer (the project uses `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- iOS 18.0 minimum deployment target
- Swift package dependencies are resolved automatically: Supabase, RevenueCat, Google Mobile Ads

## Building

```bash
open ios-kudao/Kudao.xcodeproj
```

Or from the command line, without code signing:

```bash
xcodebuild build \
  -project ios-kudao/Kudao.xcodeproj \
  -target Kudao \
  -sdk iphonesimulator \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO
```

## Configuration

Secrets are never committed. A build phase runs `ios-kudao/Scripts/generate-env-config.sh`,
which rewrites `Kudao/Utilities/EnvConfig.swift` from the platform-generated
`Kudao/Config.swift`, stripping any invisible character that would break the compiler.
Read values through `Config.KEY_NAME`.

Keys currently used: Supabase URL and anon key, RevenueCat API keys, AdMob unit IDs,
the Amazon Associates tag per market, and the Worker base URL.

## How the app is put together

- **State** — SwiftData for everything the user writes; `@Observable` services in the
  environment for the rest. No global stores.
- **Localization** — a single `Strings` struct with one table per language. The device
  language decides; Italian is the fallback. The globe menu on Home switches it.
- **Monetization** — birthdays and remembrances are free forever and never show ads inside
  a remembrance. Weddings and other events need a subscription (RevenueCat, monthly or
  yearly). The free tier carries discreet AdMob banners, never while writing.
- **Privacy** — profiles, diary and photos stay on the device unless the user invites
  someone or turns on backup. The in-app screen `Settings > Privacy information` says the
  same thing in the user's language, and `Kudao/PrivacyInfo.xcprivacy` declares it to Apple.
- **Nothing sends itself** — greetings, invitations and messages always wait for a final tap.

## Continuous integration

`.github/workflows/ios-build.yml` builds the app for the iOS Simulator on every push and
pull request that touches `ios-kudao/`, with signing disabled. It is a compile check, not a
release pipeline: TestFlight builds are produced and uploaded separately.
