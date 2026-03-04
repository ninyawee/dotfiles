---
name: frontend-patterns
description: Frontend development patterns — component composition, state management, data fetching, forms, and performance. Uses Svelte 5 as primary example.
origin: Ninyawee
---

# Frontend Development Patterns

## When to Activate

- Building UI components, managing state, data fetching, forms, or performance optimization

## Reactivity Decision Hierarchy

Prefer pure derivations over side effects:

1. **`$derived`** — computed values, no side effects
2. **Callbacks / function bindings** — `oninput`, `bind:value={get, set}`
3. **`watch` / `watch.pre`** (runed) — explicit reactive side effects
4. **`resource`** (runed) — watch + async fetch + loading/error state
5. **`onMount`** — one-time setup, subscriptions, DOM observers
6. **`$effect`** — LAST RESORT, must have explanatory comment

## State Management — Context + Class Stores

Prefer class-based stores with framework reactivity over global singletons.

```typescript
// Svelte 5 example with runed Context
class AuthState {
  user = $state<User | null>(null);
  isLoading = $state(true);
  get isAuthenticated() { return !!this.user; }
}
export const authContext = new Context<AuthState>('auth');
```

**Rules:**
- Classes hold reactive state and derived values; methods mutate internal state
- Immutable updates: `this.items = this.items.map(i => i.id === id ? { ...i, ...patch } : i)`
- Never mutate arrays/objects in place

## Component Patterns

- **Composition over inheritance** — small composable pieces, not deep hierarchies
- **Compound components** share state via runed `Context`
- **Snippets** for content projection (not slots)
- Many small files (200-400 lines, 800 max), organized by feature domain

## Data Fetching

- **Server-side**: framework load/loader functions with parallel fetches (`Promise.all`)
- **Client-side**: abort controllers for cancellable requests
- **Auth guard**: check session early, redirect if missing

```typescript
// Cancellable fetch pattern
this.abortController?.abort();
this.abortController = new AbortController();
try {
  const res = await fetch(url, { signal: this.abortController.signal });
  if (!res.ok) throw new Error('Load failed');
  return await res.json();
} catch (e) {
  if (e instanceof DOMException && e.name === 'AbortError') return;
  console.error(e);
}
```

## Forms

- Prefer **Valibot** for schema validation (smaller bundle, tree-shakeable). Zod acceptable for existing projects.
- Validate on both client and server
- Scroll to first error on submission failure

## Performance

- **Virtual scrolling** for long lists (Svelte 5: use [virtua](https://github.com/inokawa/virtua), not tanstack/virtual)
- **Debounced search** — debounce input, abort in-flight requests on new input
- **Code splitting / lazy loading** for heavy components
- **Memoize** expensive computations, not everything

## Date/Time

Prefer **date-fns** (tree-shakeable, immutable). Never hand-roll formatting — use date-fns inline where needed rather than wrapping in shared helpers.

## Key Principles

- Derived values over effects — always
- Immutable state updates — never mutate in place
- Abort controllers for cancellable fetches
- Composition over inheritance
- Many small files over few large files
- Framework-provided patterns over hand-rolled equivalents
