from std.testing import TestSuite
from yaml import parse

def test_version_diagnostics() raises:
    print("Test 1: Unquoted version (should fail)")
    var failed = False
    try:
        var r1 = parse("version: 0.1.0")
        print("Unexpected success:", r1.get("version").as_string())
    except e:
        failed = True
        print("Failed as expected:", e)

    if not failed:
        raise Error("Expected parse failure for unquoted semantic version")

    print("\nTest 2: Quoted version (should work)")
    var r2 = parse('version: "0.1.0"')
    if r2.get("version").as_string() != "0.1.0":
        raise Error("Expected quoted version to round-trip correctly")

    print("Success:", r2.get("version").as_string())


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
