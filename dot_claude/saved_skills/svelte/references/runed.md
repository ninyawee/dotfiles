# Runed Utilities

## watch - Explicit Dependencies

Use `watch` over `$effect` for explicit dependency declaration:

```typescript
import { watch } from "runed";

let count = $state(0);

// Explicit: only runs when count changes
watch(() => count, (current, previous) => {
  console.log(`Changed from ${previous} to ${current}`);
});

// Deep object watching
let user = $state({ name: 'bob', age: 20 });
watch(() => $state.snapshot(user), () => {
  console.log(`${user.name} is ${user.age}`);
});

// Multiple sources
watch([() => age, () => name], ([age, name], [prevAge, prevName]) => {
  console.log('Changed');
});
```

Options: `{ lazy: true }` - delays initial callback until first change.

Variants: `watch.pre`, `watchOnce`, `watchOnce.pre`

## Context - Type-safe Context API

```typescript
import { Context } from "runed";

// Define context (e.g., in a shared module)
export const themeContext = new Context<"light" | "dark">("theme");

// Set in parent (during component init)
themeContext.set("dark");

// Get in child
const theme = themeContext.get();        // throws if not set
const theme = themeContext.getOr("light"); // fallback if not set
const exists = themeContext.exists();    // check if set
```

## PersistedState - LocalStorage/SessionStorage

```typescript
import { PersistedState } from "runed";

// Basic - persists to localStorage
const count = new PersistedState("count", 0);
count.current++;  // Auto-persisted

// With options
const state = new PersistedState("key", initialValue, {
  storage: "session",     // 'local' (default) or 'session'
  syncTabs: true,         // Cross-tab sync (default: true)
  connected: true,        // Start connected (default: true)
  serializer: {           // Custom serialization
    serialize: JSON.stringify,
    deserialize: JSON.parse
  }
});

// Control connection
state.disconnect(); // Remove from storage, keep in memory
state.connect();    // Re-enable persistence
```

## Debounced - Debounce State Changes

```typescript
import { Debounced } from "runed";

let search = $state("");
const debounced = new Debounced(() => search, 500); // 500ms delay

// Access debounced value
console.log(debounced.current);

// Methods
debounced.cancel();              // Cancel pending update
debounced.setImmediately(value); // Update immediately
await debounced.updateImmediately(); // Apply pending now
```

## Throttled - Throttle State Changes

```typescript
import { Throttled } from "runed";

let count = $state(0);
const throttled = new Throttled(() => count, 500); // Max once per 500ms

// Access throttled value
console.log(throttled.current);

// Methods
throttled.cancel();              // Cancel pending update
throttled.setImmediately(value); // Update immediately
```
