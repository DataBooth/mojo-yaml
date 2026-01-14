"""Lexer for YAML files.

# Why: Purpose of the Lexer
The lexer (tokeniser) is the first stage of YAML parsing. It converts raw text into
a stream of meaningful tokens, making it easier for the parser to understand structure.

Example transformation:
    Input:  'server:\\n  host: localhost  # comment'
    Output: [KEY("server"), COLON, NEWLINE, INDENT, KEY("host"), COLON, STRING("localhost"), COMMENT("comment")]

# What: Responsibilities
- Break YAML text into atomic units (tokens)
- Identify token types (keys, values, structural elements)
- Track indentation levels (critical for block-style YAML)
- Handle comments (# to end of line)
- Identify scalar types (string, number, bool, null)
- Track line/column positions for error messages

# How: Lexer Design
The lexer uses a character-by-character scanner with indentation tracking:
1. Read current character
2. Track indentation at start of each line
3. Emit INDENT/DEDENT tokens when indentation changes
4. Determine token type (key? value? comment?)
5. Consume characters until token complete
6. Emit token with type, value, and position
7. Repeat until EOF

This design keeps the parser simple—it works with high-level tokens rather than
raw characters, making YAML syntax rules easier to implement.

# YAML-Specific Handling
- Indentation: Track indent stack, emit INDENT/DEDENT tokens
- Mappings: key: value (colon separator)
- Sequences: - item (dash indicator)
- Comments: # comment (to end of line)
- Scalars: Quoted strings, unquoted strings, numbers, booleans, null
"""

from collections import List


@register_passable("trivial")
struct Position:
    """Position in the source file (line and column).

    Used for error messages to show users exactly where parsing failed.
    Example: "Error at line 5, column 12: unexpected character"
    """
    var line: Int
    var column: Int

    fn __init__(out self, line: Int, column: Int):
        self.line = line
        self.column = column


@register_passable("trivial")
struct TokenKind:
    """Token types for YAML lexer.

    YAML uses indentation for structure, unlike INI/TOML which use brackets.
    """
    var _value: Int

    fn __init__(out self, value: Int):
        self._value = value

    # Special tokens
    @staticmethod
    fn EOF() -> TokenKind:
        """End of file marker."""
        return TokenKind(0)

    @staticmethod
    fn NEWLINE() -> TokenKind:
        """Line break (separates elements)."""
        return TokenKind(1)

    @staticmethod
    fn INDENT() -> TokenKind:
        """Increased indentation (nesting deeper)."""
        return TokenKind(2)

    @staticmethod
    fn DEDENT() -> TokenKind:
        """Decreased indentation (returning to outer level)."""
        return TokenKind(3)

    @staticmethod
    fn COMMENT() -> TokenKind:
        """Comment text after # symbol."""
        return TokenKind(4)

    # Scalars (values)
    @staticmethod
    fn STRING() -> TokenKind:
        """String literal: "quoted" or 'quoted' or unquoted."""
        return TokenKind(10)

    @staticmethod
    fn INTEGER() -> TokenKind:
        """Integer: 42, -17, 0."""
        return TokenKind(11)

    @staticmethod
    fn FLOAT() -> TokenKind:
        """Float: 3.14, -0.5, 1.5e10."""
        return TokenKind(12)

    @staticmethod
    fn BOOLEAN() -> TokenKind:
        """Boolean: true, false, yes, no."""
        return TokenKind(13)

    @staticmethod
    fn NULL() -> TokenKind:
        """Null: null, ~."""
        return TokenKind(14)

    # Structural elements
    @staticmethod
    fn KEY() -> TokenKind:
        """Key name before colon."""
        return TokenKind(20)

    @staticmethod
    fn COLON() -> TokenKind:
        """Mapping separator: :."""
        return TokenKind(21)

    @staticmethod
    fn DASH() -> TokenKind:
        """Sequence indicator: -."""
        return TokenKind(22)

    fn __eq__(self, other: TokenKind) -> Bool:
        return self._value == other._value

    fn __ne__(self, other: TokenKind) -> Bool:
        return self._value != other._value


struct Token(Copyable, Movable):
    """A token in the YAML input stream.

    Represents a single meaningful unit of YAML syntax with its type,
    content, and location in the source file.
    """
    var kind: TokenKind
    var value: String  # The actual text content
    var pos: Position  # Where it appears in the file

    fn __init__(out self, kind: TokenKind, value: String, pos: Position):
        self.kind = kind
        self.value = value
        self.pos = pos

    fn copy(self) -> Self:
        """Create a copy of this token."""
        return Token(self.kind, self.value, self.pos)


