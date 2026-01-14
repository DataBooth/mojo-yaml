"""Tests for YAML lexer indentation tracking.

Validates INDENT/DEDENT token emission based on indentation changes.
"""

from testing import assert_equal, assert_true, TestSuite
from yaml.lexer import Lexer, TokenKind


def test_simple_indent():
    """Test single level of indentation."""
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
    assert_true(tokens[7].kind == TokenKind.DEDENT())


def test_simple_dedent():
    """Test dedent back to base level."""
    var lexer = Lexer("outer:\n  inner: 1\nback: 2")
    var tokens = lexer.tokenize()
    
    # outer : \n INDENT inner : 1 \n DEDENT back : 2 EOF
    assert_equal(len(tokens), 13)
    assert_true(tokens[0].kind == TokenKind.STRING())  # outer
    assert_true(tokens[1].kind == TokenKind.COLON())
    assert_true(tokens[2].kind == TokenKind.NEWLINE())
    assert_true(tokens[3].kind == TokenKind.INDENT())
    assert_true(tokens[4].kind == TokenKind.STRING())  # inner
    assert_true(tokens[5].kind == TokenKind.COLON())
    assert_true(tokens[6].kind == TokenKind.INTEGER())  # 1
    assert_true(tokens[7].kind == TokenKind.NEWLINE())
    assert_true(tokens[8].kind == TokenKind.DEDENT())
    assert_true(tokens[9].kind == TokenKind.STRING())  # back
    assert_true(tokens[10].kind == TokenKind.COLON())
    assert_true(tokens[11].kind == TokenKind.INTEGER())  # 2


def test_multiple_indent_levels():
    """Test nested indentation (multiple levels)."""
    var lexer = Lexer("a:\n  b:\n    c: value")
    var tokens = lexer.tokenize()
    
    # a : \n INDENT b : \n INDENT c : value DEDENT DEDENT EOF
    assert_equal(len(tokens), 14)
    assert_true(tokens[0].kind == TokenKind.STRING())  # a
    assert_true(tokens[2].kind == TokenKind.NEWLINE())
    assert_true(tokens[3].kind == TokenKind.INDENT())
    assert_true(tokens[4].kind == TokenKind.STRING())  # b
    assert_true(tokens[6].kind == TokenKind.NEWLINE())
    assert_true(tokens[7].kind == TokenKind.INDENT())
    assert_true(tokens[8].kind == TokenKind.STRING())  # c
    assert_true(tokens[11].kind == TokenKind.DEDENT())
    assert_true(tokens[12].kind == TokenKind.DEDENT())


def test_multiple_dedents():
    """Test dedenting multiple levels at once."""
    var lexer = Lexer("a:\n  b:\n    c: 1\nback: 2")
    var tokens = lexer.tokenize()
    
    # Should have 2 DEDENT tokens when going from level 2 back to 0
    var dedent_count = 0
    for i in range(len(tokens)):
        if tokens[i].kind == TokenKind.DEDENT():
            dedent_count += 1
    
    assert_equal(dedent_count, 2)


def test_blank_line_ignored():
    """Test that blank lines don't affect indentation."""
    var lexer = Lexer("parent:\n\n  child: value")
    var tokens = lexer.tokenize()
    
    # Blank line should not create extra INDENT/DEDENT
    var indent_count = 0
    var dedent_count = 0
    for i in range(len(tokens)):
        if tokens[i].kind == TokenKind.INDENT():
            indent_count += 1
        if tokens[i].kind == TokenKind.DEDENT():
            dedent_count += 1
    
    assert_equal(indent_count, 1)
    assert_equal(dedent_count, 1)


def test_comment_line_ignored():
    """Test that comment-only lines don't affect indentation."""
    var lexer = Lexer("parent:\n  # comment\n  child: value")
    var tokens = lexer.tokenize()
    
    # Comment line should not create extra INDENT/DEDENT
    var indent_count = 0
    var dedent_count = 0
    for i in range(len(tokens)):
        if tokens[i].kind == TokenKind.INDENT():
            indent_count += 1
        if tokens[i].kind == TokenKind.DEDENT():
            dedent_count += 1
    
    assert_equal(indent_count, 1)
    assert_equal(dedent_count, 1)


def test_list_with_indented_items():
    """Test list items with nested content."""
    var lexer = Lexer("items:\n  - name: Alice\n    age: 30")
    var tokens = lexer.tokenize()
    
    # items : \n INDENT - name : Alice \n INDENT age : 30 DEDENT DEDENT EOF
    # Note: 4-space indent for 'age' is deeper than 2-space indent for dash
    assert_equal(len(tokens), 16)
    assert_true(tokens[0].kind == TokenKind.STRING())  # items
    assert_true(tokens[2].kind == TokenKind.NEWLINE())
    assert_true(tokens[3].kind == TokenKind.INDENT())
    assert_true(tokens[4].kind == TokenKind.DASH())
    assert_true(tokens[5].kind == TokenKind.STRING())  # name


def test_same_indent_no_tokens():
    """Test that same indentation level doesn't emit tokens."""
    var lexer = Lexer("key1: val1\nkey2: val2")
    var tokens = lexer.tokenize()
    
    # No INDENT/DEDENT tokens should be present
    for i in range(len(tokens)):
        assert_true(tokens[i].kind != TokenKind.INDENT())
        assert_true(tokens[i].kind != TokenKind.DEDENT())


def test_dedent_at_eof():
    """Test that DEDENT tokens are emitted at EOF."""
    var lexer = Lexer("a:\n  b:\n    c: value")
    var tokens = lexer.tokenize()
    
    # Should have 2 INDENT and 2 DEDENT (at EOF)
    var indent_count = 0
    var dedent_count = 0
    for i in range(len(tokens)):
        if tokens[i].kind == TokenKind.INDENT():
            indent_count += 1
        if tokens[i].kind == TokenKind.DEDENT():
            dedent_count += 1
    
    assert_equal(indent_count, 2)
    assert_equal(dedent_count, 2)


def test_mixed_indentation_with_lists():
    """Test complex structure with mappings and sequences."""
    var lexer = Lexer("config:\n  servers:\n    - host: localhost\n      port: 8080")
    var tokens = lexer.tokenize()
    
    # config : \n INDENT servers : \n INDENT - host : localhost \n INDENT port : 8080 DEDENT DEDENT DEDENT EOF
    # Note: 6-space indent for 'port' is deeper than 4-space dash line
    var indent_count = 0
    var dedent_count = 0
    for i in range(len(tokens)):
        if tokens[i].kind == TokenKind.INDENT():
            indent_count += 1
        if tokens[i].kind == TokenKind.DEDENT():
            dedent_count += 1
    
    assert_equal(indent_count, 3)
    assert_equal(dedent_count, 3)


def main():
    """Run all indentation tests."""
    TestSuite.discover_tests[__functions_in_module()]().run()
