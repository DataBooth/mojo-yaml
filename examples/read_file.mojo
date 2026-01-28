"""Reading YAML from files

Demonstrates parsing YAML files from disk.
"""

from yaml import parse
from pathlib import Path


fn main() raises:
    print("=== Reading YAML from File ===")

    # Read the working example fixture
    var path = Path("fixtures/yaml_lite_working.yaml")
    var content = path.read_text()

    print("File:", path)
    print("Size:", len(content), "bytes")
    print()

    # Parse the content
    var data = parse(content)

    # Access some values
    print("Project name:", data.get("name").as_string())
    print("Version:", data.get("version").as_string())
    print("Description:", data.get("description").as_string())

    print()
    print("=== Server Configuration ===")
    var server = data.get("server")
    print("Host:", server.get("host").as_string())
    print("Port:", server.get("port").as_int())
    print("Debug:", server.get("debug").as_bool())

    print()
    print("=== Features List ===")
    var features = data.get("features")
    for i in range(len(features.sequence_value)):
        print("-", features.get_at(i).as_string())
