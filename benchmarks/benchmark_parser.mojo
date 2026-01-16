"""Performance benchmark for mojo-yaml parser.

Measures parsing performance with various YAML Lite document sizes and complexities.
"""

from time import perf_counter
from yaml import parse
from pathlib import Path


fn format_time(seconds: Float64) -> String:
    """Format time in appropriate units."""
    if seconds < 0.001:
        return String(Int(seconds * 1_000_000)) + " μs"
    elif seconds < 1.0:
        return String(Int(seconds * 1_000)) + " ms"
    else:
        return String(seconds) + " s"


fn benchmark_simple_sequence() raises:
    """Benchmark simple sequence parsing."""
    var yaml_content = """- apple
- banana
- cherry
- date
- elderberry
"""

    var iterations = 1000
    var start = perf_counter()

    for i in range(iterations):
        var data = parse(yaml_content)

    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)

    print("Simple sequence (5 items):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_simple_mapping() raises:
    """Benchmark simple mapping parsing."""
    var yaml_content = """name: Alice
age: 30
city: Sydney
email: alice@example.com
active: true
"""

    var iterations = 1000
    var start = perf_counter()

    for i in range(iterations):
        var data = parse(yaml_content)

    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)

    print("\nSimple mapping (5 key-value pairs):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_sequence_of_mappings() raises:
    """Benchmark sequence of mappings (common pattern)."""
    var yaml_content = """- name: Alice
  age: 30
  city: Sydney
- name: Bob
  age: 25
  city: Melbourne
- name: Charlie
  age: 35
  city: Brisbane
"""

    var iterations = 1000
    var start = perf_counter()

    for i in range(iterations):
        var data = parse(yaml_content)

    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)

    print("\nSequence of mappings (3 items, 9 keys):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_nested_structure() raises:
    """Benchmark nested mappings and sequences."""
    var yaml_content = """database:
  host: localhost
  port: 5432
  credentials:
    username: admin
    password: secret
  pools:
    - name: primary
      size: 10
    - name: replica
      size: 5
"""

    var iterations = 1000
    var start = perf_counter()

    for i in range(iterations):
        var data = parse(yaml_content)

    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)

    print("\nNested structure (2 levels, mixed types):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_large_document() raises:
    """Benchmark larger document with mixed complexity."""
    var yaml_content = """users:
  - name: Alice
    email: alice@example.com
    age: 30
    roles:
      - admin
      - developer
  - name: Bob
    email: bob@example.com
    age: 25
    roles:
      - developer
      - tester
  - name: Charlie
    email: charlie@example.com
    age: 35
    roles:
      - manager

config:
  environment: production
  debug: false
  timeout: 30
  features:
    - authentication
    - caching
    - monitoring

database:
  host: localhost
  port: 5432
  name: myapp
  credentials:
    username: admin
    password: secret
"""

    var iterations = 500
    var start = perf_counter()

    for i in range(iterations):
        var data = parse(yaml_content)

    var elapsed = perf_counter() - start
    var avg_time = elapsed / Float64(iterations)

    print("\nLarge document (3 sections, 30+ values):")
    print("  Total:", format_time(elapsed), "for", iterations, "iterations")
    print("  Average:", format_time(avg_time), "per parse")
    print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")


fn benchmark_real_yaml_lite() raises:
    """Benchmark real-world yaml_lite_working.yaml if it exists."""
    try:
        var path = Path("fixtures/yaml_lite_working.yaml")
        var content = path.read_text()

        var iterations = 500
        var start = perf_counter()

        for i in range(iterations):
            var data = parse(content)

        var elapsed = perf_counter() - start
        var avg_time = elapsed / Float64(iterations)

        print("\nReal-world yaml_lite_working.yaml:")
        print("  Total:", format_time(elapsed), "for", iterations, "iterations")
        print("  Average:", format_time(avg_time), "per parse")
        print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")
    except:
        print("\nReal-world yaml_lite_working.yaml: SKIPPED (file not found)")


fn benchmark_pre_commit() raises:
    """Benchmark real-world pre_commit.yaml if it exists."""
    try:
        var path = Path("fixtures/pre_commit.yaml")
        var content = path.read_text()

        var iterations = 200
        var start = perf_counter()

        for i in range(iterations):
            var data = parse(content)

        var elapsed = perf_counter() - start
        var avg_time = elapsed / Float64(iterations)

        print("\nReal-world pre_commit.yaml:")
        print("  Total:", format_time(elapsed), "for", iterations, "iterations")
        print("  Average:", format_time(avg_time), "per parse")
        print("  Rate:", Int(Float64(iterations) / elapsed), "parses/sec")
    except:
        print("\nReal-world pre_commit.yaml: SKIPPED (file not found)")


fn main() raises:
    """Run all benchmarks."""
    print("=" * 60)
    print("mojo-yaml Performance Benchmark")
    print("=" * 60)

    benchmark_simple_sequence()
    benchmark_simple_mapping()
    benchmark_sequence_of_mappings()
    benchmark_nested_structure()
    benchmark_large_document()
    benchmark_real_yaml_lite()
    benchmark_pre_commit()

    print("\n" + "=" * 60)
    print("Benchmark Complete")
    print("=" * 60)
