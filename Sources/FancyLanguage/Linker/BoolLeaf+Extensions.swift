//
// Created by dragoncodes on 10.05.18.

import Foundation

protocol BoolLeaf {
    func evaluate() -> Bool
}

class ValueBoolLeaf: BoolLeaf {
    var left: String?
    var right: String?
    var operand: BoolOperator?

    func evaluate() -> Bool {
        guard let leftLeaf = left else {
            return false
        }

        guard let rightLeaf = right else {
            return false
        }

        guard let boolOperand = self.operand else {
            return false
        }

        switch boolOperand {
        case .equals:
            return leftLeaf == rightLeaf
        case .contains:
            return leftLeaf.contains(rightLeaf)

        default:
            return false
        }
    }
}