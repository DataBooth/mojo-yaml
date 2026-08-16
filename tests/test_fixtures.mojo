"""Tests for parsing real YAML fixture files.

These tests verify that real-world YAML files can be parsed correctly.
As the implementation progresses, these will become full integration tests.
"""

from std.testing import assert_true, assert_false, assert_equal, TestSuite
from yaml.lexer import Lexer


def test_can_read_pre_commit_fixture() raises:
    """Test that we can read .pre-commit-config.yaml fixture."""
    # For now, just verify the file can be loaded and basic lexer works
    var content = String("""repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: check-toml
      - id: check-yaml
""")

    var lexer = Lexer(content)
    # Basic validation - lexer can be created
    assert_equal(lexer.pos, 0)
    assert_equal(lexer.line, 1)


def test_can_read_github_workflow_fixture() raises:
    """Test that we can read GitHub Actions workflow fixture."""
    var content = String("""name: Tests

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
""")

    var lexer = Lexer(content)
    assert_equal(lexer.pos, 0)
    assert_equal(lexer.line, 1)


def test_can_read_docker_compose_fixture() raises:
    """Test that we can read docker-compose.yaml fixture."""
    var content = String("""version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
""")

    var lexer = Lexer(content)
    assert_equal(lexer.pos, 0)


def test_yaml_lite_example_structure() raises:
    """Test the yaml_lite_example.yaml fixture structure."""
    # This tests the example from fixtures/yaml_lite_example.yaml
    var content = String("""name: mojo-yaml
version: 0.1.0

server:
  host: localhost
  port: 8080
""")

    var lexer = Lexer(content)
    # Verify we can navigate through the content
    var first_char = lexer.current()
    assert_equal(first_char, "n")

    _ = lexer.advance()
    assert_equal(lexer.current(), "a")


def test_multiline_yaml() raises:
    """Test YAML with multiple levels of nesting."""
    var content = String("""config:
  api:
    endpoints:
      - name: users
        path: /api/users
      - name: posts
        path: /api/posts
""")

    var lexer = Lexer(content)
    # Basic lexer operations work
    assert_equal(lexer.line, 1)

    # Test indentation counting
    # First line has no indentation
    assert_equal(lexer.count_leading_spaces(), 0)


def test_yaml_with_lists() raises:
    """Test YAML with list items."""
    var content = String("""features:
  - block-style
  - nested structures
  - basic types
""")

    var lexer = Lexer(content)
    assert_equal(lexer.pos, 0)

    # Advance to first line
    var c = lexer.current()
    assert_equal(c, "f")


def test_yaml_with_quoted_strings() raises:
    """Test YAML with quoted strings."""
    var content = String("""message: "quoted string"
path: /unquoted/path
""")

    var lexer = Lexer(content)
    # Test quoted string detection
    var first = lexer.current()
    assert_equal(first, "m")


def test_yaml_with_numbers() raises:
    """Test YAML with numeric values."""
    var content = String("""count: 42
ratio: 3.14
negative: -17
""")

    var lexer = Lexer(content)
    assert_true(lexer.is_digit("4"))
    assert_true(lexer.is_digit("2"))
    assert_false(lexer.is_digit("a"))


def test_yaml_with_booleans() raises:
    """Test YAML with boolean values."""
    var content = String("""enabled: true
disabled: false
yes_value: yes
no_value: no
""")

    var lexer = Lexer(content)
    assert_equal(lexer.line, 1)


def test_yaml_with_null() raises:
    """Test YAML with null values."""
    var content = String("""empty: null
tilde: ~
""")

    var lexer = Lexer(content)
    assert_equal(lexer.pos, 0)


def test_yaml_with_comments() raises:
    """Test YAML with comments."""
    var content = String("""# This is a comment
key: value  # Inline comment
# Another comment
""")

    var lexer = Lexer(content)
    # Skip to first non-comment line would be tested when lexer is complete
    assert_equal(lexer.current(), "#")


def test_complex_nested_structure() raises:
    """Test complex nested YAML structure."""
    var content = String("""root:
  level1:
    level2:
      level3:
        deep_value: found
""")

    var lexer = Lexer(content)
    assert_equal(lexer.line, 1)
    # Test deep nesting parsing will be added when parser is complete


def test_sequence_of_mappings() raises:
    """Test sequence containing mappings (common in config files)."""
    var content = String("""repos:
  - repo: https://example.com/repo1
    rev: v1.0.0
  - repo: https://example.com/repo2
    rev: v2.0.0
""")

    var lexer = Lexer(content)
    assert_equal(lexer.pos, 0)


def test_empty_lines_handling() raises:
    """Test YAML with empty lines."""
    var content = String("""key1: value1

key2: value2


key3: value3
""")

    var lexer = Lexer(content)
    assert_equal(lexer.line, 1)


def test_mixed_indentation_detection() raises:
    """Test detection of different indentation levels."""
    var content = String("""no_indent: value
  two_spaces: value
    four_spaces: value
""")

    var lexer = Lexer(content)
    # First line - no indentation
    assert_equal(lexer.count_leading_spaces(), 0)


def main() raises:
    """Run all fixture tests."""
    TestSuite.discover_tests[__functions_in_module()]().run()
