//
// Created by dragoncodes on 8.05.18.

/*

Heavily influenced and almost 1:1 copied from:

https://harlanhaskins.com/2017/01/08/building-a-compiler-with-swift-in-llvm-part-1-introduction-and-the-lexer.html

*/

import Foundation

enum Token {
    case openBrace, closeBrace
    case identifier(String)
    case boolOperator(BoolOperator)
}

enum BoolOperator: String {
    case and = "&&"
    case or = "||"
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

    var isPotentialBool: Bool {
        return self == "&" || self == "|" || self == "?" || self == "="
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
        input.formIndex(after: &index)
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
        while let char = currentChar, char.isPotentialBool {
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
            "=": .boolOperator(.equals)
        ]

        if let tok = singleTokMapping[char] {
            advanceIndex()
            return tok
        }

        if char.isAlphanumeric || char.isPotentialBool || char == "?" || char == "." {
            var str = readIdentifierOrNumber()

            if str.isEmpty {
                str = readBooleanOperator()
            }

            switch str {
            case "?=": return .boolOperator(.contains)
            case "||": return .boolOperator(.or)
            case "&&": return .boolOperator(.and)
            default: return .identifier(str)
            }
        }

        return nil
    }

    func lex() -> [Token] {
        var tokes = [Token]()
        while let tok = advanceToNextToken() {
            tokes.append(tok)
        }
        return tokes
    }
}