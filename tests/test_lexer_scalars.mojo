"""Tests for YAML lexer scalar tokenisation."""

from std.testing import assert_equal, assert_true, TestSuite
from yaml.lexer import Lexer, TokenKind


def test_tokenize_integer() raises:
    """Test tokenising integer values."""
    var lexer = Lexer("42")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)  # INTEGER + EOF
    assert_true(tokens[0].kind == TokenKind.INTEGER())
    assert_equal(tokens[0].value, "42")


def test_tokenize_negative_integer() raises:
    """Test tokenising negative integer."""
    var lexer = Lexer("-17")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)
    assert_true(tokens[0].kind == TokenKind.INTEGER())
    assert_equal(tokens[0].value, "-17")


def test_tokenize_float() raises:
    """Test tokenising float values."""
    var lexer = Lexer("3.14")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)  # FLOAT + EOF
    assert_true(tokens[0].kind == TokenKind.FLOAT())
    assert_equal(tokens[0].value, "3.14")


def test_tokenize_scientific_notation() raises:
    """Test tokenising scientific notation."""
    var lexer = Lexer("1.5e10")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)
    assert_true(tokens[0].kind == TokenKind.FLOAT())
    assert_equal(tokens[0].value, "1.5e10")


def test_tokenize_boolean_true() raises:
    """Test tokenising boolean true."""
    var lexer = Lexer("true")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)  # BOOLEAN + EOF
    assert_true(tokens[0].kind == TokenKind.BOOLEAN())
    assert_equal(tokens[0].value, "true")


def test_tokenize_boolean_false() raises:
    """Test tokenising boolean false."""
    var lexer = Lexer("false")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)
    assert_true(tokens[0].kind == TokenKind.BOOLEAN())
    assert_equal(tokens[0].value, "false")


def test_tokenize_boolean_yes() raises:
    """Test tokenising boolean yes."""
    var lexer = Lexer("yes")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)
    assert_true(tokens[0].kind == TokenKind.BOOLEAN())
    assert_equal(tokens[0].value, "yes")


def test_tokenize_boolean_no() raises:
    """Test tokenising boolean no."""
    var lexer = Lexer("no")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)
    assert_true(tokens[0].kind == TokenKind.BOOLEAN())
    assert_equal(tokens[0].value, "no")


def test_tokenize_null() raises:
    """Test tokenising null."""
    var lexer = Lexer("null")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)  # NULL + EOF
    assert_true(tokens[0].kind == TokenKind.NULL())
    assert_equal(tokens[0].value, "null")


def test_tokenize_tilde_null() raises:
    """Test tokenising ~ as null."""
    var lexer = Lexer("~")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)
    assert_true(tokens[0].kind == TokenKind.NULL())
    assert_equal(tokens[0].value, "~")


def test_tokenize_quoted_string() raises:
    """Test tokenising double-quoted string."""
    var lexer = Lexer('"hello world"')
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)  # STRING + EOF
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "hello world")


def test_tokenize_single_quoted_string() raises:
    """Test tokenising single-quoted string."""
    var lexer = Lexer("'hello world'")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "hello world")


def test_tokenize_unquoted_string() raises:
    """Test tokenising unquoted string."""
    var lexer = Lexer("hello")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)  # STRING + EOF
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "hello")


def test_tokenize_colon() raises:
    """Test tokenising colon separator."""
    var lexer = Lexer(":")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)  # COLON + EOF
    assert_true(tokens[0].kind == TokenKind.COLON())


def test_tokenize_dash() raises:
    """Test tokenising dash (list indicator)."""
    var lexer = Lexer("- ")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 2)  # DASH + EOF
    assert_true(tokens[0].kind == TokenKind.DASH())


def main() raises:
    """Run all scalar tokenisation tests."""
    TestSuite.discover_tests[__functions_in_module()]().run()
