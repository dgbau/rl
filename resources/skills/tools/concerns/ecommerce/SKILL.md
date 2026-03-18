# E-Commerce

<!-- category: template -->

## Overview

Patterns for building e-commerce applications: product catalog, cart, checkout,
orders, payments, and compliance.

## Payment Integration

[FILL: Stripe / Square / Braintree / Adyen / Shopify Payments]

## Product Catalog

```typescript
interface Product {
  id: string;
  slug: string;
  name: string;
  description: string;
  images: { url: string; alt: string }[];
  variants: Variant[];
  category: string[];
  metadata: Record<string, string>;
  status: 'draft' | 'active' | 'archived';
}

interface Variant {
  id: string;
  sku: string;
  name: string;            // e.g., "Large / Blue"
  price: number;           // Store in smallest currency unit (cents)
  compareAtPrice?: number; // Strikethrough price
  inventory: number;
  attributes: Record<string, string>; // size, color, etc.
}
```

- Store prices as integers in smallest currency unit (cents) to avoid floating point errors
- Use slugs for SEO-friendly URLs; ensure uniqueness
- Support draft/active/archived lifecycle for content management

## Cart Management

```typescript
// Server-side cart (recommended for reliability)
interface Cart {
  id: string;
  items: CartItem[];
  createdAt: Date;
  expiresAt: Date; // Auto-expire abandoned carts (e.g., 30 days)
}

interface CartItem {
  variantId: string;
  quantity: number;
  price: number; // Snapshot price at time of add
}
```

- Validate inventory at add-to-cart AND at checkout (race conditions exist)
- Re-validate prices at checkout — cart price may be stale
- Support guest carts that merge on login

## Checkout Flow

1. **Cart review** — show items, quantities, subtotal
2. **Shipping info** — address form with validation, address autocomplete
3. **Shipping method** — calculate rates from carrier APIs or flat rates
4. **Payment** — collect payment via provider's hosted fields (PCI scope reduction)
5. **Review & confirm** — final total with tax, place order
6. **Confirmation** — order ID, email confirmation, clear cart

- Use idempotency keys for payment requests to prevent double charges
- Never store raw card numbers; use tokenized payment methods

## Order Lifecycle

```
pending -> confirmed -> fulfilled -> shipped -> delivered
                    \-> cancelled    \-> returned
```

- Each transition should emit an event (for emails, webhooks, analytics)
- Store complete order snapshot (prices, addresses) — do not reference mutable product data
- Generate sequential human-readable order numbers separate from database IDs

## Inventory Management

- **Optimistic**: decrement on order placement, restore on cancellation
- **Pessimistic**: reserve on add-to-cart with TTL, release on expiry
- Use atomic decrements: `UPDATE ... SET stock = stock - 1 WHERE stock > 0`

## Tax, Shipping & PCI

- Use tax APIs (TaxJar, Avalara) — never hardcode rates; rules vary by jurisdiction
- Calculate shipping via carrier APIs (EasyPost, Shippo) or zone-based flat rates
- Use hosted payment fields (Stripe Elements, Braintree Drop-in) for SAQ A eligibility
- Never log, store, or transmit raw card numbers through your servers

## Common Pitfalls

- Floating point math for currency (use integer cents)
- Not re-validating prices/inventory at checkout time
- Missing idempotency keys on payment calls causing double charges
- Storing mutable product references in orders instead of snapshots
