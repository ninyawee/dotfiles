# Remote Functions

Server-side functions callable from anywhere. Enable in `svelte.config.js`:

```javascript
export default {
  kit: {
    experimental: { remoteFunctions: true }
  },
  compilerOptions: {
    experimental: { async: true }
  }
};
```

Place `*.remote.ts` files anywhere in `src/` (except `src/lib/server`).

## query - Fetch Data

```typescript
// src/lib/posts.remote.ts
import { query } from '$app/server';
import * as db from '$lib/server/database';

export const getPosts = query(async () => {
  return await db.sql`SELECT title, slug FROM post ORDER BY published_at DESC`;
});

// With validation (use valibot/zod)
export const getPost = query(v.string(), async (slug) => {
  const [post] = await db.sql`SELECT * FROM post WHERE slug = ${slug}`;
  if (!post) error(404, 'Not found');
  return post;
});
```

```svelte
{#each await getPosts() as post}
  <a href="/blog/{post.slug}">{post.title}</a>
{/each}
```

Refresh: `await getPosts().refresh();`

## query.batch - Solve N+1

```typescript
export const getWeather = query.batch(v.string(), async (cities) => {
  const weather = await db.sql`SELECT * FROM weather WHERE city = ANY(${cities})`;
  const lookup = new Map(weather.map(w => [w.city, w]));
  return (city) => lookup.get(city);
});
```

## form - Mutations with Forms

```typescript
export const createPost = form(
  v.object({
    title: v.pipe(v.string(), v.nonEmpty()),
    content: v.pipe(v.string(), v.nonEmpty())
  }),
  async ({ title, content }) => {
    const user = await auth.getUser();
    if (!user) error(401, 'Unauthorized');
    const slug = title.toLowerCase().replace(/ /g, '-');
    await db.sql`INSERT INTO post (slug, title, content) VALUES (${slug}, ${title}, ${content})`;
    redirect(303, `/blog/${slug}`);
  }
);
```

```svelte
<form {...createPost}>
  <input {...createPost.fields.title.as('text')} />
  {#each createPost.fields.title.issues() as issue}
    <p class="error">{issue.message}</p>
  {/each}
  <textarea {...createPost.fields.content.as('text')}></textarea>
  <button>Publish</button>
</form>
```

With enhancement:

```svelte
<form {...createPost.enhance(async ({ form, submit }) => {
  try {
    await submit().updates(getPosts());
    form.reset();
  } catch (e) {
    showToast('Failed');
  }
})}>
```

## command - Mutations without Forms

```typescript
export const addLike = command(v.string(), async (id) => {
  await db.sql`UPDATE item SET likes = likes + 1 WHERE id = ${id}`;
});
```

```typescript
// With optimistic update
await addLike(itemId).updates(
  getLikes(itemId).withOverride(n => n + 1)
);
```

## Access Request Context

```typescript
import { getRequestEvent, query } from '$app/server';

export const getProfile = query(async () => {
  const { cookies } = getRequestEvent();
  return await findUser(cookies.get('session_id'));
});
```
