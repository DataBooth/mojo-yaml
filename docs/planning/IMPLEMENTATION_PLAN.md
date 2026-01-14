# Implementation Plan: mojo-yaml Lite v0.1.0

## Problem Statement
Create a practical YAML parser for Mojo that covers ~80% of real-world use cases (configuration files like .pre-commit-config.yaml, GitHub Actions, Docker Compose) with read-first focus. Skip complex features (anchors/aliases, flow style, multi-document) that add significant complexity but have limited use in config files.

## Current State
**Project Structure:** ✅ Complete
- pixi.toml environment configured
- Basic src/yaml/__init__.mojo skeleton
- Example fixtures in fixtures/yaml_lite_example.yaml
- Test infrastructure ready (no test files yet)
- CI/CD workflows (.github/workflows/)

**No Implementation Yet:**
- No lexer.mojo (needs creation)
- No parser.mojo (needs creation)
- No writer.mojo (deferred to later)
- No test files
- WARP.md contains incorrect INI content (needs fixing)

**Reference Architecture:**
Proven three-component pattern from mojo-ini:
- Lexer: 300 LOC (mojo-ini/src/ini/lexer.mojo)
- Parser: 200 LOC (mojo-ini/src/ini/parser.mojo)
- Writer: 120 LOC (deferred for YAML)

## Scope: YAML Lite v0.1.0

### ✅ Supported (80% Use Case Coverage)
**Block Style Mappings:**
```yaml
server:
  host: localhost
  port: 8080
```

**Block Style Sequences:**
```yaml
features:
  - block-style
  - nested structures
```

**Nested Structures:**
```yaml
config:
  api:
    endpoints:
      - name: users
        path: /api/users
```

**Basic Scalar Types:**
- Strings: quoted ("text", 'text') and unquoted (bare words)
- Numbers: integers (42, -17) and floats (3.14, 1.5e10)
- Booleans: true, false, yes, no
- Null: null, ~

**Comments:**
- `# comment` to end of line
- Inline comments after values

