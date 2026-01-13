# mojo-yaml 🔥

> ⚠️ **PLACEHOLDER REPOSITORY** - This is a future project placeholder. Active development has NOT started.
> 
> **Current Status:** Planning / Not Yet Implemented  
> **Priority:** Low - [mojo-ini](https://github.com/databooth/mojo-ini) takes precedence
>
> This repository reserves the namespace and documents the planned scope. See [Why YAML is complex](#why-yaml-is-complex-40-60-days) below for context on implementation effort.

**YAML file parser and writer for Mojo** - Planned future implementation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Mojo](https://img.shields.io/badge/Mojo-🔥-orange)](https://www.modular.com/mojo)
[![Status](https://img.shields.io/badge/Status-Planning-yellow)](https://github.com/DataBooth/mojo-yaml)

Parse and write YAML configuration files in native Mojo with zero Python dependencies.

## Status: 🚧 Placeholder - Not Yet Implemented

This repository is a **placeholder** for future YAML support. No code has been implemented yet.

**Active projects:**
- ✅ [mojo-toml](https://github.com/databooth/mojo-toml) - TOML 1.0 parser/writer (v0.5.0 released)
- ✅ [mojo-dotenv](https://github.com/databooth/mojo-dotenv) - Environment variables (stable)
- 🚧 [mojo-ini](https://github.com/databooth/mojo-ini) - INI parser/writer (v0.1.0 in development)
- 📋 **mojo-yaml** - Future (this repository)

## Why Full YAML is Complex (40-60+ days)

Full YAML 1.2 implementation is significantly more complex than INI:

- **Indentation-based syntax** (like Python) - complex state tracking
- **Minimal code reuse** from mojo-toml/mojo-ini
- **84-page specification** with many edge cases
- **Security concerns** (anchors/aliases can enable exploits)
- **Multiple syntax styles** (flow vs block)

**Strategy:** Start with **YAML Lite** subset (8-11 weeks) covering 90% of real-world use cases, then consider extensions.

## Planned Features (If Implemented)

- ⏳ **YAML 1.2 Parser** - Read YAML files
- ⏳ **YAML Writer** - Write YAML files
- ⏳ **Indentation handling** - Block style syntax
- ⏳ **Basic types** - Strings, numbers, booleans, null
- ⏳ **Collections** - Sequences and mappings
- ⏳ **Subset implementation** - Core features only (no anchors/aliases initially)

## Hypothetical API (Not Implemented)

```mojo
from yaml import parse, dump

# Parse YAML
var data = parse("""
server:
  host: localhost
  port: 8080
database:
  name: mydb
  user: admin
""")

# Access nested data
print(data["server"]["host"])  # "localhost"

# Write YAML
var output = dump(data)
```

## Implementation Challenges

**Indentation parsing** - YAML relies on whitespace for structure  
**Anchors & Aliases** - `&anchor` and `*reference` syntax adds complexity  
**Multiple syntaxes** - Flow style `{key: value}` vs block style  
**Type inference** - Implicit typing (bare words, dates, etc.)  
**Security** - Arbitrary code execution risks in some YAML parsers

## Planned Approach: YAML Lite

Instead of implementing full YAML 1.2, start with a **practical subset** covering 90% of common use cases:

### YAML Lite Scope (v0.1.0)

**✅ Supported:**
- Block style mappings (key: value)
- Nested structures via indentation
- Sequences (- item)
- Strings (quoted and unquoted)
- Basic types: strings, numbers, booleans, null
- Comments (#)

**❌ Not Supported Initially:**
- Anchors & aliases (&anchor, *reference)
- Flow style ({key: value}, [1, 2, 3])
- Multi-document streams (---)
- Complex types (dates, timestamps)
- Tag directives (%TAG, %YAML)

### Example: Parse .pre-commit-config.yaml

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
```

This covers most config files (pre-commit, GitHub Actions, Docker Compose, etc.)

## Alternative Approaches (Later)

**Option 1:** Wait for Mojo FFI maturity, then bind to libyaml (C library)  
**Option 2:** Extend YAML Lite with flow style and anchors  
**Option 3:** Full YAML 1.2 compliance (12-19 weeks)

## Timeline (If Prioritized)

### YAML Lite (Recommended)
**Phase 1 (3-4 weeks):** Block style parser (mappings, sequences)  
**Phase 2 (2-3 weeks):** Type inference (strings, numbers, booleans)  
**Phase 3 (2-3 weeks):** Writer implementation  
**Phase 4 (1 week):** Real-world testing (.pre-commit-config.yaml, etc.)

**YAML Lite Total:** 8-11 weeks (covers 90% of use cases)

### Full YAML 1.2 (Optional Later)
**Phase 5 (3-4 weeks):** Flow style syntax  
**Phase 6 (2-3 weeks):** Anchors & aliases  
**Phase 7 (1-2 weeks):** Multi-document streams  

**Full YAML Total:** 14-20 weeks

## Not Planned (Currently)

No active development is scheduled. This repository serves as namespace reservation and design document.

## Documentation

- [CHANGELOG.md](CHANGELOG.md) - Version history and changes
- [docs/planning/](docs/planning/) - Technical documentation and design docs
- [examples/](examples/) - Usage examples

## Related Projects

- [mojo-toml](https://github.com/databooth/mojo-toml) - TOML 1.0 parser/writer for modern configs
- [mojo-dotenv](https://github.com/databooth/mojo-dotenv) - Environment variable management

Together these provide comprehensive configuration file support for Mojo! 🎯

## Contributing

Contributions welcome! Please:
1. Follow existing code style (see mojo-toml for reference)
2. Add tests for new features
3. Update documentation
4. Use Australian English for docs, US spelling for code

## License

MIT License - see [LICENSE](LICENSE) file for details

---

Made with 🔥 by [DataBooth](https://github.com/databooth)
