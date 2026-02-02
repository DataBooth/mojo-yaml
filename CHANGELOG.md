# Changelog

All notable changes to mojo-yaml will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Bumped MAX / Mojo toolchain dependency to `max ">=26.1.0,<27"` and updated recipes to pin `mojo_version = "=0.26.1"`.
- Updated the YAML lexer to use a cached `List[String]` buffer plus `codepoint_slices()` instead of direct `String` indexing, matching Mojo 0.26.1 string and `__getitem__` semantics while keeping behaviour identical.
- Adopted a "no warnings" policy for the core library and tests so future migrations surface only new issues.

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
