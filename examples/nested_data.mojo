"""Working with nested data from README.md

Demonstrates navigating nested mappings and sequences.
"""

from yaml import parse


def main() raises:
    var yaml_str = """
config:
  database:
    host: localhost
    port: 5432
  servers:
    - name: web1
      ip: "192.168.1.10"
    - name: web2
      ip: "192.168.1.11"
"""

    var data = parse(yaml_str)

    print("=== Navigate Nested Mappings ===")
    var config = data.get("config")
    var db = config.get("database")
    print("Database host:", db.get("host").as_string())  # localhost
    print("Database port:", db.get("port").as_int())     # 5432

    print()
    print("=== Navigate Sequences ===")
    var servers = config.get("servers")
    print("Number of servers:", len(servers.sequence_value))

    for i in range(len(servers.sequence_value)):
        var server = servers.get_at(i)
        print("Server", i, ":")
        print("  Name:", server.get("name").as_string())
        print("  IP:", server.get("ip").as_string())
