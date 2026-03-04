# README Template

Example README structure based on ninyawee's projects.

## Template

```markdown
# Project Name

Thai Name (ชื่อไทย) — Short description in English

[![PyPI](https://img.shields.io/pypi/v/PACKAGE)](https://pypi.org/project/PACKAGE/)
[![Documentation](https://img.shields.io/badge/docs-ninyawee.github.io%2FREPO-blue)](https://ninyawee.github.io/REPO)

**[Documentation](https://ninyawee.github.io/REPO)** | **[GitHub](https://github.com/ninyawee/REPO)**

---

## Features

- Feature one
- Feature two
- Feature three

---

## Packages

| Language | Package | Install |
|----------|---------|---------|
| Python | [packages/pkg-python](./packages/pkg-python) | `pip install pkg` |
| Node.js | [packages/pkg-node](./packages/pkg-node) | `npm install pkg` |
| Rust | [packages/pkg](./packages/pkg) | `cargo add pkg` |

---

## Installation

\`\`\`bash
pip install package-name
\`\`\`

---

## Quick Start

\`\`\`python
from package import function

result = function("input")
print(result)
\`\`\`

---

## Usage

### Feature One

\`\`\`bash
command subcommand --option value
\`\`\`

### Feature Two

\`\`\`python
from package import feature_two

feature_two.do_thing()
\`\`\`

---

## Development

Uses [mise](https://mise.jdx.dev/) for task running.

\`\`\`bash
mise run test          # Run all tests
mise run build         # Build all packages
mise run docs:serve    # Preview docs locally
\`\`\`

---

## Support

[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support%20me%20☕-ff5f5f?logo=ko-fi&logoColor=white)](https://ko-fi.com/ninyawee)

---

## License

MIT / ISC / Apache-2.0
```

## Thai Project Variant

For Thai-focused projects, add bilingual elements:

```markdown
# ชื่อโปรเจค (Project Name)

**คำอธิบายภาษาไทย** — English description

## ✨ ฟีเจอร์ (Features)

- รองรับ XXX (Supports XXX)
- ใช้งานง่าย (Easy to use)

## การติดตั้ง (Installation)

## การใช้งาน (Usage)

## ☕ สนับสนุน (Support)
```
