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

## Why YAML is Complex (40-60+ days)

YAML implementation is significantly more complex than INI:

- **Indentation-based syntax** (like Python) - complex state tracking
- **Minimal code reuse** from mojo-toml/mojo-ini
- **84-page specification** with many edge cases
- **Security concerns** (anchors/aliases can enable exploits)
- **Multiple syntax styles** (flow vs block)

**Recommendation:** Consider C library bindings (libyaml) instead of pure Mojo implementation.

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

## Alternative Approach

Instead of pure Mojo implementation, consider:

**Option 1:** Wait for Mojo FFI maturity, then bind to libyaml (C library)  
**Option 2:** Implement YAML subset (no anchors, explicit types only)  
**Option 3:** Focus on YAML writing only (simpler than parsing)

## Timeline (If Prioritized)

**Phase 1 (4-6 weeks):** Basic parser (block style, strings only)  
**Phase 2 (4-6 weeks):** Type inference, collections, flow style  
**Phase 3 (2-4 weeks):** Writer implementation  
**Phase 4 (2-3 weeks):** Anchors/aliases (optional)

**Total:** 12-19 weeks for feature-complete implementation

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
