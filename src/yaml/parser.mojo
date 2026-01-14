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

from collections import List, Dict
from .lexer import Token, TokenKind, Position
from .value import YamlValue


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

    fn __init__(out self, var tokens: List[Token]):
        """Initialise parser with token stream.

        Args:
            tokens: List of tokens from lexer.
        """
        self.tokens = tokens^
        self.pos = 0

    fn current(self) -> Token:
        """Get current token without advancing.

        Returns:
            Current token or EOF if at end.
        """
        if self.pos >= len(self.tokens):
            return Token(TokenKind.EOF(), "", Position(0, 0))
        return self.tokens[self.pos].copy()

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
        return self.tokens[peek_pos].copy()

    fn advance(mut self) -> Token:
        """Consume and return current token.

        Returns:
            Current token or EOF if at end.
        """
        if self.pos >= len(self.tokens):
            return Token(TokenKind.EOF(), "", Position(0, 0))

        var token = self.tokens[self.pos].copy()
        self.pos += 1
        return token^

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
    
    fn skip_newlines(mut self):
        """Skip over NEWLINE tokens."""
        while self.current().kind == TokenKind.NEWLINE():
            _ = self.advance()
    
    fn parse(mut self) raises -> YamlValue:
        """Parse the token stream into a YamlValue.
        
        Returns:
            Root YamlValue (typically a mapping or sequence).
        
        Raises:
            Error: If parsing fails.
        """
        self.skip_newlines()
        
        if self.current().kind == TokenKind.EOF():
            # Empty document
            return YamlValue.null()
        
        return self.parse_value()
    
    fn parse_value(mut self) raises -> YamlValue:
        """Parse a value (scalar, mapping, or sequence).
        
        Dispatches to appropriate parsing method based on token type.
        
        Returns:
            Parsed YamlValue.
        """
        var token = self.current()
        
        # Check if this is a sequence (starts with dash)
        if token.kind == TokenKind.DASH():
            return self.parse_sequence()
        
        # Check if this is a mapping (key followed by colon)
        # Look for pattern: STRING/KEY COLON
        if token.kind == TokenKind.STRING():
            var next_token = self.peek()
            if next_token.kind == TokenKind.COLON():
                return self.parse_mapping()
        
        # Otherwise it's a scalar
        return self.parse_scalar()
    
    fn parse_scalar(mut self) raises -> YamlValue:
        """Parse a scalar value.
        
        Returns:
            YamlValue containing the scalar.
        """
        var token = self.advance()
        
        if token.kind == TokenKind.NULL():
            return YamlValue.null()
        elif token.kind == TokenKind.BOOLEAN():
            if token.value == "true" or token.value == "yes":
                return YamlValue.bool(True)
            else:
                return YamlValue.bool(False)
        elif token.kind == TokenKind.INTEGER():
            return YamlValue.integer(atol(token.value))
        elif token.kind == TokenKind.FLOAT():
            return YamlValue.float(atof(token.value))
        elif token.kind == TokenKind.STRING():
            return YamlValue.string(token.value)
        else:
            raise Error("Unexpected token kind for scalar at line " + String(token.pos.line))
    
    fn parse_mapping(mut self) raises -> YamlValue:
        """Parse a mapping (dictionary).
        
        Returns:
            YamlValue containing mapping.
        """
        var result = Dict[String, YamlValue]()
        
        # Keep parsing key:value pairs until we hit DEDENT or EOF
        while True:
            self.skip_newlines()
            
            var token = self.current()
            
            # Stop at EOF
            if token.kind == TokenKind.EOF():
                break
            
            # Stop at DEDENT (but we might see DEDENT from nested values that we should skip)
            if token.kind == TokenKind.DEDENT():
                break
            
            # Check for dash (sequence at same level - stop here)
            if token.kind == TokenKind.DASH():
                break
            
            # Handle INDENT - this continues the mapping at a deeper level
            if token.kind == TokenKind.INDENT():
                _ = self.advance()
                continue
            
            # Parse key
            if token.kind != TokenKind.STRING():
                raise Error("Expected key at line " + String(token.pos.line))
            
            var key = token.value
            _ = self.advance()
            
            # Expect colon
            _ = self.expect(TokenKind.COLON())
            
            self.skip_newlines()
            
            # Check if value is on next line (indented)
            if self.current().kind == TokenKind.INDENT():
                _ = self.advance()
                var value = self.parse_value()
                result[key] = value^
                
                # Consume DEDENT after indented value
                if self.current().kind == TokenKind.DEDENT():
                    _ = self.advance()
            else:
                # Value on same line
                var value = self.parse_value()
                result[key] = value^
            
            self.skip_newlines()
        
        return YamlValue.mapping(result^)
    
    fn parse_sequence(mut self) raises -> YamlValue:
        """Parse a sequence (list).
        
        Returns:
            YamlValue containing sequence.
        """
        var result = List[YamlValue]()
        
        # Keep parsing list items until we hit DEDENT or EOF
        while True:
            self.skip_newlines()
            
            var token = self.current()
            
            # Stop at DEDENT or EOF
            if token.kind == TokenKind.DEDENT() or token.kind == TokenKind.EOF():
                break
            
            # Expect dash
            if token.kind != TokenKind.DASH():
                break
            
            _ = self.advance()  # consume dash
            
            self.skip_newlines()
            
            # Check if item is on next line (indented)
            if self.current().kind == TokenKind.INDENT():
                _ = self.advance()
                var item = self.parse_value()
                result.append(item^)
                
                # Consume DEDENT after indented item
                if self.current().kind == TokenKind.DEDENT():
                    _ = self.advance()
            else:
                # Item on same line (but might have nested INDENT internally)
                var item = self.parse_value()
                result.append(item^)
                
                # If the item had nested content, consume the DEDENT
                if self.current().kind == TokenKind.DEDENT():
                    _ = self.advance()
            
            self.skip_newlines()
        
        return YamlValue.sequence(result^)
