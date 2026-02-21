# Content Management System Integration

<!-- category: template -->

## Overview

Patterns for integrating headless CMS platforms: content modeling, rich text,
media, previews, localization, and admin customization.

## CMS Platform

[FILL: Payload CMS / Strapi / Sanity / Contentful / Directus]

### Selection Guidance

| Platform   | Type         | Database         | Self-hosted | Real-time |
|------------|------------- |------------------|-------------|-----------|
| Payload    | Code-first   | MongoDB/Postgres | Yes         | No        |
| Strapi     | Admin-first  | SQLite/PG/MySQL  | Yes         | No        |
| Sanity     | Schema-first | Hosted (GROQ)    | No          | Yes       |
| Contentful | GUI-first    | Hosted (GraphQL) | No          | No        |
| Directus   | DB-first     | Any SQL          | Yes         | Yes       |

## Content Modeling

```typescript
// Example: Blog post content type (Payload CMS style)
const Posts: CollectionConfig = {
  slug: 'posts',
  fields: [
    { name: 'title', type: 'text', required: true },
    { name: 'slug', type: 'text', unique: true, required: true },
    { name: 'author', type: 'relationship', relationTo: 'users' },
    { name: 'publishedAt', type: 'date' },
    { name: 'status', type: 'select', options: ['draft', 'published', 'archived'] },
    { name: 'content', type: 'richText' },
    { name: 'featuredImage', type: 'upload', relationTo: 'media' },
    { name: 'tags', type: 'relationship', relationTo: 'tags', hasMany: true },
  ],
};
```

- Define content types with explicit field validation and required markers
- Use relationships over embedded data for reusable entities (authors, categories)
- Add `slug` fields with auto-generation hooks for URL-friendly identifiers

## Rich Text Handling

- CMS rich text often arrives as structured JSON (Slate, ProseMirror, Portable Text)
- Write a renderer that maps each block/mark type to your frontend components
- Sanitize any raw HTML blocks to prevent XSS
- Support embedded media, code blocks, and internal links within rich text

```typescript
// Portable Text (Sanity) renderer example
import { PortableText } from '@portabletext/react';

const components = {
  types: {
    image: ({ value }) => <CmsImage src={value.asset} alt={value.alt} />,
    code: ({ value }) => <CodeBlock lang={value.language}>{value.code}</CodeBlock>,
  },
  marks: {
    internalLink: ({ value, children }) => <Link href={`/${value.slug}`}>{children}</Link>,
  },
};
```

## Media Management

- Use the CMS media library for uploads; serve via CDN with image transformations
- Request images at the size needed: `?w=800&q=80&fm=webp`
- Store alt text alongside every image at the content level
- Set upload size limits and allowed MIME types in CMS config

## Preview / Draft Mode

- Implement a secure preview endpoint protected by a shared secret token
- Enable Next.js draft mode (or framework equivalent) and redirect to the content page
- Fetch draft content conditionally based on preview state

## Webhooks for Revalidation

- Configure CMS webhooks to fire on content publish/unpublish/update
- Trigger ISR revalidation (`revalidatePath` / `revalidateTag`) on webhook receipt
- Verify webhook signatures to prevent unauthorized cache purges

## Admin UI & Localization

- Configure role-based access: editors, reviewers, admins
- Add workflow stages: draft -> in-review -> approved -> published
- Store translations per field, not per document (avoids content duplication)
- Fall back to default locale for untranslated fields
- Sync locale slugs for SEO (`/en/about`, `/fr/a-propos`)

## Common Pitfalls

- Over-nesting content models — keep structures flat and composable
- Not setting up preview mode — editors publish blind
- Ignoring webhook security — unauthenticated revalidation is a cache-busting vector
- Coupling frontend rendering tightly to CMS structure — use a mapping/adapter layer
