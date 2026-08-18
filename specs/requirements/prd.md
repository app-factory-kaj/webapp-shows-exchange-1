# Exchange Rate Lookup — PRD

## Problem Statement

People who deal with foreign currency — travelers, online shoppers, freelancers billing overseas clients — often need to quickly know what a given currency is worth against the US Dollar. Today they resort to general web searches or bank pages that are cluttered with unrelated financial products, making a simple "what is 1 EUR in USD right now" question slower to answer than it should be.

## Solution

A focused single-page webapp where a signed-in user selects a currency and immediately sees its current exchange rate to USD. The experience is intentionally narrow: one currency, one rate, updated daily — no dashboards, no history, no clutter.

## Actors

- **User** — any visitor who selects a currency and views its current exchange rate to USD. No account or sign-in is required.

## User Stories

1. As a User, I want to open the app without creating an account or signing in, so that I can quickly check a rate with no friction.
2. As a User, I want to search for or select a currency from a list of supported currencies, so that I can find the one I care about.
3. As a User, I want to see the current exchange rate of my selected currency to USD, so that I know what it's worth right now.
4. As a User, I want to see when the displayed rate was last updated, so that I know how current the information is.

## Product Decisions

- The app is publicly accessible with no sign-in or account required — overriding the organization's default of signing every web app's users in via SSO.
- The core experience is a single-currency lookup, not a multi-currency dashboard — the user picks one currency at a time and sees its rate to USD.
- Only the current rate is shown; no historical trend or charting is in scope for this phase.
- The app is stateless with respect to user preferences — no favorites or saved/pinned currencies.
- Exchange rate data is refreshed daily rather than in near real-time, keeping the data dependency simple and inexpensive.
- The product depends on an external exchange-rate data capability to source daily rates; the specific provider is chosen at design time.

## Phasing

- **Phase 1 — Deliver a single-currency, daily-refreshed exchange rate lookup tool**: no-signin access, currency selection, and current-rate display, all in one narrow flow. Stories: 1, 2, 3, 4.

## Out of Scope

- Multi-currency dashboards or side-by-side comparisons.
- Historical trend charts or rate-over-time views.
- Per-user favorites, watchlists, or saved currencies.
- Real-time or intraday rate updates.
- Currency conversion of arbitrary amounts (e.g. "convert 50 EUR to USD") beyond showing the unit rate — may be considered later but is not part of this phase.

## Open Questions

None at this time.