**Key Use Cases:**
- .pre-commit-config.yaml parsing ✅
- GitHub Actions workflows (.github/workflows/*.yml) ✅
- Docker Compose (docker-compose.yml) ✅
- Simple config files (app.yaml, settings.yml) ✅

### ❌ Not Supported (Complex/Rare Features)
- Flow style: `{key: value}` or `[1, 2, 3]`
- Anchors & aliases: `&anchor` and `*reference`
- Multi-document streams: `---` separator
- Complex types: timestamps, binary data
- Tag directives: `%TAG`, `%YAML`
- Literal/folded strings: `|` and `>`
- Escape sequences in strings (basic only)

**Rationale:** These features add 2-3 weeks of complexity but appear in <20% of config files.

## Type System Design

### Data Structure
Unlike INI's flat `Dict[String, Dict[String, String]]`, YAML needs recursive structure:

```mojo
struct YamlValue(Copyable, Movable):
    """Variant type for YAML values."""
    var _kind: Int  # 0=null, 1=bool, 2=int, 3=float, 4=string, 5=list, 6=dict
    var _string: String
    var _int: Int
    var _float: Float64
    var _bool: Bool
    var _list: List[YamlValue]  # Recursive!
    var _dict: Dict[String, YamlValue]  # Recursive!
```

**Public API:**
```mojo
fn parse(content: String) raises -> YamlValue
fn parse_file(path: String) raises -> YamlValue

# Accessor methods on YamlValue
fn as_string(self) raises -> String
fn as_int(self) raises -> Int
fn as_dict(self) raises -> Dict[String, YamlValue]
fn as_list(self) raises -> List[YamlValue]
fn get(self, key: String) raises -> YamlValue  # Dict access
fn get_at(self, index: Int) raises -> YamlValue  # List access
```

**Simpler Alternative (v0.1.0):**
If Mojo's variant/recursive types are challenging, start with string-only:
```mojo
Dict[String, YamlValue]  # where YamlValue is simpler (no recursive dict/list)
```
Then add full recursion in v0.2.0.

## Architecture: Three Components

### 1. Lexer (src/yaml/lexer.mojo) - ~400 LOC
**Responsibilities:**
- Tokenise YAML text into stream
- Track indentation levels (critical for block style)
- Handle comments
- Identify scalar types (string, number, bool, null)
- Line/column position tracking for errors

**Token Types:**
```mojo
struct TokenKind:
    # Special
    fn EOF() -> TokenKind
    fn NEWLINE() -> TokenKind
    fn INDENT() -> TokenKind  # Increased indentation
    fn DEDENT() -> TokenKind  # Decreased indentation
    fn COMMENT() -> TokenKind
    
    # Scalars
    fn STRING() -> TokenKind
    fn INTEGER() -> TokenKind
    fn FLOAT() -> TokenKind
    fn BOOLEAN() -> TokenKind
    fn NULL() -> TokenKind
    
    # Structure
    fn COLON() -> TokenKind      # : for mappings
    fn DASH() -> TokenKind       # - for sequences
    fn KEY() -> TokenKind        # Unquoted key name
```

**Key Challenge: Indentation Tracking**
Unlike INI/TOML, YAML uses indentation for structure:
```yaml
parent:        # INDENT+2
  child: val   # INDENT+2
other: x       # DEDENT-2
```

Lexer must emit INDENT/DEDENT tokens to help parser understand nesting.

**Reference:** Python's tokenize module uses similar indent stack.

**Implementation Pattern:**
```mojo
struct Lexer:
    var input: String
    var pos: Int
    var line: Int
    var column: Int
    var indent_stack: List[Int]  # Track indentation levels!
    
    fn tokenize(mut self) raises -> List[Token]:
        # Character-by-character scan
        # Track current line indentation
        # Emit INDENT/DEDENT when indentation changes
```

### 2. Parser (src/yaml/parser.mojo) - ~500 LOC
**Responsibilities:**
- Consume token stream from lexer
- Build nested YamlValue structure
- Handle indentation-based nesting
- Validate YAML structure rules
- Error messages with line/column context

**Parsing Strategy:**
Recursive descent parser with indentation context:
```mojo
struct Parser:
    var tokens: List[Token]
    var pos: Int
    
    fn parse(mut self) raises -> YamlValue:
        return self.parse_value(indent_level=0)
    
    fn parse_value(mut self, indent_level: Int) raises -> YamlValue:
        # Look at current token
        # If next token is ':', parse as mapping
        # If current token is '-', parse as sequence
        # Otherwise parse as scalar
    
    fn parse_mapping(mut self, indent_level: Int) raises -> Dict[String, YamlValue]:
        # Collect key: value pairs at this indent level
        # Recursively parse values
    
    fn parse_sequence(mut self, indent_level: Int) raises -> List[YamlValue]:
        # Collect - items at this indent level
        # Recursively parse items
```

**State Machine:**
```
[START]
  |
  v
[PARSE_VALUE] --is_mapping--> [PARSE_MAPPING] --recurse--> [PARSE_VALUE]
  |                                  ^
  is_sequence                        |
  |                                  v
  v                            [PARSE_KEY_VALUE]
[PARSE_SEQUENCE] --recurse--> [PARSE_VALUE]
  |
  is_scalar
  v
[PARSE_SCALAR]
```

**Key Challenge: Indentation-Based Nesting**
Parser must track indent levels to determine when nesting ends:
```yaml
parent:
  child1: a    # indent=2
  child2: b    # indent=2
sibling: c     # indent=0, back to parent level
```

When indent decreases, parser knows current mapping/sequence is complete.

### 3. Writer (src/yaml/writer.mojo) - DEFERRED
**Rationale:** Focus on reading first (80% use case). Writing is useful but lower priority.

**Future v0.2.0:**
- Convert YamlValue to YAML string
- Preserve indentation (2 spaces default)
- Handle nested structures
- ~300 LOC estimated

## Implementation Steps

### Phase 1: Foundation (Week 1)
**1.1 Fix WARP.md (30 min)**
- Remove INI/configparser content
- Replace with YAML-specific architecture
- Update commands, examples, scope

**1.2 Create YamlValue Type (2 days)**
File: src/yaml/value.mojo (~150 LOC)
- Implement variant struct with 7 types (null, bool, int, float, string, list, dict)
- Constructor methods: `YamlValue.string()`, `YamlValue.dict_()`, etc.
- Accessor methods: `as_string()`, `as_dict()`, `get()`, `get_at()`
- Error handling for type mismatches
- Unit tests: test_yaml_value.mojo (~20 tests)

**1.3 Basic Lexer Skeleton (2 days)**
File: src/yaml/lexer.mojo (~200 LOC initial)
- Position, TokenKind, Token structs (reuse INI pattern)
- Lexer struct with input, pos, line, column
- Character navigation: `current()`, `peek()`, `advance()`
- Indentation tracking: `indent_stack: List[Int]`
- Basic tokenize() skeleton (no full logic yet)
- Unit tests: test_lexer_basic.mojo (~10 tests for position tracking)

**Validation:** YamlValue type compiles and passes tests, lexer skeleton compiles.

### Phase 2: Lexer Implementation (Week 2)
**2.1 Scalar Tokenisation (2 days)**
- Implement `scan_string()` - quoted and unquoted
- Implement `scan_number()` - int/float detection
- Implement `scan_boolean()` - true/false/yes/no
- Implement `scan_null()` - null/~
- Tests: test_lexer_scalars.mojo (~15 tests)

**2.2 Structural Tokens (2 days)**
- Implement `scan_colon()` - mapping indicator
- Implement `scan_dash()` - sequence indicator
- Implement `scan_comment()` - # to end of line
- Tests: test_lexer_structure.mojo (~10 tests)

**2.3 Indentation Logic (3 days)**
This is the hardest part!
- Track current line indentation in `tokenize()` loop
- Maintain `indent_stack` (starts with [0])
- When indentation increases: emit INDENT token
- When indentation decreases: emit DEDENT token(s)
- Handle edge cases: blank lines, comments (don't affect indent)
- Tests: test_lexer_indent.mojo (~20 tests)

**Example Indent Logic:**
```mojo
fn handle_line_start(mut self) raises:
    var current_indent = self.count_leading_spaces()
    var prev_indent = self.indent_stack[-1]
    
    if current_indent > prev_indent:
        self.indent_stack.append(current_indent)
        self.emit_token(TokenKind.INDENT())
    elif current_indent < prev_indent:
        while self.indent_stack[-1] > current_indent:
            self.indent_stack.pop()
            self.emit_token(TokenKind.DEDENT())
```

**Validation:** Lexer tokenises fixtures/yaml_lite_example.yaml correctly.

### Phase 3: Parser Implementation (Week 3-4)
**3.1 Parser Skeleton (1 day)**
File: src/yaml/parser.mojo (~150 LOC initial)
- Parser struct with tokens, pos
- Token navigation: `current()`, `peek()`, `advance()`, `expect()`
- Entry point: `parse() raises -> YamlValue`
- Tests: test_parser_skeleton.mojo (~5 tests)

**3.2 Scalar Parsing (1 day)**
- Implement `parse_scalar()` - convert token to YamlValue
- Handle type detection (string, int, float, bool, null)
- Tests: test_parser_scalars.mojo (~10 tests)

**3.3 Mapping Parsing (3 days)**
Core challenge!
- Implement `parse_mapping(indent_level)`
- Loop: expect KEY, COLON, parse_value()
- Track indent level, stop when DEDENT
- Handle nested mappings recursively
- Tests: test_parser_mappings.mojo (~15 tests)

**Example:**
```mojo
fn parse_mapping(mut self, indent_level: Int) raises -> YamlValue:
    var result = Dict[String, YamlValue]()
    
    while True:
        if self.current().kind == TokenKind.DEDENT():
            break  # End of mapping
        
        var key = self.expect(TokenKind.KEY()).value
        self.expect(TokenKind.COLON())
        
        # Check if nested structure follows
        if self.current().kind == TokenKind.INDENT():
            self.advance()  # Consume INDENT
            var value = self.parse_value(indent_level + 1)
            result[key] = value
        else:
            # Inline value
            var value = self.parse_scalar()
            result[key] = value
    
    return YamlValue.dict_(result)
```

**3.4 Sequence Parsing (2 days)**
- Implement `parse_sequence(indent_level)`
- Loop: expect DASH, parse_value()
- Track indent level, stop when DEDENT
- Handle nested sequences/mappings in items
- Tests: test_parser_sequences.mojo (~12 tests)

**3.5 Integration (2 days)**
- Implement `parse_value()` - dispatcher (mapping? sequence? scalar?)
- Handle mixed nesting (sequences of mappings, etc.)
- Error handling and messages
- Tests: test_parser_integration.mojo (~20 tests)

**Validation:** Parser correctly parses fixtures/yaml_lite_example.yaml and .pre-commit-config.yaml.

### Phase 4: Public API & Examples (Week 5)
**4.1 Public API (1 day)**
File: src/yaml/__init__.mojo
- Implement `parse(content: String) raises -> YamlValue`
- Implement `parse_file(path: String) raises -> YamlValue`
- Export types: YamlValue
- Clean up placeholder code

**4.2 Examples (2 days)**
Create working examples:
- examples/quickstart.mojo - Basic parsing from README
- examples/pre_commit.mojo - Parse .pre-commit-config.yaml
- examples/github_actions.mojo - Parse workflow file
- Add pixi commands: example-quickstart, example-pre-commit

**4.3 Documentation (2 days)**
- Update README.md - Remove "placeholder" warnings, add usage
- Update CHANGELOG.md - v0.1.0 release notes
- Create docs/planning/ARCHITECTURE.md - Detailed design doc
- Update WARP.md - Final state with all commands

**Validation:** Examples run successfully with `pixi run example-*`.

### Phase 5: Testing & Hardening (Week 6)
**5.1 Fixture Testing (2 days)**
- Create fixtures/ directory with real-world YAML files:
  - fixtures/pre_commit.yaml
  - fixtures/github_workflow.yaml
  - fixtures/docker_compose.yaml
  - fixtures/nested_complex.yaml
- Test parser against each fixture
- Ensure correct structure extraction

**5.2 Error Handling (2 days)**
- Test malformed YAML (indent errors, syntax errors)
- Verify error messages include line/column
- Add ~15 error case tests

**5.3 Edge Cases (1 day)**
- Empty files
- Files with only comments
- Deep nesting (10+ levels)
- Large files (>1000 lines)
- Unicode in keys/values

**Validation:** All tests pass, error messages are clear.

## File Structure
```
src/yaml/
  __init__.mojo          # Public API: parse(), parse_file()
  value.mojo             # YamlValue type definition [NEW]
  lexer.mojo             # Tokenisation [NEW]
  parser.mojo            # Structure building [NEW]

tests/
  test_yaml_value.mojo          # ~20 tests [NEW]
  test_lexer_basic.mojo         # ~10 tests [NEW]
  test_lexer_scalars.mojo       # ~15 tests [NEW]
  test_lexer_structure.mojo     # ~10 tests [NEW]
  test_lexer_indent.mojo        # ~20 tests [NEW]
  test_parser_skeleton.mojo     # ~5 tests [NEW]
  test_parser_scalars.mojo      # ~10 tests [NEW]
  test_parser_mappings.mojo     # ~15 tests [NEW]
  test_parser_sequences.mojo    # ~12 tests [NEW]
  test_parser_integration.mojo  # ~20 tests [NEW]
  test_errors.mojo              # ~15 tests [NEW]

examples/
  quickstart.mojo        # Basic usage [NEW]
  pre_commit.mojo        # Real-world example [NEW]
  github_actions.mojo    # Real-world example [NEW]

fixtures/
  yaml_lite_example.yaml  # Exists
  pre_commit.yaml         # [NEW]
  github_workflow.yaml    # [NEW]
  docker_compose.yaml     # [NEW]
  nested_complex.yaml     # [NEW]
```

**Total Test Count:** ~152 tests (comprehensive coverage)

## Risks & Mitigations

### Risk 1: Indentation Parsing Complexity (HIGH)
**Problem:** Indentation-based syntax is harder than bracket-based (INI/TOML).

**Mitigation:**
- Start with simple cases (2-space indent only)
- Reference Python's tokenize module implementation
- Build comprehensive indent test suite early
- Use fixtures from real config files to validate

### Risk 2: Recursive Type System (MEDIUM)
**Problem:** Mojo's variant/recursive types may be challenging.

**Mitigation:**
- Option A: Use YamlValue variant (follow mojo-toml TomlValue pattern)
- Option B: If blocked, start with string-only values in v0.1.0, add types in v0.2.0
- Test type system separately before parser integration

### Risk 3: Ambiguous YAML Syntax (MEDIUM)
**Problem:** YAML has tricky edge cases (unquoted strings, type inference).

**Mitigation:**
- Document limitations clearly
- When ambiguous, match PyYAML behavior
- Fail with clear errors rather than guess
- Test against real config files

### Risk 4: Performance (LOW)
**Problem:** Recursive parsing might be slow for large files.

**Mitigation:**
- Don't optimise prematurely
- Most config files <1000 lines
- Add benchmarks in v0.2.0 if needed
- Mojo is fast by default

## Success Criteria
✅ Parse .pre-commit-config.yaml correctly
✅ Parse GitHub Actions workflow files
✅ Parse Docker Compose files
✅ Support nested mappings and sequences (5+ levels deep)
✅ Handle all basic scalar types (string, int, float, bool, null)
✅ Clear error messages with line/column context
✅ ~150 passing tests
✅ 3 working examples
✅ Updated documentation (README, WARP.md, CHANGELOG)

**Definition of "80% Coverage":**
Can parse 8 out of 10 typical config files without errors. Excludes edge cases like anchors, flow style, multi-document.

## Timeline Estimate
- **Week 1:** Foundation (YamlValue, lexer skeleton, WARP.md fix)
- **Week 2:** Lexer implementation (scalars, structure, indentation)
- **Week 3-4:** Parser implementation (mappings, sequences, integration)
- **Week 5:** Public API, examples, documentation
- **Week 6:** Testing, error handling, hardening

**Total: 6 weeks (30 working days)**

Compare to original README estimate:
- YAML Lite: 8-11 weeks (original estimate)
- This plan: 6 weeks (read-focused, no writer)

**Acceleration factors:**
- Skip writer (~2 weeks)
- Reuse mojo-ini/mojo-toml patterns (~1 week)
- Focus on 80% use cases, skip edge cases (~2 weeks)

## Future Work (v0.2.0+)

### v0.2.0 - Writer Support (3-4 weeks)
- Implement src/yaml/writer.mojo
- YamlValue to YAML string serialisation
- Preserve indentation (2 spaces)
- to_yaml() and write_file() functions

### v0.3.0 - Extended Features (4-5 weeks)
- Flow style: `{key: value}`, `[1, 2, 3]`
- Literal/folded strings: `|`, `>`
- Multi-line strings
- Advanced scalar type detection

### v0.4.0 - Advanced Features (6-8 weeks)
- Anchors & aliases: `&anchor`, `*reference`
- Multi-document streams: `---`
- Tag directives: `%TAG`, `%YAML`
- Full YAML 1.2 compliance

**Total to full YAML 1.2:** ~19-23 additional weeks (original estimate validated)

## Questions to Resolve
1. **YamlValue implementation:** Use variant type or simpler approach first?
2. **Error recovery:** Should parser continue after errors or fail fast?
3. **Indentation strictness:** Require consistent indent (2 or 4 spaces) or allow mixed?
4. **Type inference:** How aggressive? (e.g., "123" as int or string?)
5. **Performance benchmarks:** Compare against PyYAML? (v0.2.0 feature?)

**Recommendation:** Start with strict rules, relax later based on real-world feedback.
