# mojo-yaml 🔥

**YAML Lite parser for Mojo** - Native, zero-dependency YAML reader

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Mojo](https://img.shields.io/badge/Mojo-🔥-orange)](https://www.modular.com/mojo)
[![Status](https://img.shields.io/badge/Status-v0.1.0%20Lite-brightgreen)](https://github.com/DataBooth/mojo-yaml)
[![Tests](https://img.shields.io/badge/Tests-91%2F91%20passing-brightgreen)](https://github.com/DataBooth/mojo-yaml)

Parse YAML configuration files in native Mojo with zero Python dependencies.

## Status: ✅ v0.1.0 Lite - Functional (Reader Only)

This is a **working YAML Lite parser** covering ~80% of common YAML patterns.

**Current Capabilities:**
- ✅ Nested mappings and sequences
- ✅ Inline list-mappings: `- name: Alice\n  age: 30`  
- ✅ All scalar types (int, float, bool, null, string)
- ✅ Comments anywhere
- ✅ 91/91 tests passing (100%)
- ✅ Works with real configs (pre-commit, custom YAMLs)

**Limitations:** See [COMPATIBILITY.md](docs/COMPATIBILITY.md) for details

## Quick Start

```mojo
from yaml import parse

# Parse YAML string
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

# Access values with type-safe methods
var server = config.get("server")
print(server.get("host").as_string())   # localhost
print(server.get("port").as_int())      # 8080
print(server.get("debug").as_bool())    # True

# Navigate nested structures
var users = config.get("users")
var first_user = users.get_at(0)
print(first_user.get("name").as_string())  # Alice
print(first_user.get("role").as_string())  # admin
```

## Features

### ✅ Fully Supported

- **Nested Mappings**: Any depth, e.g., `server: {nested: {deep: value}}`
- **Nested Sequences**: Any depth, e.g., `- [- item]`
- **Inline List-Mappings**: `- name: value\n  key2: value2`
- **All Scalar Types**: `42`, `3.14`, `true`, `null`, `"string"`
- **Comments**: `# anywhere in file`
- **Mixed Structures**: Lists in dicts, dicts in lists

### ⚠️ Requires Quoting

- **Multi-word strings**: Must use `"Hello world"` not `Hello world`
- **Version numbers**: Must use `"1.0.0"` not `1.0.0`
- **Single-word strings work**: `host: localhost` ✅

### ❌ Not Supported (v0.1.0)

- **Flow style**: `[1, 2, 3]` or `{key: value}` → use block style
- **Empty values**: `key:` → use `key: null` or `key: ""`
- **Anchors/Aliases**: `&anchor`, `*reference`
- **Multi-document**: `---` separator
- **Literal/Folded**: `|`, `>`
- **Writing YAML**: Reader-only in v0.1.0

## Installation

### Option 1: Git Submodule (Recommended)

```bash
# Add as submodule
git submodule add https://github.com/databooth/mojo-yaml vendor/mojo-yaml

# Use in your code
mojo -I vendor/mojo-yaml/src your_app.mojo
```

### Option 2: Direct Copy

```bash
# Copy source files
cp -r mojo-yaml/src/yaml your-project/lib/yaml

# Use in your code  
mojo -I your-project/lib your_app.mojo
```

### Option 3: Pixi (Future)

```bash
pixi add modular-community::mojo-yaml  # After publication to modular-community
```

## Usage

### Basic Parsing

```mojo
from yaml import parse
from pathlib import Path

# From string
var config = parse("name: value")
print(config.get("name").as_string())  # value

# From file
var content = Path("config.yaml").read_text()
var data = parse(content)
```

### Type-Safe Access

```mojo
# Check type before accessing
if value.is_string():
    print(value.as_string())
elif value.is_int():
    print(value.as_int())

# Or handle errors
try:
    var num = value.as_int()
    print("Got number:", num)
except:
    print("Not a number")
```

### Working with Nested Data

```mojo
var yaml_str = """
config:
  database:
    host: localhost
    port: 5432
  servers:
    - name: web1
      ip: 192.168.1.10
    - name: web2
      ip: 192.168.1.11
"""

var data = parse(yaml_str)

# Navigate nested mappings
var config = data.get("config")
var db = config.get("database")
print(db.get("host").as_string())  # localhost
print(db.get("port").as_int())     # 5432

# Navigate sequences
var servers = config.get("servers")
for i in range(len(servers.sequence_value)):
    var server = servers.get_at(i)
    print(server.get("name").as_string())
    print(server.get("ip").as_string())
```

### Compatibility Tips

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
key:                       # ❌ Empty values fail
```

## Examples

See `examples/` directory for working code:
- `quickstart.mojo` - Quick start from README
- `basic_usage.mojo` - Type-safe access patterns  
- `nested_data.mojo` - Navigate complex structures
- `read_file.mojo` - Reading YAML from disk

Run with: `pixi run example-quickstart` (or `example-all` for all)

Real-world YAML files in `fixtures/`:
- `yaml_lite_working.yaml` - Reference implementation
- `yaml_lite_example.yaml` - Comprehensive demo
- `pre_commit.yaml` - Actual pre-commit config

For detailed compatibility info, see [COMPATIBILITY.md](docs/COMPATIBILITY.md).

## Documentation

- [CHANGELOG.md](CHANGELOG.md) - Version history and changes
- [docs/planning/](docs/planning/) - Technical documentation and design docs
- [examples/](examples/) - Usage examples

## Related Projects

- [mojo-toml](https://github.com/databooth/mojo-toml) - TOML 1.0 parser/writer for modern configs
- [mojo-ini](https://github.com/databooth/mojo-ini) - INI/ConfigParser for Mojo  
- [mojo-dotenv](https://github.com/databooth/mojo-dotenv) - Environment variable management

Together these provide comprehensive configuration file support for Mojo! 🎯

## Contributing

Contributions welcome! Please:
1. Follow existing code style (see mojo-toml for reference)
2. Add tests for new features
3. Update documentation
4. Australian or US English fine for docs, US spelling for code

## License

MIT License - see [LICENSE](LICENSE) file for details

---

Open source project with initial development sponsored by [DataBooth](https://github.com/databooth) 🔥
