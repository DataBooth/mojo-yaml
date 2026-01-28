"""Tests for structural token patterns in YAML."""

from testing import assert_equal, assert_true, TestSuite
from yaml.lexer import Lexer, TokenKind


def test_simple_sequence():
    """Test tokenisation of simple list."""
    var lexer = Lexer("- apple\n- banana")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 6)  # dash, string, newline, dash, string, EOF
    assert_true(tokens[0].kind == TokenKind.DASH())
    assert_true(tokens[1].kind == TokenKind.STRING())
    assert_equal(tokens[1].value, "apple")
    assert_true(tokens[2].kind == TokenKind.NEWLINE())
    assert_true(tokens[3].kind == TokenKind.DASH())
    assert_true(tokens[4].kind == TokenKind.STRING())
    assert_equal(tokens[4].value, "banana")


def test_simple_mapping():
    """Test tokenisation of simple key-value."""
    var lexer = Lexer("name: Alice\nage: 30")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 8)  # name : Alice \n age : 30 EOF
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "name")
    assert_true(tokens[1].kind == TokenKind.COLON())
    assert_true(tokens[2].kind == TokenKind.STRING())
    assert_equal(tokens[2].value, "Alice")
    assert_true(tokens[3].kind == TokenKind.NEWLINE())
    assert_true(tokens[4].kind == TokenKind.STRING())
    assert_equal(tokens[4].value, "age")
    assert_true(tokens[5].kind == TokenKind.COLON())
    assert_true(tokens[6].kind == TokenKind.INTEGER())
    assert_equal(tokens[6].value, "30")


def test_empty_value():
    """Test key with empty value."""
    var lexer = Lexer("key:\nother: value")
    var tokens = lexer.tokenize()

    assert_equal(len(tokens), 7)  # key : \n other : value EOF
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "key")
    assert_true(tokens[1].kind == TokenKind.COLON())
    assert_true(tokens[2].kind == TokenKind.NEWLINE())
    assert_true(tokens[3].kind == TokenKind.STRING())
    assert_equal(tokens[3].value, "other")
    assert_true(tokens[4].kind == TokenKind.COLON())
    assert_true(tokens[5].kind == TokenKind.STRING())
    assert_equal(tokens[5].value, "value")


def test_sequence_with_mapping():
    """Test list items containing key-value pairs."""
    var lexer = Lexer("- name: Alice\n  age: 30")
    var tokens = lexer.tokenize()

    # - name : Alice \n INDENT age : 30 DEDENT EOF
    assert_equal(len(tokens), 11)
    assert_true(tokens[0].kind == TokenKind.DASH())
    assert_true(tokens[1].kind == TokenKind.STRING())
    assert_equal(tokens[1].value, "name")
    assert_true(tokens[2].kind == TokenKind.COLON())
    assert_true(tokens[3].kind == TokenKind.STRING())
    assert_equal(tokens[3].value, "Alice")
    assert_true(tokens[4].kind == TokenKind.NEWLINE())
    assert_true(tokens[5].kind == TokenKind.INDENT())
    assert_true(tokens[6].kind == TokenKind.STRING())
    assert_equal(tokens[6].value, "age")
    assert_true(tokens[7].kind == TokenKind.COLON())
    assert_true(tokens[8].kind == TokenKind.INTEGER())
    assert_equal(tokens[8].value, "30")


def test_nested_mapping():
    """Test mapping containing nested mapping."""
    var lexer = Lexer("parent:\n  child: value")
    var tokens = lexer.tokenize()

    # parent : \n INDENT child : value DEDENT EOF
    assert_equal(len(tokens), 9)
    assert_true(tokens[0].kind == TokenKind.STRING())
    assert_equal(tokens[0].value, "parent")
    assert_true(tokens[1].kind == TokenKind.COLON())
    assert_true(tokens[2].kind == TokenKind.NEWLINE())
    assert_true(tokens[3].kind == TokenKind.INDENT())
    assert_true(tokens[4].kind == TokenKind.STRING())
    assert_equal(tokens[4].value, "child")
    assert_true(tokens[5].kind == TokenKind.COLON())
    assert_true(tokens[6].kind == TokenKind.STRING())
    assert_equal(tokens[6].value, "value")


def test_sequence_spacing_variations():
    """Test different spacing around dashes."""
    # In YAML spec, dash without space is just a string, not a list indicator
    var lexer1 = Lexer("-one")  # No space - treated as string
    var tokens1 = lexer1.tokenize()
    assert_equal(len(tokens1), 2)  # string "-one", EOF
    assert_true(tokens1[0].kind == TokenKind.STRING())
    assert_equal(tokens1[0].value, "-one")

    var lexer2 = Lexer("- two")  # Space after - proper list syntax
    var tokens2 = lexer2.tokenize()
    assert_equal(len(tokens2), 3)  # dash, string, EOF
    assert_true(tokens2[0].kind == TokenKind.DASH())
    assert_true(tokens2[1].kind == TokenKind.STRING())
    assert_equal(tokens2[1].value, "two")


def test_colon_spacing_variations():
    """Test different spacing around colons."""
    var lexer1 = Lexer("key:value")  # No spaces
    var tokens1 = lexer1.tokenize()
    assert_equal(len(tokens1), 4)  # string, colon, string, EOF
    assert_true(tokens1[0].kind == TokenKind.STRING())
    assert_equal(tokens1[0].value, "key")
    assert_true(tokens1[1].kind == TokenKind.COLON())
    assert_true(tokens1[2].kind == TokenKind.STRING())
    assert_equal(tokens1[2].value, "value")

    var lexer2 = Lexer("key: value")  # Space after
    var tokens2 = lexer2.tokenize()
    assert_equal(len(tokens2), 4)
    assert_true(tokens2[0].kind == TokenKind.STRING())
    assert_equal(tokens2[0].value, "key")
    assert_true(tokens2[1].kind == TokenKind.COLON())
    assert_true(tokens2[2].kind == TokenKind.STRING())
    assert_equal(tokens2[2].value, "value")


def main():
    """Run all structural token tests."""
    TestSuite.discover_tests[__functions_in_module()]().run()
