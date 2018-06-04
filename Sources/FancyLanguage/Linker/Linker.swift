//
// Created by dragoncodes on 25.04.18.

import Foundation

class Linker {

    private var input: [FancyLanguageNode]

    private var rules: [String: Any]

    var linkedNodes: [FancyLanguageNode]

    init(input: [FancyLanguageNode], rules: [String: Any]) {

        self.input = input

        self.rules = rules

        linkedNodes = [FancyLanguageNode]()
    }

    func link() -> [FancyLanguageNode] {

        linkedNodes = [FancyLanguageNode]()

        input.forEach { node in
            parseLanguageNode(node: node, parentNode: nil)

            linkedNodes.append(node)
        }

        return linkedNodes.reversed()
    }

    private func parseLanguageNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) {

        var resolvedValue = resolveLanguageNode(node: node, parentNode: parentNode)

        node.attributes.forEach { property in

            if property.value is String {
                resolvedValue = resolvedValue.replacingOccurrences(of: property.name, with: property.value as! String)
            }
        }

        node.children.forEach { childNode in
            parseLanguageNode(node: childNode, parentNode: node)
        }

        node.value = resolvedValue
    }

    private func resolveLanguageNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> String {

        if let ruleNode = rules[node.name], ruleNode is RuleNode {
            return (ruleNode as! RuleNode).value
        }

        if parentNode != nil,
           let parentRules = rules[parentNode!.name], parentRules is RuleNode {

            let childRules = (parentRules as! RuleNode).childRules

            for childRule in childRules {
                guard childRule.isNodeEligible(node: node) else {
                    continue
                }

                let attributes = node.attributes.toDictionary()

                let tokens = Lexer(input: childRule.rawRule).lex()

                var result = true

                var currentBoolLeaf = ValueBoolLeaf()

                var pendingOperand: BoolOperator? = nil

                for token in tokens {
                    switch token {

                    case .identifier(var identifier):

                        if let attribForIdentifier = attributes[identifier] {
                            identifier = attribForIdentifier.value as! String
                        }

                        if currentBoolLeaf.left == nil {
                            currentBoolLeaf.left = identifier
                        } else {
                            currentBoolLeaf.right = identifier

                            let evaluatedLeaf = currentBoolLeaf.evaluate()

                            if pendingOperand == nil {
                                result = result && evaluatedLeaf
                            } else {
                                switch pendingOperand! {
                                case .and:
                                    result = result && evaluatedLeaf
                                case .or:
                                    result = result || evaluatedLeaf
                                default:
                                    break
                                }

                                pendingOperand = nil
                            }

                            currentBoolLeaf = ValueBoolLeaf()
                        }

                    case .boolOperator(let operand):

                        if currentBoolLeaf.operand == nil && currentBoolLeaf.left != nil {
                            currentBoolLeaf.operand = operand
                        } else {
                            pendingOperand = operand
                        }

                    default:
                        break
                    }
                }

                if result {
                    return childRule.value
                }
            }
        }

        return node.name
    }
}