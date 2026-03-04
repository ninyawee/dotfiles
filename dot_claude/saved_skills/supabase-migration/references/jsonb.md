# JSONB Patterns

Use for flexible, semi-structured data. MUST validate via application-side schema.

**When to use:**
- User preferences/settings
- API response caching
- Dynamic form data
- Metadata that varies per record

**When NOT to use:**
- Data queried/filtered frequently
- Referential integrity needed
- Aggregations required

## App-side Validation (REQUIRED)

```typescript
// Zod (TypeScript)
const UserSettingsSchema = z.object({
  theme: z.enum(['light', 'dark']).default('light'),
  notifications: z.object({
    email: z.boolean().default(true),
    push: z.boolean().default(false),
  }),
});
```

```python
# Pydantic (Python)
class UserSettings(BaseModel):
    theme: str = "light"
    notifications: dict = {"email": True, "push": False}
```

## Database Constraint (OPTIONAL)

```sql
ALTER TABLE tb_users ADD CONSTRAINT chk_settings_valid
    CHECK (jsonb_typeof(settings) = 'object');
```
