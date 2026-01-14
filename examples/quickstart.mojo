"""Quick start example from README.md

Demonstrates basic YAML parsing with nested structures.
"""

from yaml import parse


fn main() raises:
    # Parse YAML string
    var config = parse("""
server:
  host: localhost
  port: 8080
  debug: true
users:
  - name: Alice
    role: admin
  - name: Bob
    role: user
""")
    
    # Access values with type-safe methods
    var server = config.get("server")
    print(server.get("host").as_string())   # localhost
    print(server.get("port").as_int())      # 8080
    print(server.get("debug").as_bool())    # True
    
    # Navigate nested structures
    var users = config.get("users")
    var first_user = users.get_at(0)
    print(first_user.get("name").as_string())  # Alice
    print(first_user.get("role").as_string())  # admin
