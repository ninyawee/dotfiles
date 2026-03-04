---
name: svelte
description: "Svelte and SvelteKit development. Use when building Svelte components or SvelteKit applications."
---

# Svelte Development

## Conventions

- **MUST use Remote Functions** (`*.remote.ts`) over `+page.server.ts` for server communication
- **MUST use runed** utilities for reactivity patterns

## References

- `references/remote-functions.md` - query, form, command patterns
- `references/runed.md` - watch, Context, PersistedState, Debounced, Throttled
