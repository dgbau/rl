# UI/UX — Universal Design Principles

<!-- category: universal -->

## Overview

Applies to any project with a user interface. Covers accessibility, color theory, typography, responsive design, interaction design, and design tokens.

## Accessibility (WCAG 2.2 AA)

- **Contrast**: Minimum 4.5:1 for normal text, 3:1 for large text (18px+ bold or 24px+) and UI components
- **Keyboard**: Full keyboard navigation; visible focus indicators on all interactive elements
- **Semantics**: Use semantic HTML (`<nav>`, `<main>`, `<button>`, `<dialog>`); ARIA labels only when HTML semantics are insufficient
- **Motion**: Respect `prefers-reduced-motion` — disable animations/transitions for users who request it
- **Color scheme**: Respect `prefers-color-scheme` for automatic dark/light mode
- **Navigation**: Skip-to-content links; proper heading hierarchy (no skipped levels: h1 → h2 → h3)
- **Forms**: Labels on every input; error messages associated via `aria-describedby`; no placeholder-only labels
- **Images**: Alt text on all meaningful images; decorative images use `alt=""`

## Color Theory

- Never rely on color alone to convey information — always pair with icons, text, or patterns
- Use HSL color model for design tokens (easier to reason about lightness/saturation)
- Establish palette: primary, secondary, accent, neutral, success, warning, error
- Test with colorblind simulation: protanopia (red-blind), deuteranopia (green-blind), tritanopia (blue-blind)
- Ensure sufficient contrast in both light and dark modes

## Typography

- Minimum 16px body text; never below 14px for any readable content
- Line height 1.4–1.6 for body text; tighter (1.1–1.2) for headings
- Max 2–3 font families; establish a modular type scale (e.g., 1.25 ratio)
- Line length: 45–75 characters per line for readability
- Use `font-display: swap` for web fonts to prevent invisible text during load

## Responsive Design

- **Mobile-first** approach — design for smallest screen, enhance upward
- Breakpoints: 320px (mobile), 768px (tablet), 1024px (desktop), 1440px (wide)
- Touch targets: minimum 44x44px with adequate spacing between targets
- Use container queries for component-level responsiveness where supported
- Test on real devices, not just browser devtools resize

## Interaction Design

- **Micro-interactions**: 100–300ms for feedback animations (hover, click, toggle)
- **Transitions**: 200–500ms for layout changes, page transitions
- **Immediate feedback**: Every user action should produce visible response within 100ms
- **States**: Loading, empty, error, success states for every data-dependent view
- **Optimistic UI**: Update immediately, reconcile with server response — but show clear error recovery on failure

## Design Tokens

- Single source of truth for colors, spacing, typography, shadows, border radii
- Use CSS custom properties or a design token system (Style Dictionary, Tailwind config)
- Dark mode as first-class concern — design both themes from the start, not as an afterthought
- Consistent spacing scale (e.g., 4px base: 4, 8, 12, 16, 24, 32, 48, 64)

## Related Skills

- `tailwind` — utility-first CSS implementation of these principles
- `react` — component patterns for accessible UIs
- `accessibility` — deeper accessibility patterns (if installed)
