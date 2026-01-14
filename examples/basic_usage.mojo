"""Basic usage examples from README.md

Shows parsing from strings and type-safe access.
"""

from yaml import parse


fn main() raises:
    print("=== Basic Parsing ===")
    
    # From string
    var config = parse("name: value")
    print(config.get("name").as_string())  # value
    
    print()
    print("=== Type-Safe Access ===")
    
    var yaml_str = """
number: 42
text: hello
flag: true
empty: null
"""
    
    var data = parse(yaml_str)
    
    # Check type before accessing
    var value = data.get("number")
    if value.is_int():
        print("Got integer:", value.as_int())
    
    var text = data.get("text")
    if text.is_string():
        print("Got string:", text.as_string())
    
    var flag = data.get("flag")
    if flag.is_bool():
        print("Got boolean:", flag.as_bool())
    
    var empty = data.get("empty")
    if empty.is_null():
        print("Got null value")
    
    # Or handle errors
    try:
        var num = data.get("text").as_int()  # Will fail - text is not an int
        print("Got number:", num)
    except:
        print("'text' is not a number (as expected)")
