# Security Guidelines

## Mandatory Security Checks

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML)
- [ ] CSRF protection enabled
- [ ] Authentication/authorization verified
- [ ] Rate limiting on all endpoints
- [ ] Error messages don't leak sensitive data

## Secret Management with fnox

- NEVER hardcode secrets in source code
- Use `fnox` CLI for secret and variable management (preferred over raw env vars)
- Validate that required secrets are present at startup
- Rotate any secrets that may have been exposed

### fnox Usage

- `fnox exec -- [command]` to run commands with secrets injected
- `fnox list` to list available secrets
- Set variables: `fnox set --default [key] [value]`
- Set secrets: `echo [value] | fnox set [key]`
- AVOID `fnox get [key]` — exposes secrets in shell history. Use `fnox ls | grep [key]` to check existence instead
- Uses `age` backend for secret encryption
- Supports profiles (e.g. `[dev-name]`, `[env:prod,staging]`) for environment separation

### fnox Config Rules

- `.fnox.toml` goes at project root (git root) ONLY
- NEVER create `~/.fnox.toml` — no global config allowed
- Hierarchical config: secrets expose only to directories below the config file

### fnox Starter Template

Every project `.fnox.toml` MUST contain providers:

```toml
[providers.age]
type = "age"
recipients = ["age1jqy4r7lltng327m9wzwtrwcd9pkjpveafmv8cjhv2tymdmcg93vqrc3y4j"]

[secrets]
```

### Environment Documentation

- Maintain `.env.example` documenting all env vars for the project

## Security Response Protocol

If security issue found:
1. STOP immediately
2. Use **security-reviewer** agent
3. Fix CRITICAL issues before continuing
4. Rotate any exposed secrets
5. Review entire codebase for similar issues
