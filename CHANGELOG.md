# Changelog

All notable changes to mojo-yaml will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Migrated workspace/runtime dependencies and recipe compiler pins to Mojo `1.0.0`.
- Updated source/tests/examples/packaging from legacy `fn` syntax and older imports to Mojo 1.0-compatible forms (`def`, `std.pathlib`, `std.math`, `std.python`).
- Reworked recursive `YamlValue` storage for Mojo 1.0 by boxing sequence/mapping members and implementing explicit deep-copy/deinit ownership handling.
- Fixed remaining Mojo 1.0 string API incompatibilities (`len(String)` and quoted-string bounds checks) in lexer/tests.
- Revalidated migration with `pixi run test-all` (all 15 suites passing) and `pixi run build-package` (success with warnings only).

**Status:** Ready for v0.1.0 release

## [0.1.0] - 2026-01-14

### Added
- **Core YAML parsing functionality** (reader-only)
  - Lexer with full tokenisation and indentation tracking (INDENT/DEDENT)
  - Recursive descent parser building nested YamlValue structures
  - Public `parse()` API for string-to-YamlValue conversion
  
- **Supported YAML Features** (~80% of common use cases)
  - ✅ Nested mappings (any depth)
  - ✅ Nested sequences (any depth)
  - ✅ Inline list-mappings: `- name: Alice\n  age: 30`
  - ✅ All scalar types: int, float, bool, null, string
  - ✅ Comments anywhere
  - ✅ Mixed nested structures

- **Type-Safe Value Access**
  - `YamlValue` variant type (7 types: null, bool, int, float, string, sequence, mapping)
  - Safe accessors: `.as_string()`, `.as_int()`, `.as_float()`, `.as_bool()`
  - Navigation: `.get(key)`, `.get_at(index)`
  - Type checking: `.is_null()`, `.is_mapping()`, etc.

- **Test Coverage**
  - 91/91 tests passing (100%)
  - Real-world fixture testing
  - Comprehensive test suite

- **Documentation**
  - COMPATIBILITY.md with feature matrix
  - Working example fixtures
  - Inline code documentation

### Known Limitations
- ⚠️ Multi-word strings must be quoted
- ⚠️ Version numbers must be quoted (e.g., `"0.1.0"`)
- ❌ Flow-style not supported: `[1, 2]`, `{a: b}`
- ❌ Empty values not supported
- ❌ No anchors/aliases, multi-document, literal blocks
- ❌ Reader-only (no writer)

### Fixed
- Inline list-mapping continuation patterns
- Comment token handling throughout parser
- Indentation tracking with proper INDENT/DEDENT

### Technical Details
- Pure Mojo (0.26.1+), zero Python dependencies
- ~1,500 LOC (lexer: 485, parser: 290, value: 290)
- Three-component architecture

[0.1.0]: https://github.com/databooth/mojo-yaml/releases/tag/v0.1.0
