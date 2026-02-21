# React Patterns — Core Design Principles & Best Practices

<!-- category: universal -->

## Overview

Comprehensive React patterns, conventions, and best practices. This is a core skill (always installed) that covers universal React knowledge. The `react` template skill covers project-specific configuration.

## Component Design

### Composition over configuration
- Prefer composable components with children/render props over prop-heavy monoliths
- Use compound components for related UI (e.g., `<Tabs>`, `<Tabs.List>`, `<Tabs.Panel>`)
- Favor `children` over render props unless you need to pass data upward
- Split components when they exceed ~150 lines or handle more than one concern

### Component categories
| Type | Purpose | State | Examples |
|------|---------|-------|---------|
| **Presentational** | Render UI from props | None or local UI state | `Button`, `Card`, `Avatar` |
| **Container** | Orchestrate data + logic | Fetching, derived state | `UserProfile`, `Dashboard` |
| **Layout** | Structure and spacing | None | `PageLayout`, `Sidebar`, `Grid` |
| **Feature** | Full feature slice | All types | `AuthFlow`, `CheckoutWizard` |

### File organization
- One component per file, named same as the component: `UserCard.tsx`
- Colocate styles, tests, and types: `UserCard.module.css`, `UserCard.test.tsx`
- Use barrel exports (`index.ts`) only at feature boundaries, not per-component
- Group by feature, not by type: `features/auth/` not `components/`, `hooks/`, `utils/`

## Hooks

### Built-in hooks mastery
- `useState`: For simple local state. Use functional updates (`setCount(c => c + 1)`) when next state depends on previous
- `useReducer`: For complex state transitions, state machines, or when next state depends on multiple values
- `useEffect`: Synchronization only — NOT for derived data, NOT for event handlers. Always specify dependencies
- `useRef`: For DOM references and mutable values that don't trigger re-renders (timers, previous values)
- `useMemo`: Memoize expensive computations. Not needed for simple operations — profile first
- `useCallback`: Stabilize function identity for child component memoization. Only useful when child is wrapped in `React.memo`
- `useId`: Generate unique IDs for accessibility (label-input associations). Never use for keys
- `useDeferredValue` / `useTransition`: For non-urgent UI updates (search results, filtered lists)

### Custom hook patterns
- Extract repeated stateful logic into custom hooks: `useForm`, `useDebounce`, `useMediaQuery`
- Hooks should return a consistent shape: `[value, setter]` or `{ data, loading, error }`
- Name with `use` prefix — this is enforced by the Rules of Hooks
- Compose hooks from other hooks — avoid hooks that do too many things

### Rules of Hooks (non-negotiable)
- Only call hooks at the top level — never in loops, conditions, or nested functions
- Only call hooks from React functions — components or other custom hooks
- Dependencies array must be exhaustive — never lie about dependencies

## State Management

### State location decision tree
1. **Used by one component?** → `useState` / `useReducer`
2. **Shared by parent-child?** → Lift state up to common ancestor, pass via props
3. **Shared by distant components?** → Context (if reads are infrequent) or external store
4. **Server data?** → TanStack Query / SWR (NOT local state)
5. **URL state?** → URL search params via router
6. **Global UI state?** → Zustand, Jotai, or Context (small surface area)

### Context best practices
- Create focused contexts: `AuthContext`, `ThemeContext` — not `AppContext`
- Split read and write contexts to prevent unnecessary re-renders
- Memoize context values: `useMemo(() => ({ user, login, logout }), [user])`
- Context is NOT a state manager — it's a dependency injection mechanism

### Server state vs client state
- **Server state** (TanStack Query, SWR): Remote data with caching, refetching, optimistic updates
- **Client state** (useState, Zustand): UI state, form input, toggles, selections
- Never duplicate server state into client state — let the cache be the source of truth

## Rendering Optimization

### When to optimize
- **Don't optimize prematurely** — React is fast by default. Profile with React DevTools first
- **Symptoms that warrant optimization**: Visible jank, laggy input, slow list scrolling

### Techniques (in order of preference)
1. **Move state down**: State closer to where it's used means fewer re-renders
2. **Lift content up**: Pass unchanged JSX as `children` — it won't re-render when parent state changes
3. **React.memo**: Wrap components that receive stable props but re-render due to parent state changes
4. **useMemo / useCallback**: Stabilize references passed as props to memoized children
5. **Virtualization**: For long lists (>100 items), use `@tanstack/react-virtual` or `react-window`

### Keys
- Use stable, unique IDs from data — never array indices (causes bugs on reorder/delete)
- Never use `Math.random()` or `Date.now()` as keys
- Keys are per-sibling, not globally unique

## Data Fetching

### Patterns (modern React)
- **Server Components** (Next.js/RSC): Fetch in the component, `async/await`, zero client JS
- **TanStack Query**: Client-side with caching, deduplication, background refetch, optimistic updates
- **SWR**: Simpler alternative to TanStack Query, stale-while-revalidate pattern
- **fetch in useEffect**: Last resort — no caching, no deduplication, race condition prone

### Loading and error states
- Every data-fetching component needs: loading skeleton, error boundary, empty state
- Use `Suspense` boundaries for loading states — colocate with error boundaries
- Show stale data during refetch (stale-while-revalidate) rather than loading spinners

## Forms

- **Uncontrolled** (useRef, FormData): For simple forms — submit handler reads values once
- **Controlled** (useState per field): When you need real-time validation or derived UI
- **Form libraries** (React Hook Form, Formik): For complex forms with many fields, validation rules, dynamic fields
- Validate on blur and submit, not on every keystroke (unless providing search-as-you-type)
- Use native HTML validation attributes (`required`, `pattern`, `min`, `max`) as first line

## Error Handling

- **Error Boundaries**: Catch rendering errors — wrap at feature boundaries, not per-component
- Error boundaries don't catch: event handlers, async code, server-side, errors in the boundary itself
- Use `react-error-boundary` for declarative reset and fallback UI
- For async errors: handle in the fetching layer (TanStack Query `onError`, try/catch in event handlers)

## TypeScript Integration

- Define component props as interfaces: `interface UserCardProps { user: User; onEdit: (id: string) => void }`
- Use `React.FC` sparingly — prefer explicit return types or just `function UserCard(props: Props) {}`
- Discriminated unions for variant props: `type ButtonProps = { variant: 'primary'; icon: ReactNode } | { variant: 'ghost' }`
- Generic components: `function List<T>({ items, renderItem }: ListProps<T>)`
- Event handler types: `React.MouseEvent<HTMLButtonElement>`, `React.ChangeEvent<HTMLInputElement>`

## Accessibility in React

- Use semantic HTML elements (`<button>`, `<nav>`, `<dialog>`) — not `<div onClick>`
- Forward refs for custom components that wrap native elements
- `aria-label` for icon-only buttons, `aria-describedby` for form errors
- Focus management: `useRef` + `.focus()` for modals, drawers, route changes
- Keyboard: Enter/Space for buttons, Escape to close modals, Tab to navigate

## Testing React Components

- **Testing Library**: Test behavior, not implementation — `getByRole`, `getByText`, not `getByTestId`
- **User events**: `userEvent.click()` over `fireEvent.click()` — simulates real user interaction
- **Don't test**: Internal state, lifecycle methods, implementation details
- **Do test**: User-visible behavior, accessibility, error states, loading states
- **Snapshot tests**: Avoid — they break on every change and provide no insight

## Related Skills

- `react` — project-specific React configuration (template)
- `testing-principles` — universal testing patterns
- `ui-ux` — accessibility and design principles
- `nextjs-patterns` — Next.js-specific React patterns
