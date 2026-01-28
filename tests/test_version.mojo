from yaml import parse

fn main() raises:
    print("Test 1: Unquoted version (should fail)")
    try:
        var r1 = parse("version: 0.1.0")
        print("Unexpected success:", r1.get("version").as_string())
    except e:
        print("Failed as expected:", e)

    print("\nTest 2: Quoted version (should work)")
    var r2 = parse('version: "0.1.0"')
    print("Success:", r2.get("version").as_string())