struct Lexer:
    """Tokeniser for YAML input.

    The lexer scans YAML text character-by-character and produces a stream
    of tokens. It handles:
    - Indentation tracking (INDENT/DEDENT tokens)
    - Mappings (key: value)
    - Sequences (- item)
    - Comments (# to end of line)
    - Scalar types (strings, numbers, booleans, null)
    - Position tracking for error messages

    Usage:
        var lexer = Lexer("server:\\n  host: localhost")
        var tokens = lexer.tokenize()  # Returns List[Token]
    """

    var input: String
    var pos: Int      # Current position in input
    var line: Int     # Current line number (1-indexed)
    var column: Int   # Current column number (1-indexed)
    var indent_stack: List[Int]  # Track indentation levels for INDENT/DEDENT
    var at_line_start: Bool  # Are we at the start of a line?

    fn __init__(out self, input: String):
        """Initialise lexer with YAML input.

        Args:
            input: YAML content to tokenise.
        """
        self.input = input
        self.pos = 0
        self.line = 1
        self.column = 1
        self.indent_stack = List[Int]()
        self.indent_stack.append(0)  # Base indentation level
        self.at_line_start = True

    fn current(self) -> String:
        """Get current character without advancing.

        Returns:
            Current character or empty string if at EOF.
        """
        if self.pos >= len(self.input):
            return ""
        return String(self.input[self.pos])

    fn peek(self, offset: Int = 1) -> String:
        """Look ahead at character without consuming it.

        Args:
            offset: Number of characters to look ahead (default: 1).

        Returns:
            Character at pos + offset or empty string if out of bounds.
        """
        var peek_pos = self.pos + offset
        if peek_pos >= len(self.input):
            return ""
        return String(self.input[peek_pos])

    fn advance(mut self) -> String:
        """Consume and return current character.

        Advances position and updates line/column tracking for error messages.

        Returns:
            Current character or empty string if at EOF.
        """
        if self.pos >= len(self.input):
            return ""

        var c = String(self.input[self.pos])
        self.pos += 1

        if c == "\n":
            self.line += 1
            self.column = 1
            self.at_line_start = True
        else:
            self.column += 1
            if c != " " and c != "\t":
                self.at_line_start = False

        return c

    fn count_leading_spaces(self) -> Int:
        """Count spaces at start of current line.

        Returns:
            Number of leading spaces (tabs count as 1 space for simplicity).
        """
        var count = 0
        var temp_pos = self.pos

        while temp_pos < len(self.input):
            var c = String(self.input[temp_pos])
            if c == " " or c == "\t":
                count += 1
                temp_pos += 1
            else:
                break

        return count

    fn skip_whitespace(mut self):
        """Skip whitespace characters (space, tab) but not newlines.

        Newlines are significant in YAML for structure.
        """
        while self.pos < len(self.input):
            var c = self.current()
            if c == " " or c == "\t":
                _ = self.advance()
            else:
                break

    fn read_comment(mut self) raises -> Token:
        """Read a comment starting with #.

        Comments run from # to end of line.
        Example: key: value  # This is a comment

        Returns:
            Comment token (excluding the # character).
        """
        var start_pos = Position(self.line, self.column)
        _ = self.advance()  # Skip #

        var comment = String("")
        while self.pos < len(self.input):
            var c = self.current()
            if c == "\n":
                break
            comment += self.advance()

        return Token(TokenKind.COMMENT(), String(comment.strip()), start_pos)

    fn read_quoted_string(mut self, quote: String) raises -> Token:
        """Read a quoted string (single or double quotes).

        Args:
            quote: The quote character (" or ').

        Returns:
            STRING token with content (without quotes).

        Raises:
            Error: If string not properly closed.
        """
        var start_pos = Position(self.line, self.column)
        _ = self.advance()  # Skip opening quote

        var content = String("")
        while self.pos < len(self.input):
            var c = self.current()
            if c == quote:
                _ = self.advance()  # Skip closing quote
                return Token(TokenKind.STRING(), content, start_pos)
            elif c == "\n":
                raise Error("Unterminated string at line " + String(self.line))
            else:
                content += self.advance()

        raise Error("Unterminated string at end of file")

    fn is_digit(self, c: String) -> Bool:
        """Check if character is a digit."""
        return c >= "0" and c <= "9"

    fn is_alpha(self, c: String) -> Bool:
        """Check if character is alphabetic."""
        return (c >= "a" and c <= "z") or (c >= "A" and c <= "Z")

    fn is_key_char(self, c: String) -> Bool:
        """Check if character can be part of an unquoted key."""
        return self.is_alpha(c) or self.is_digit(c) or c == "_" or c == "-"

    fn scan_number(mut self) raises -> Token:
        """Scan a number (integer or float).
        
        Returns:
            INTEGER or FLOAT token.
        """
        var start_pos = Position(self.line, self.column)
        var num_str = String("")
        var is_float = False
        
        # Handle negative numbers
        if self.current() == "-":
            num_str += self.advance()
        
        # Read digits before decimal point
        while self.pos < len(self.input) and self.is_digit(self.current()):
            num_str += self.advance()
        
        # Check for decimal point
        if self.current() == "." and self.is_digit(self.peek()):
            is_float = True
            num_str += self.advance()  # consume '.'
            while self.pos < len(self.input) and self.is_digit(self.current()):
                num_str += self.advance()
        
        # Check for scientific notation (e.g., 1.5e10)
        if self.current() == "e" or self.current() == "E":
            is_float = True
            num_str += self.advance()
            if self.current() == "+" or self.current() == "-":
                num_str += self.advance()
            while self.pos < len(self.input) and self.is_digit(self.current()):
                num_str += self.advance()
        
        if is_float:
            return Token(TokenKind.FLOAT(), num_str, start_pos)
        else:
            return Token(TokenKind.INTEGER(), num_str, start_pos)

    fn scan_unquoted_string(mut self) raises -> Token:
        """Scan an unquoted string or keyword.
        
        This handles unquoted values, keys, and keywords like true/false/null.
        
        Returns:
            STRING, BOOLEAN, or NULL token depending on content.
        """
        var start_pos = Position(self.line, self.column)
        var text = String("")
        
        # Read until we hit a special character
        while self.pos < len(self.input):
            var c = self.current()
            if c == ":" or c == "#" or c == "\n" or c == " " or c == "\t":
                break
            text += self.advance()
        
        # Check for special keywords
        var trimmed = String(text.strip())
        if trimmed == "true" or trimmed == "false" or trimmed == "yes" or trimmed == "no":
            return Token(TokenKind.BOOLEAN(), trimmed, start_pos)
        elif trimmed == "null" or trimmed == "~":
            return Token(TokenKind.NULL(), trimmed, start_pos)
        else:
            return Token(TokenKind.STRING(), trimmed, start_pos)

    fn tokenize(mut self) raises -> List[Token]:
        """Tokenise YAML input into token stream.

        Returns:
            List of tokens.

        Raises:
            Error: If syntax error encountered.
        """
        var tokens = List[Token]()

        while self.pos < len(self.input):
            # Handle indentation at line start
            if self.at_line_start:
                var indent_level = self.count_leading_spaces()
                
                # Skip blank lines and comment-only lines for indentation tracking
                var temp_pos = self.pos + indent_level
                if temp_pos >= len(self.input) or String(self.input[temp_pos]) == "\n" or String(self.input[temp_pos]) == "#":
                    # Blank or comment line - don't change indentation
                    self.at_line_start = False
                else:
                    # Real content - process indentation change
                    var current_indent = self.indent_stack[len(self.indent_stack) - 1]
                    
                    if indent_level > current_indent:
                        # Increased indentation - emit INDENT
                        tokens.append(Token(TokenKind.INDENT(), "", Position(self.line, self.column)))
                        self.indent_stack.append(indent_level)
                    elif indent_level < current_indent:
                        # Decreased indentation - emit DEDENT(s)
                        while len(self.indent_stack) > 1 and self.indent_stack[len(self.indent_stack) - 1] > indent_level:
                            tokens.append(Token(TokenKind.DEDENT(), "", Position(self.line, self.column)))
                            _ = self.indent_stack.pop()
                        
                        # Check for indentation mismatch
                        if len(self.indent_stack) > 0 and self.indent_stack[len(self.indent_stack) - 1] != indent_level:
                            raise Error("Indentation mismatch at line " + String(self.line))
                    
                    self.at_line_start = False
            
            var c = self.current()
            
            # Skip whitespace (but track for indentation later)
            if c == " " or c == "\t":
                self.skip_whitespace()
                continue
            
            # Newline
            if c == "\n":
                tokens.append(Token(TokenKind.NEWLINE(), "\n", Position(self.line, self.column)))
                _ = self.advance()
                self.at_line_start = True
                continue
            
            # Comment
            if c == "#":
                tokens.append(self.read_comment())
                continue
            
            # Colon (mapping separator)
            if c == ":":
                tokens.append(Token(TokenKind.COLON(), ":", Position(self.line, self.column)))
                _ = self.advance()
                # Skip space after colon
                if self.current() == " ":
                    self.skip_whitespace()
                continue
            
            # Dash (sequence indicator) - must be followed by space
            if c == "-" and (self.peek() == " " or self.peek() == "\n"):
                tokens.append(Token(TokenKind.DASH(), "-", Position(self.line, self.column)))
                _ = self.advance()
                self.skip_whitespace()
                continue
            
            # Quoted strings
            if c == '"' or c == "'":
                tokens.append(self.read_quoted_string(c))
                continue
            
            # Numbers (including negative)
            if self.is_digit(c) or (c == "-" and self.is_digit(self.peek())):
                tokens.append(self.scan_number())
                continue
            
            # Tilde (null shorthand)
            if c == "~":
                tokens.append(Token(TokenKind.NULL(), "~", Position(self.line, self.column)))
                _ = self.advance()
                continue
            
            # Unquoted strings, keys, or keywords (true/false/null/etc.)
            # Also handle '-' that's not a list indicator or negative number
            if self.is_alpha(c) or c == "_" or c == "/" or c == "." or c == "-":
                tokens.append(self.scan_unquoted_string())
                continue
            
            # Unknown character - raise error
            raise Error("Unexpected character '" + c + "' at line " + String(self.line) + 
                       ", column " + String(self.column))
        
        # Emit remaining DEDENT tokens at EOF
        while len(self.indent_stack) > 1:
            tokens.append(Token(TokenKind.DEDENT(), "", Position(self.line, self.column)))
            _ = self.indent_stack.pop()
        
        # Add EOF token
        tokens.append(Token(TokenKind.EOF(), "", Position(self.line, self.column)))

        return tokens^
