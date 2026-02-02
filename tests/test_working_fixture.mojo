from pathlib import Path
from testing import assert_equal, assert_true, TestSuite
from yaml import parse


fn test_working_fixture() raises:
    print("Testing yaml_lite_working.yaml")
    print("="*60)

    var p = Path("fixtures/yaml_lite_working.yaml")
    var content = p.read_text()

    print("File size:", len(content), "bytes")

    var result = parse(content)
    print("✅ PARSING SUCCEEDED!")
    print()

    # Test various fields
    print("Testing field access:")
    assert_equal(result.get("name").as_string(), "mojo-yaml")
    assert_equal(result.get("version").as_string(), "0.1.0")

    var desc = result.get("description").as_string()
    assert_true(len(desc) > 0)

    var server = result.get("server")
    assert_equal(server.get("host").as_string(), "localhost")
    assert_equal(server.get("port").as_int(), 8080)
    assert_true(server.get("debug").as_bool())

    var features = result.get("features")
    var seq = features.sequence_value.copy()
    assert_true(len(seq) >= 1)
    # First feature in the working fixture
    assert_equal(features.get_at(0).as_string(), "block-style parsing")

    var config = result.get("config")
    var api = config.get("api")
    assert_equal(api.get("url").as_string(), "/api/v1")
    assert_equal(api.get("timeout").as_int(), 30)

    print()
    print("✅ All field access successful!")


fn main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
