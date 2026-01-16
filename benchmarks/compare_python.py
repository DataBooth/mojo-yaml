#!/usr/bin/env python3
"""Comparative benchmarks: mojo-yaml vs Python pyyaml.

Compares parsing performance between mojo-yaml and Python's pyyaml library.

Run with: pixi run benchmark-python
"""

import sys
import time
import yaml  # pyyaml
from pathlib import Path

# Import benchmark utilities
sys.path.insert(0, str(Path(__file__).parent))
from machine_info import get_system_info, format_system_info, get_timestamp
from report_utils import generate_report, save_report


# Test documents (matching Mojo benchmarks)
SIMPLE_SEQUENCE = """- apple
- banana
- cherry
- date
- elderberry
"""

SIMPLE_MAPPING = """name: Alice
age: 30
city: Sydney
email: alice@example.com
active: true
"""

SEQUENCE_OF_MAPPINGS = """- name: Alice
  age: 30
  city: Sydney
- name: Bob
  age: 25
  city: Melbourne
- name: Charlie
  age: 35
  city: Brisbane
"""

NESTED_STRUCTURE = """database:
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

LARGE_DOCUMENT = """users:
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


def benchmark_python_parse(yaml_content: str, iterations: int = 1000) -> tuple[float, int]:
    """Benchmark Python's pyyaml parsing. Returns (elapsed_time, iterations)."""
    start = time.perf_counter()
    for _ in range(iterations):
        _ = yaml.safe_load(yaml_content)
    elapsed = time.perf_counter() - start
    return elapsed, iterations


def format_time(seconds: float) -> str:
    """Format time in appropriate units."""
    if seconds < 0.001:
        return f"{seconds * 1_000_000:.0f} μs"
    elif seconds < 1.0:
        return f"{seconds * 1_000:.1f} ms"
    else:
        return f"{seconds:.2f} s"


def format_rate(rate: float) -> str:
    """Format rate with thousands separator."""
    if rate >= 1_000_000:
        return f"{rate / 1_000_000:.2f}M/sec"
    elif rate >= 1_000:
        return f"{rate / 1_000:.1f}K/sec"
    else:
        return f"{rate:.0f}/sec"


def run_parse_benchmark(name: str, yaml_content: str, iterations: int = 1000) -> dict:
    """Run and display Python parsing benchmark. Returns result dict."""
    print(f"\n{name}:")

    py_time, py_iters = benchmark_python_parse(yaml_content, iterations)
    py_rate = py_iters / py_time
    py_avg = py_time / py_iters

    print(f"  Python (pyyaml):  {format_time(py_avg)} per parse  |  {format_rate(py_rate)}")

    return {
        "Test": name,
        "Avg Time": format_time(py_avg),
        "Rate": format_rate(py_rate),
        "Iterations": py_iters
    }


def main():
    """Run all comparison benchmarks."""
    print("=" * 70)
    print("Python YAML Baseline Benchmarks (pyyaml)")
    print("=" * 70)

    # Display system info
    print("\nSystem Information:")
    sys_info = get_system_info()
    print(format_system_info(sys_info))
    print(f"  Timestamp: {get_timestamp()}")

    # Add pyyaml version
    try:
        import yaml
        sys_info["pyyaml"] = yaml.__version__
        print(f"  pyyaml: {yaml.__version__}")
    except:
        sys_info["pyyaml"] = "Unknown"

    print("\nThese establish baseline performance for comparison with mojo-yaml.")
    print("Run 'pixi run benchmark-mojo' to see mojo-yaml performance.")

    # Collect parse results
    print("\n\nParsing Benchmarks (pyyaml):")
    print("=" * 70)

    parse_results = []
    parse_results.append(run_parse_benchmark("Simple sequence (5 items)", SIMPLE_SEQUENCE, 1000))
    parse_results.append(run_parse_benchmark("Simple mapping (5 key-value pairs)", SIMPLE_MAPPING, 1000))
    parse_results.append(run_parse_benchmark("Sequence of mappings (3 items, 9 keys)", SEQUENCE_OF_MAPPINGS, 1000))
    parse_results.append(run_parse_benchmark("Nested structure (2 levels, mixed types)", NESTED_STRUCTURE, 1000))
    parse_results.append(run_parse_benchmark("Large document (3 sections, 30+ values)", LARGE_DOCUMENT, 500))

    # Test real-world files if they exist
    yaml_lite_path = Path("fixtures/yaml_lite_working.yaml")
    if yaml_lite_path.exists():
        content = yaml_lite_path.read_text()
        parse_results.append(run_parse_benchmark("Real-world yaml_lite_working.yaml", content, 500))
    else:
        print("\nReal-world yaml_lite_working.yaml: SKIPPED (file not found)")

    pre_commit_path = Path("fixtures/pre_commit.yaml")
    if pre_commit_path.exists():
        content = pre_commit_path.read_text()
        parse_results.append(run_parse_benchmark("Real-world pre_commit.yaml", content, 200))
    else:
        print("\nReal-world pre_commit.yaml: SKIPPED (file not found)")

    print("\n" + "=" * 70)
    print("Benchmark Complete")
    print("=" * 70)

    # Generate and save markdown report
    report = generate_report(
        title="Python YAML Baseline Benchmarks",
        description="Baseline performance measurements for Python's pyyaml library. These establish comparison baselines for mojo-yaml.",
        parse_results=parse_results,
        write_results=None,
        notes="These benchmarks use Python's `pyyaml` library (`yaml.safe_load()`). Run `pixi run benchmark-mojo` to see mojo-yaml performance."
    )

    report_dir = Path(__file__).parent / "reports"
    report_path = save_report(report, report_dir, "python_baseline.md")

    print(f"\nMarkdown report saved to: {report_path}")
    print("\nNote: These are Python baseline numbers.")
    print("For mojo-yaml performance, run: pixi run benchmark-mojo")


if __name__ == "__main__":
    main()
