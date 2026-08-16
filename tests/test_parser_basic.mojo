"""Tests for YAML parser basic functionality."""

from std.testing import assert_equal, assert_true, TestSuite
from yaml.lexer import Lexer
from yaml.parser import Parser
from yaml.value import YamlValue


def test_parse_empty() raises:
    """Test parsing empty input."""
    var lexer = Lexer("")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_null())


def test_parse_simple_string() raises:
    """Test parsing a simple string value."""
    var lexer = Lexer("hello")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_string())
    assert_equal(result.as_string(), "hello")


def test_parse_integer() raises:
    """Test parsing integer value."""
    var lexer = Lexer("42")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_int())
    assert_equal(result.as_int(), 42)


def test_parse_float() raises:
    """Test parsing float value."""
    var lexer = Lexer("3.14")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_float())
    # Note: Float comparison with tolerance
    var val = result.as_float()
    assert_true(val > 3.13 and val < 3.15)


def test_parse_boolean_true() raises:
    """Test parsing boolean true."""
    var lexer = Lexer("true")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_bool())
    assert_equal(result.as_bool(), True)


def test_parse_boolean_false() raises:
    """Test parsing boolean false."""
    var lexer = Lexer("false")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_bool())
    assert_equal(result.as_bool(), False)


def test_parse_null() raises:
    """Test parsing null value."""
    var lexer = Lexer("null")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_null())


def test_parse_simple_mapping() raises:
    """Test parsing a simple key-value mapping."""
    var lexer = Lexer("name: Alice")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_mapping())
    var mapping = result.as_mapping()
    assert_true("name" in mapping)
    assert_equal(mapping["name"].as_string(), "Alice")


def test_parse_multiple_keys() raises:
    """Test parsing multiple key-value pairs."""
    var lexer = Lexer("name: Alice\nage: 30")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_mapping())
    var mapping = result.as_mapping()
    assert_equal(len(mapping), 2)
    assert_equal(mapping["name"].as_string(), "Alice")
    assert_equal(mapping["age"].as_int(), 30)


def test_parse_simple_sequence() raises:
    """Test parsing a simple list."""
    var lexer = Lexer("- apple\n- banana")
    var tokens = lexer.tokenize()
    var parser = Parser(tokens^)
    var result = parser.parse()

    assert_true(result.is_sequence())
    var seq = result.as_sequence()
    assert_equal(len(seq), 2)
    assert_equal(seq[0].as_string(), "apple")
    assert_equal(seq[1].as_string(), "banana")


def main() raises:
    """Run all parser basic tests."""
    TestSuite.discover_tests[__functions_in_module()]().run()
