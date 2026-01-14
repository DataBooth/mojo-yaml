"""mojo-yaml: YAML file parser for Mojo.

Lite YAML parser supporting block-style mappings and sequences.

Example:
    ```mojo
    from yaml import parse
    
    var yaml_str = "database:\\n  host: localhost\\n  port: 5432"
    var config = parse(yaml_str)
    
    var db = config.get("database")
    print(db.get("host").as_string())  # "localhost"
    print(db.get("port").as_int())      # 5432
    ```

Architecture:
    - Lexer: Tokenises YAML text with indentation tracking
    - Parser: Builds nested YamlValue structures from tokens
    - YamlValue: Variant type supporting null, bool, int, float, string, sequence, mapping

Status: v0.1.0 - Lexer and Parser complete, nested structures working
"""

from .lexer import Lexer
from .parser import Parser
from .value import YamlValue


fn parse(content: String) raises -> YamlValue:
    """Parse YAML string into YamlValue.
    
    Args:
        content: YAML formatted string.
    
    Returns:
        Parsed YamlValue (typically a mapping or sequence).
    
    Raises:
        Error: If YAML syntax is invalid.
    
    Example:
        ```mojo
        var yaml_str = "name: Alice\\nage: 30"
        var result = parse(yaml_str)
        print(result.get("name").as_string())  # "Alice"
        print(result.get("age").as_int())      # 30
        ```
    """
    var lexer = Lexer(content)
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    return parser.parse()
