from yaml import parse

fn main() raises:
    print("Test 1: Simple unquoted string")
    var r1 = parse("name: value")
    print("Success:", r1.get("name").as_string())

    print("\nTest 2: Unquoted string with space (should fail)")
    try:
        var r2 = parse("description: YAML parser")
        print("Success:", r2.get("description").as_string())
    except e:
        print("Failed:", e)

    print("\nTest 3: Quoted string with spaces (should work)")
    var r3 = parse('description: "YAML parser for Mojo"')
    print("Success:", r3.get("description").as_string())
