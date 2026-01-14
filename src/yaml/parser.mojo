"""Parser for YAML files.

# Why: Purpose of the Parser
The parser is the second stage of YAML parsing. It consumes the token stream
from the lexer and builds a nested YamlValue structure representing the document.

Example transformation:
    Input tokens:  [KEY("server"), COLON, NEWLINE, INDENT, KEY("host"), COLON, STRING("localhost")]
    Output:        YamlValue(dict: {"server": {"host": "localhost"}})

# What: Responsibilities
- Consume token stream from lexer
- Build nested YamlValue structure (mappings and sequences)
- Track indentation levels to determine nesting
- Validate YAML structure rules
- Provide clear error messages with line/column context

# How: Parser Design
Recursive descent parser with indentation tracking:
1. parse_value() - dispatcher (mapping? sequence? scalar?)
2. parse_mapping() - collect key:value pairs at same indent level
3. parse_sequence() - collect - items at same indent level
4. parse_scalar() - convert token to YamlValue

The parser tracks indentation via INDENT/DEDENT tokens from the lexer,
allowing it to determine when to stop collecting items for a mapping or sequence.

# YAML-Specific Handling
- Indentation determines nesting (INDENT = nest deeper, DEDENT = return to outer level)
- Mappings: key: value (can be nested)
- Sequences: - item (can contain mappings or other sequences)
- Scalars: Convert tokens to appropriate YamlValue types
"""

from collections import List
from .lexer import Token, TokenKind, Position


struct Parser:
    """Parser for YAML token stream.

    The parser builds a nested YamlValue structure from tokens produced
    by the lexer. It handles:
    - Recursive mapping and sequence parsing
    - Indentation-based nesting
    - Type conversion for scalars
    - Error messages with position context

    Usage:
        var tokens = lexer.tokenize()
        var parser = Parser(tokens)
        var result = parser.parse()  # Returns YamlValue
    """

    var tokens: List[Token]
    var pos: Int  # Current position in token stream

    fn __init__(out self, tokens: List[Token]):
        """Initialise parser with token stream.

        Args:
            tokens: List of tokens from lexer.
        """
        self.tokens = tokens
        self.pos = 0

    fn current(self) -> Token:
        """Get current token without advancing.

        Returns:
            Current token or EOF if at end.
        """
        if self.pos >= len(self.tokens):
            return Token(TokenKind.EOF(), "", Position(0, 0))
        return self.tokens[self.pos]

    fn peek(self, offset: Int = 1) -> Token:
        """Look ahead at token without consuming it.

        Args:
            offset: Number of tokens to look ahead (default: 1).

        Returns:
            Token at pos + offset or EOF if out of bounds.
        """
        var peek_pos = self.pos + offset
        if peek_pos >= len(self.tokens):
            return Token(TokenKind.EOF(), "", Position(0, 0))
        return self.tokens[peek_pos]

    fn advance(mut self) -> Token:
        """Consume and return current token.

        Returns:
            Current token or EOF if at end.
        """
        if self.pos >= len(self.tokens):
            return Token(TokenKind.EOF(), "", Position(0, 0))

        var token = self.tokens[self.pos]
        self.pos += 1
        return token

    fn expect(mut self, expected: TokenKind) raises -> Token:
        """Consume token and verify it matches expected kind.

        Args:
            expected: The expected token kind.

        Returns:
            The token if it matches.

        Raises:
            Error: If token doesn't match expected kind.
        """
        var token = self.current()
        if token.kind != expected:
            raise Error("Expected token type at line " + String(token.pos.line) + 
                       ", column " + String(token.pos.column))

        return self.advance()
