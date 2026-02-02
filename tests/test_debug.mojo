from testing import TestSuite
from yaml import parse

fn test_basic_debug_diagnostics() raises:
    print("Test 1: Simple mapping")
    var r1 = parse("name: value")
    print("Success:", r1.get("name").as_string())

    print("\nTest 2: With comment")
    var r2 = parse("# comment\nname: value")
    print("Success:", r2.get("name").as_string())

    print("\nTest 3: Multiple lines")
    var r3 = parse("name: value\nage: 42")
    print("Success name:", r3.get("name").as_string())
    print("Success age:", r3.get("age").as_int())


fn main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
