from pathlib import Path
from yaml import parse

fn main() raises:
    print("Testing yaml_lite_working.yaml")
    print("="*60)

    var p = Path("fixtures/yaml_lite_working.yaml")
    var content = p.read_text()

    print("File size:", len(content), "bytes")

    try:
        var result = parse(content)
        print("✅ PARSING SUCCEEDED!")
        print()

        # Test various fields
        print("Testing field access:")
        print("  name:", result.get("name").as_string())
        print("  version:", result.get("version").as_string())
        print("  description:", result.get("description").as_string())

        var server = result.get("server")
        print("  server.host:", server.get("host").as_string())
        print("  server.port:", server.get("port").as_int())
        print("  server.debug:", server.get("debug").as_bool())

        var features = result.get("features")
        print("  features count:", len(features.sequence_value))
        print("  features[0]:", features.get_at(0).as_string())

        var config = result.get("config")
        var api = config.get("api")
        print("  config.api.url:", api.get("url").as_string())
        print("  config.api.timeout:", api.get("timeout").as_int())

        print()
        print("✅ All field access successful!")

    except e:
        print("❌ FAILED:", e)
