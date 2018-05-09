//
// Created by dragoncodes on 6.05.18.

import Foundation

enum BooleanOperand: String {
    case And = "&"
}

let operandsDict = [
    "&": BooleanOperand.And
]


func parseText(text: String) -> BoolExpLeaf {
    let preparedText = text.prepareForParsing()

//    let nodes = []


    var term: String = ""

    var nodes = [BoolExpLeaf]()

    var currentLeaf = BoolExpLeaf(value: "")

    preparedText.forEach { character in
        if character.isOperand() {

            guard let operand = operandsDict[String(character)] else {
                return
            }

            currentLeaf.operand = operand

            if currentLeaf.left == nil {
                currentLeaf.left = BoolExpLeaf(value: term)
            } else {
                currentLeaf.right = BoolExpLeaf(value: term)
            }

//            nodes.append(boolLeaf)

            term = ""

        } else {

            if character == "(" || character == ")" {
                return
            }

            term += [character]
        }
    }

    if !term.isEmpty {
        currentLeaf.right = BoolExpLeaf(value: term)
    }

    return currentLeaf
}

extension String {
    func prepareForParsing() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Character {
    func isOperand() -> Bool {
        return operandsDict[String(self)] != nil
    }
}

class BoolExpLeaf {
    var operand: BooleanOperand?

    var left: BoolExpLeaf?

    var right: BoolExpLeaf?

    var value: String

    init(value: String) {
        self.value = value

        operand = nil
        left = nil
        right = nil
    }

    init(operand: BooleanOperand) {

        self.operand = operand

        value = ""
        left = nil
        right = nil
    }

    func evaluate(with node: FancyLanguageNode) -> Bool {

        var leftResult = true
        var rightResult = false

        return false
    }
}