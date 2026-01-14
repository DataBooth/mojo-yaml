# mojo-yaml v0.1.0 Lite - Native YAML Parser

From the author (@mjboothaus) of [mojo-toml](https://github.com/databooth/mojo-toml), [mojo-ini](https://github.com/databooth/mojo-ini), and [mojo-dotenv](https://github.com/databooth/mojo-dotenv) comes **mojo-yaml**, a native YAML Lite parser for Mojo with zero dependencies, covering ~80% of common YAML use cases.

## What it does

Parses block-style YAML configuration files into native Mojo structures:
- Nested mappings (dicts) and sequences (lists) of any depth
- Inline list-mappings: `- name: Alice\n  age: 30`
- All scalar types: int, float, bool, null, string (quoted/unquoted)
- Comments anywhere with `#`
- Type-safe value access with `.get()` and `.get_at()`
- Clear error messages with line/column context
- 91 tests ensuring reliability (100% passing)

## Installation

```bash
git clone https://github.com/DataBooth/mojo-yaml.git
cd mojo-yaml
pixi run test-all
pixi run example-all  # See working examples
```

Coming soon to the `modular-community` channel.

## Usage

**Basic Parsing:**

```mojo
from yaml import parse

fn main() raises:
    var config = parse("""
server:
  host: localhost
  port: 8080
  debug: true
users:
  - name: Alice
    role: admin
  - name: Bob
    role: user
""")
    
    # Type-safe access
    var server = config.get("server")
    print(server.get("host").as_string())   # localhost
    print(server.get("port").as_int())      # 8080
    print(server.get("debug").as_bool())    # True
    
    # Navigate sequences
    var users = config.get("users")
    var first_user = users.get_at(0)
    print(first_user.get("name").as_string())  # Alice
```

**File I/O:**

```mojo
from yaml import parse
from pathlib import Path

fn main() raises:
    var content = Path("config.yaml").read_text()
    var config = parse(content)
    # Work with parsed data
```

## What's in v0.1.0 Lite

- **Core Parser:** Lexer (518 LOC) + Parser (300 LOC) + YamlValue (318 LOC)
- **Coverage:** ~80% of common YAML patterns (block-style only)
- **Tests:** 91/91 passing across 15 test suites (100%)
- **Examples:** 4 working code examples with real-world fixtures
- **Documentation:** Comprehensive README, CHANGELOG, and COMPATIBILITY.md

### Real-World Testing

✅ **Works:** `.pre-commit-config.yaml`, custom configs  
⚠️ **Requires quoting:** Multi-word strings, version numbers  
❌ **Not supported:** Flow-style `[...]`, empty values, anchors/aliases

See [COMPATIBILITY.md](https://github.com/DataBooth/mojo-yaml/blob/main/docs/COMPATIBILITY.md) for detailed feature matrix.

## Compatibility Tips

**✅ Do:**
```yaml
version: "1.0.0"           # Quote version numbers
description: "My app"      # Quote multi-word strings  
host: localhost            # Single words OK unquoted
list:
  - item1                  # Use block style
  - item2
```

**❌ Don't:**
```yaml
version: 1.0.0             # ❌ Multiple dots fail
description: My app        # ❌ Spaces in unquoted strings
list: [item1, item2]       # ❌ Flow style not supported  
```

## Feature Comparison

| Feature | Support | Notes |
|---------|---------|-------|
| **Nested Mappings** | ✅ Full | Any depth |
| **Nested Sequences** | ✅ Full | Any depth |
| **Inline List-Mapping** | ✅ Full | `- name: value` with continuation |
| **Scalars** | ✅ Full | int, float, bool, null, string |
| **Comments** | ✅ Full | `# anywhere` |
| **Quoted Strings** | ✅ Full | `"text"`, `'text'` |
| **Unquoted Strings** | ⚠️ Single word | Must quote multi-word |
| **Version Numbers** | ⚠️ Must quote | `"1.0.0"` not `1.0.0` |
| **Flow Style** | ❌ Not supported | `[1, 2]`, `{a: b}` |
| **Empty Values** | ❌ Not supported | `key:` → use `key: null` |
| **Anchors/Aliases** | ❌ Not supported | `&anchor`, `*ref` |
| **Multi-Document** | ❌ Not supported | `---` |
| **Writing YAML** | ❌ Not implemented | Reader-only v0.1.0 |

## Why "Lite"?

Full YAML 1.2 is complex (~84-page spec). YAML Lite focuses on the ~80% use case:
- ✅ Configuration files (pre-commit, custom configs)
- ✅ Data serialization (block-style only)
- ✅ Nested structures (any depth)
- ❌ Advanced features (anchors, flow-style, multi-doc)

This provides immediate value while keeping implementation maintainable.

## Roadmap

Possible enhancements for v0.2.0+:
- Support version number patterns (multiple decimal points)
- Handle empty values gracefully
- Flow-style array support `[1, 2, 3]`
- YAML writer functionality

Not planned:
- Anchors/aliases (complex, rarely needed)
- Multi-document streams (niche use case)
- Literal/folded blocks (marginal utility)

## Links

- [GitHub Repository](https://github.com/DataBooth/mojo-yaml)
- [v0.1.0 Release](https://github.com/DataBooth/mojo-yaml/releases/tag/v0.1.0)
- [Documentation](https://github.com/DataBooth/mojo-yaml/blob/main/README.md)
- [Compatibility Guide](https://github.com/DataBooth/mojo-yaml/blob/main/docs/COMPATIBILITY.md)
- License: MIT

## Related Projects

- [mojo-toml](https://github.com/databooth/mojo-toml) - TOML 1.0 parser/writer for modern configs
- [mojo-ini](https://github.com/databooth/mojo-ini) - INI/ConfigParser for Mojo
- [mojo-dotenv](https://github.com/databooth/mojo-dotenv) - Environment variable management

Together these provide comprehensive configuration file support for Mojo! 🎯

## Acknowledgements

Open source project with initial development sponsored by [DataBooth](https://www.databooth.com.au/posts/mojo), building high-performance data and AI services with Mojo.

Feedback and contributions welcome!
