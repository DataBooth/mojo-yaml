from yaml import parse

def main() raises:
    # Parse a simple YAML document using the public API
    # Use a simple top-level mapping that is already covered by parser tests.
    var yaml_str = """
name: mojo-yaml
mode: lite
"""
    var root = parse(yaml_str)

    if root.get("name").as_string() != "mojo-yaml":
        raise Error("Parse failed: expected name = 'mojo-yaml'")

    print("ok")
