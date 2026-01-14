"""Tests for nested YAML structure parsing."""

from testing import assert_equal, assert_true, TestSuite
from yaml.lexer import Lexer
from yaml.parser import Parser


def test_nested_mapping():
    """Test parsing nested mappings."""
    var lexer = Lexer("parent:\n  child: value")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()
    
    assert_true(result.is_mapping())
    var parent = result.get("parent")
    assert_true(parent.is_mapping())
    assert_equal(parent.get("child").as_string(), "value")


def test_deeply_nested_mapping():
    """Test parsing deeply nested mappings."""
    var lexer = Lexer("level1:\n  level2:\n    level3: deep_value")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()
    
    assert_true(result.is_mapping())
    var level1 = result.get("level1")
    var level2 = level1.get("level2")
    assert_equal(level2.get("level3").as_string(), "deep_value")


def test_mapping_with_sequence():
    """Test mapping containing a sequence."""
    var lexer = Lexer("items:\n  - apple\n  - banana")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()
    
    assert_true(result.is_mapping())
    var items = result.get("items")
    assert_true(items.is_sequence())
    assert_equal(items.get_at(0).as_string(), "apple")
    assert_equal(items.get_at(1).as_string(), "banana")


def test_sequence_of_mappings():
    """Test sequence containing mappings."""
    var lexer = Lexer("- name: Alice\n  age: 30\n- name: Bob\n  age: 25")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()
    
    assert_true(result.is_sequence())
    var person1 = result.get_at(0)
    assert_equal(person1.get("name").as_string(), "Alice")
    assert_equal(person1.get("age").as_int(), 30)
    
    var person2 = result.get_at(1)
    assert_equal(person2.get("name").as_string(), "Bob")
    assert_equal(person2.get("age").as_int(), 25)


def test_complex_nested_structure():
    """Test complex nested structure with mappings and sequences."""
    var yaml = """config:
  servers:
    - host: localhost
      port: 8080
    - host: example.com
      port: 443
  enabled: true"""
    
    var lexer = Lexer(yaml)
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()
    
    assert_true(result.is_mapping())
    var config = result.get("config")
    
    # Check servers sequence
    var servers = config.get("servers")
    assert_true(servers.is_sequence())
    
    var server1 = servers.get_at(0)
    assert_equal(server1.get("host").as_string(), "localhost")
    assert_equal(server1.get("port").as_int(), 8080)
    
    var server2 = servers.get_at(1)
    assert_equal(server2.get("host").as_string(), "example.com")
    assert_equal(server2.get("port").as_int(), 443)
    
    # Check enabled flag
    assert_equal(config.get("enabled").as_bool(), True)


def test_multiple_top_level_keys():
    """Test multiple top-level keys with nested values."""
    var yaml = """api:
  endpoint: /users
  timeout: 30
database:
  host: localhost
  port: 5432"""
    
    var lexer = Lexer(yaml)
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()
    
    assert_true(result.is_mapping())
    
    var api = result.get("api")
    assert_equal(api.get("endpoint").as_string(), "/users")
    assert_equal(api.get("timeout").as_int(), 30)
    
    var db = result.get("database")
    assert_equal(db.get("host").as_string(), "localhost")
    assert_equal(db.get("port").as_int(), 5432)


def test_mixed_scalar_types():
    """Test nested structure with mixed scalar types."""
    var yaml = """settings:
  name: app
  version: 1.5
  debug: true
  max_retries: 3
  timeout: null"""
    
    var lexer = Lexer(yaml)
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()
    
    var settings = result.get("settings")
    
    assert_equal(settings.get("name").as_string(), "app")
    var version = settings.get("version").as_float()
    assert_true(version > 1.4 and version < 1.6)
    assert_equal(settings.get("debug").as_bool(), True)
    assert_equal(settings.get("max_retries").as_int(), 3)
    assert_true(settings.get("timeout").is_null())


def main():
    """Run all nested structure tests."""
    TestSuite.discover_tests[__functions_in_module()]().run()
