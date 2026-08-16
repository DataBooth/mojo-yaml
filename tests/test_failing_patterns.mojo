from yaml import parse

def main() raises:
    print("Test 1: Sequence of mappings (inline)")
    var yaml1 = """- name: Alice
  age: 30
- name: Bob
  age: 25"""
    print("Input:", yaml1)
    try:
        var result = parse(yaml1)
        print("✅ Success!")
        print("Result is sequence:", result.is_sequence())
        if result.is_sequence():
            var seq = result.as_sequence()
            print("Length:", len(seq))
            for i in range(len(seq)):
                var item = seq[i].copy()
                print("  Item", i, "is mapping:", item.is_mapping())
                if item.is_mapping():
                    print("    Keys:", len(item.as_mapping()))
    except e:
        print("❌ Failed:", e)

    print("\\nTest 2: Complex nested (from test)")
    var yaml2 = """config:
  servers:
    - host: localhost
      port: 8080
    - host: example.com
      port: 443
  enabled: true"""
    try:
        var result2 = parse(yaml2)
        print("✅ Success!")
        print("Result is mapping:", result2.is_mapping())
    except e:
        print("❌ Failed:", e)
