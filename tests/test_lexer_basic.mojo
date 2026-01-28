"""Basic tests for YAML lexer - position tracking and character navigation."""

from testing import assert_equal, assert_true, TestSuite
from yaml.lexer import Lexer, Token, TokenKind, Position


def test_lexer_initialization():
    """Test lexer initialises correctly."""
    var lexer = Lexer("test")
    assert_equal(lexer.pos, 0)
    assert_equal(lexer.line, 1)
    assert_equal(lexer.column, 1)


def test_current_character():
    """Test current() returns character without advancing."""
    var lexer = Lexer("abc")
    assert_equal(lexer.current(), "a")
    assert_equal(lexer.pos, 0)  # Should not advance


def test_current_at_eof():
    """Test current() returns empty string at EOF."""
    var lexer = Lexer("")
    assert_equal(lexer.current(), "")


def test_peek_character():
    """Test peek() looks ahead without advancing."""
    var lexer = Lexer("abc")
    assert_equal(lexer.peek(1), "b")
    assert_equal(lexer.peek(2), "c")
    assert_equal(lexer.pos, 0)  # Should not advance


def test_peek_at_eof():
    """Test peek() returns empty string when out of bounds."""
    var lexer = Lexer("a")
    assert_equal(lexer.peek(5), "")


def test_advance_character():
    """Test advance() consumes character and updates position."""
    var lexer = Lexer("abc")
    assert_equal(lexer.advance(), "a")
    assert_equal(lexer.pos, 1)
    assert_equal(lexer.column, 2)
    assert_equal(lexer.advance(), "b")
    assert_equal(lexer.pos, 2)


def test_advance_newline():
    """Test advance() handles newlines correctly."""
    var lexer = Lexer("a\nb")
    _ = lexer.advance()  # 'a'
    assert_equal(lexer.line, 1)
    assert_equal(lexer.column, 2)

    _ = lexer.advance()  # '\n'
    assert_equal(lexer.line, 2)
    assert_equal(lexer.column, 1)

    _ = lexer.advance()  # 'b'
    assert_equal(lexer.line, 2)
    assert_equal(lexer.column, 2)


def test_count_leading_spaces():
    """Test count_leading_spaces() counts indentation."""
    var lexer1 = Lexer("  text")
    assert_equal(lexer1.count_leading_spaces(), 2)

    var lexer2 = Lexer("    text")
    assert_equal(lexer2.count_leading_spaces(), 4)

    var lexer3 = Lexer("text")
    assert_equal(lexer3.count_leading_spaces(), 0)


def test_skip_whitespace():
    """Test skip_whitespace() skips spaces but not newlines."""
    var lexer = Lexer("   \t  a")
    lexer.skip_whitespace()
    assert_equal(lexer.current(), "a")

    var lexer2 = Lexer("  \na")
    lexer2.skip_whitespace()
    assert_equal(lexer2.current(), "\n")  # Should stop at newline


def test_tokenize_empty():
    """Test tokenize() on empty input."""
    var lexer = Lexer("")
    var tokens = lexer.tokenize()
    assert_equal(len(tokens), 1)
    assert_true(tokens[0].kind == TokenKind.EOF())


def main():
    # Automatic test discovery and execution using TestSuite
    TestSuite.discover_tests[__functions_in_module()]().run()
