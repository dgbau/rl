# Shopify Integration Skill

<!-- category: template -->

## Overview
Shopify provides commerce infrastructure for online stores, supporting both
traditional theme development (Liquid) and modern headless commerce via Hydrogen
(React/Remix framework) and the Storefront API. Shopify also supports custom app
development and backend logic via Shopify Functions.
[FILL: How Shopify is used in THIS project -- theme, headless, app, or hybrid]

## Integration Approach

| Approach             | When to Use                              | Framework  |
|----------------------|------------------------------------------|------------|
| Hydrogen + Oxygen    | Full headless, React, Shopify-hosted     | Remix      |
| Headless (custom)    | Headless with your own framework         | Any        |
| Theme (Liquid)       | Traditional storefront, theme store       | Liquid     |
| Shopify App          | Extending admin, checkout, or POS        | Remix      |

- Approach used: [FILL: Hydrogen / Custom Headless / Theme / App]

## Hydrogen (Headless React Framework)

- Built on Remix; deployed to Oxygen (Shopify's edge hosting) or self-hosted
- Uses Shopify's Storefront API (GraphQL) for all data fetching
- Streaming SSR for fast initial page loads
- [FILL: Hydrogen version, deployment target]
- [FILL: Path to hydrogen.config.ts or remix entry]

## Storefront API (GraphQL)

- Public API for reading products, collections, cart, and customer data
- Requires Storefront Access Token (public, safe for client-side)
- Key queries: `products`, `collections`, `cart`, `customer`
- Key mutations: `cartCreate`, `cartLinesAdd`, `customerAccessTokenCreate`
- Rate limits: 50 cost points per second (calculated query cost)
- [FILL: Storefront API version used -- e.g., 2024-07]

## Admin API

- Private API for managing products, orders, inventory, customers
- Requires Admin API Access Token (secret, server-side only)
- REST and GraphQL variants available; prefer GraphQL for new development
- Rate limits: 50 points/second (GraphQL), 2 requests/second (REST) per app
- [FILL: Admin API usage -- product sync, order management, inventory updates]

## Theme Development (Liquid)

- Liquid is Shopify's templating language (similar to Jinja/Twig)
- Theme structure: `layout/`, `templates/`, `sections/`, `snippets/`, `assets/`
- Sections and blocks enable merchant-customizable pages via the theme editor
- Shopify CLI: `shopify theme dev` for local development with hot reload
- [FILL: Theme name, key customizations, custom sections developed]

## Checkout Customization

- Checkout UI Extensions: React components rendered in Shopify's checkout
- Checkout Branding API: Colors, fonts, logos without code
- Shopify Functions: Backend logic for discounts, shipping, payment customization
- [FILL: Checkout customizations in this project]

## Shopify Functions (Backend Logic)

- Lightweight WebAssembly modules that run on Shopify's infrastructure
- Use cases: custom discounts, shipping rates, payment gateways, validation
- Written in Rust (recommended), JavaScript, or any language that compiles to Wasm
- Input/output defined by Shopify's Function API schemas
- [FILL: Functions implemented and their purpose]

## Metafields & Metaobjects

- **Metafields**: Custom data attached to products, variants, orders, customers, etc.
- **Metaobjects**: Standalone custom content types (like a lightweight CMS)
- Define schemas in Shopify admin or via API
- Access in Storefront API via metafield queries
- [FILL: Custom metafields/metaobjects defined and their purpose]

## App Development

- Shopify apps extend admin functionality, checkout, POS, or customer accounts
- Built with Remix + `@shopify/shopify-app-remix` package
- App Bridge for embedding UI in Shopify admin
- OAuth flow handled by the app package
- Webhooks: Register via `shopify.config.ts`, handle in action functions
- [FILL: App purpose, embedded vs standalone, key features]

## Cart & Checkout Flow

- Cart API: Client-side cart management (add, update, remove lines)
- Checkout: Redirect to Shopify's hosted checkout or use Checkout Extensions
- [FILL: Cart implementation -- Storefront API Cart, Ajax API, or custom]
- [FILL: Post-purchase flow -- thank you page, order status page]

## Development Workflow

- Shopify CLI: `shopify theme dev`, `shopify app dev`, `shopify hydrogen dev`
- Use development store (free) for testing
- Preview deployments: [FILL: Staging strategy -- preview themes, dev stores]
- [FILL: How to seed test data -- products, orders, customers]

## Where to Look

- Storefront queries: [FILL: Path to GraphQL queries/fragments]
- Components: [FILL: Path to product, collection, cart components]
- Shopify config: [FILL: Path to shopify.config.ts or theme config]
- Theme files: [FILL: Path to Liquid templates if applicable]
- Docs: https://shopify.dev, https://shopify.dev/docs/api/storefront

## Common Pitfalls

- Storefront API rate limits are query-cost based, not request-count based
- Liquid has no debugger; use `{{ variable | json }}` for inspection
- Hydrogen/Remix caching must be configured explicitly for performance
- Metafield namespaces must be unique per app to avoid collisions
- [FILL: Project-specific gotchas encountered]
