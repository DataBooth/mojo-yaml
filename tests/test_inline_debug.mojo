from testing import TestSuite
from yaml.lexer import Lexer, TokenKind

fn test_inline_list_mapping_debug() raises:
    print("Debugging inline list-mapping pattern")
    print("="*60)

    var yaml = """- name: Alice
  age: 30
- name: Bob
  age: 25"""
    print("Input:", yaml)
    print()

    var lexer = Lexer(yaml)
    var tokens = lexer.tokenize()

    print("Token stream:")
    for i in range(len(tokens)):
        var tok = tokens[i].copy()
        var _ = String("")

        if tok.kind == TokenKind.DASH():
            kind_str = "DASH"
        elif tok.kind == TokenKind.STRING():
            kind_str = "STRING"
        elif tok.kind == TokenKind.COLON():
            kind_str = "COLON"
        elif tok.kind == TokenKind.NEWLINE():
            kind_str = "NEWLINE"
        elif tok.kind == TokenKind.INDENT():
            kind_str = "INDENT"
        elif tok.kind == TokenKind.DEDENT():
            kind_str = "DEDENT"
        elif tok.kind == TokenKind.INTEGER():
            kind_str = "INTEGER"
        elif tok.kind == TokenKind.EOF():
            kind_str = "EOF"
        else:
            kind_str = "OTHER"

        print(i, ":", kind_str, "  value:", repr(tok.value), "  pos:", tok.pos.line, ":", tok.pos.column)


fn main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
