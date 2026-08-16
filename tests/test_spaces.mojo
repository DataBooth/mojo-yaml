from std.testing import TestSuite
from yaml import parse

def test_spaces_diagnostics() raises:
    print("Test 1: Simple unquoted string")
    var r1 = parse("name: value")
    if r1.get("name").as_string() != "value":
        raise Error("Expected name = 'value' in simple unquoted string case")

    print("Success:", r1.get("name").as_string())

    print("\nTest 2: Unquoted string with space (should fail)")
    var failed = False
    try:
        var r2 = parse("description: YAML parser")
        # If we get here, the parser accepted input we expect to reject.
        print("Unexpected success:", r2.get("description").as_string())
    except e:
        failed = True
        print("Failed as expected:", e)

    if not failed:
        raise Error("Expected parse failure for unquoted string with space")

    print("\nTest 3: Quoted string with spaces (should work)")
    var r3 = parse('description: "YAML parser for Mojo"')
    if r3.get("description").as_string() != "YAML parser for Mojo":
        raise Error("Expected quoted description to round-trip correctly")

    print("Success:", r3.get("description").as_string())


def main() raises:
    # Wrap diagnostics in TestSuite so they integrate with the test runner.
    TestSuite.discover_tests[__functions_in_module()]().run()
