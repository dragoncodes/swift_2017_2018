//
// Created by dragoncodes on 8.05.18.

import Foundation

enum Token {
    case openBrace, closeBrace
    case identifier(String)
    case boolOperator(BoolOperator)
}

enum BoolOperator: String {
    case and = "&"
    case or = "|"
    case not = "!"
    case equals = "="
    case contains = "?="
}

extension Character {
    var value: Int32 {
        return Int32(String(self).unicodeScalars.first!.value)
    }
    var isSpace: Bool {
        return isspace(value) != 0
    }
    var isAlphanumeric: Bool {
        return isalnum(value) != 0 || self == "@"
    }
}

class Lexer {
    let input: String
    var index: String.Index

    init(input: String) {
        self.input = input
        self.index = input.startIndex
    }

    var currentChar: Character? {
        return index < input.endIndex ? input[index] : nil
    }

    func advanceIndex() {
        input.characters.formIndex(after: &index)
    }

    func readIdentifierOrNumber() -> String {
        var str = ""
        while let char = currentChar, char.isAlphanumeric || char == "." {
            str.characters.append(char)
            advanceIndex()
        }
        return str
    }

    func readBooleanOperator() -> String {
        var str = ""
        while let char = currentChar, char == "?" || char == "=" {
            str.characters.append(char)
            advanceIndex()
        }

        return str
    }

    func advanceToNextToken() -> Token? {
        // Skip all spaces until a non-space token
        while let char = currentChar, char.isSpace {
            advanceIndex()
        }
        // If we hit the end of the input, then we're done
        guard let char = currentChar else {
            return nil
        }


        let singleTokMapping: [Character: Token] = [
            "(": .openBrace, ")": .closeBrace,
            "!": .boolOperator(.not),
            "&": .boolOperator(.and),
            "|": .boolOperator(.or),
            "=": .boolOperator(.equals)
        ]

        if let tok = singleTokMapping[char] {
            advanceIndex()
            return tok
        }

        if char.isAlphanumeric || char == "?" || char == "." {
            var str = readIdentifierOrNumber()

            if str.isEmpty {
                str = readBooleanOperator()
            }

            switch str {
            case "?=": return .boolOperator(.contains)
            default: return .identifier(str)
            }
        }

        return nil
    }

    func lex() -> [Token] {
        var toks = [Token]()
        while let tok = advanceToNextToken() {
            toks.append(tok)
        }
        return toks
    }
}