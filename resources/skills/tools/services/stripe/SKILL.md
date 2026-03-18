# Stripe Integration Skill

<!-- category: template -->

## Overview
Stripe provides payment processing, subscription management, and financial
infrastructure. Integration patterns vary significantly based on whether you need
one-time payments, recurring subscriptions, marketplace payouts, or custom
checkout flows.
[FILL: How Stripe is used in THIS project -- products, pricing model, checkout flow]

## Integration Pattern

- **Checkout Sessions** (hosted): Redirect to Stripe's hosted page. Lowest effort,
  highest conversion, PCI SAQ A (simplest compliance).
- **Stripe Elements** (embedded): Embed payment fields in your UI. More control,
  PCI SAQ A-EP.
- **Payment Intents** (custom): Full control of the payment flow. Use when Elements
  doesn't fit.
- Pattern used: [FILL: Checkout / Elements / Payment Intents]
- Stripe SDK version: [FILL: stripe npm/pip/gem package version]

## Server-Side Setup

- Stripe secret key: stored in environment variable, NEVER in client code
- API version: [FILL: e.g., 2024-06-20 -- pin this, don't use latest]
- Stripe client initialization: [FILL: Path to Stripe client setup]
- [FILL: Language/framework -- Node.js, Python, Ruby, Go, etc.]

## Webhook Handling

- Webhook endpoint: [FILL: Path to webhook handler -- e.g., /api/webhooks/stripe]
- **Signature verification is mandatory**: Use `stripe.webhooks.constructEvent()`
  with your webhook signing secret. Never trust unverified payloads.
- Critical events to handle:
  - `checkout.session.completed` -- payment succeeded
  - `invoice.payment_succeeded` -- subscription renewed
  - `invoice.payment_failed` -- payment failed, trigger dunning
  - `customer.subscription.deleted` -- subscription canceled
  - [FILL: Additional events handled in this project]
- Webhook handlers must be idempotent (same event delivered multiple times)
- Return 200 quickly; do heavy processing asynchronously

## Idempotency Keys

- Use idempotency keys on ALL mutating API calls (create charge, create customer)
- Pass via `Idempotency-Key` header or SDK option
- Use a deterministic key derived from the operation (e.g., `order_{orderId}_payment`)
- [FILL: Idempotency key strategy used in this project]

## Test Mode vs Live Mode

- Use `sk_test_*` keys in development, `sk_live_*` in production
- Test card numbers: `4242424242424242` (success), `4000000000000002` (decline)
- Stripe CLI for local webhook testing: `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
- [FILL: How test/live mode switching is managed -- env vars, config]

## Subscriptions

- Subscription lifecycle: `trialing` -> `active` -> `past_due` -> `canceled` / `unpaid`
- Billing portal: [FILL: Using Stripe's hosted portal or custom UI]
- Proration: [FILL: How plan upgrades/downgrades handle prorated charges]
- Trial periods: [FILL: Trial configuration, conversion tracking]
- [FILL: Subscription plans/products defined in this project]

## Stripe Connect (Marketplaces)

- [FILL: Whether Connect is used -- Standard, Express, or Custom accounts]
- [FILL: Payment flow -- direct charges, destination charges, or separate charges and transfers]
- [FILL: Onboarding flow for connected accounts]
- Skip this section if not applicable.

## PCI Compliance

- **SAQ A**: Stripe Checkout (hosted page) -- card data never touches your servers
- **SAQ A-EP**: Stripe Elements -- card fields are iframes, but your page hosts them
- Never log, store, or transmit raw card numbers
- [FILL: Compliance level for this project]

## Error Handling

- Catch `StripeError` types: `CardError`, `RateLimitError`, `InvalidRequestError`,
  `AuthenticationError`, `APIConnectionError`
- Surface user-friendly messages for `CardError` (decline codes)
- Retry with exponential backoff for `RateLimitError` and `APIConnectionError`
- [FILL: Error handling patterns and user-facing error messages]

## Metadata & Tracking

- Use Stripe `metadata` fields on Customers, Subscriptions, and PaymentIntents
  to store your internal IDs (userId, orderId, planId)
- This enables reconciliation and debugging without cross-referencing databases
- [FILL: Metadata fields used in this project]

## Where to Look

- Stripe client setup: [FILL: Path to Stripe initialization]
- Webhook handler: [FILL: Path to webhook route]
- Checkout/payment flow: [FILL: Path to payment-related pages/components]
- Product/price config: [FILL: Defined in Stripe Dashboard or via API/seed script]
- Docs: https://stripe.com/docs, https://stripe.com/docs/api

## Common Pitfalls

- Webhook signature verification failures (wrong signing secret, body parsing issues)
- Not handling `past_due` subscription state causes users to lose access silently
- Using floating-point for currency amounts (Stripe uses integers in cents)
- [FILL: Project-specific gotchas encountered]
