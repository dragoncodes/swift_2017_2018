//
// Created by dragoncodes on 25.04.18.

import Foundation

class Linker {

    private var input: [FancyLanguageNode]

    private var rules: [String: RuleNode]

    var linkedNodes: [FancyLanguageNode]

    init(input: [FancyLanguageNode], rules: [String: RuleNode]) {

        self.input = input

        self.rules = rules

        linkedNodes = [FancyLanguageNode]()
    }

    func link() -> [FancyLanguageNode] {

        linkedNodes = [FancyLanguageNode]()

        input.forEach { node in
            parseLanguageNode(node: node, parentNode: nil, parsedRules: rules)

            linkedNodes.append(node)
        }

        return linkedNodes.reversed()
    }

    private func parseLanguageNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?, parsedRules: [String: RuleNode]) {

        var resolvedValue = resolveLanguageNode(node: node, parentNode: parentNode, parsedRules: parsedRules)

        node.attributes.forEach { property in

            if property.value is String {
                resolvedValue = resolvedValue.replacingOccurrences(of: property.name, with: property.value as! String)
            }
        }

        node.children.forEach { childNode in
            parseLanguageNode(node: childNode, parentNode: node, parsedRules: parsedRules)
        }

        node.value = resolvedValue
    }

    private func resolveLanguageNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?, parsedRules: [String: RuleNode]) -> String {

        if let ruleNode = parsedRules[node.name] {
            return ruleNode.value
        }

        if parentNode != nil,
           let parentRules = parsedRules[parentNode!.name] {

            let childRules = parentRules.childRules

            for childRule in childRules {
                guard childRule.isNodeEligible(node: node) else {
                    continue
                }

                let tokens = Lexer(input: childRule.rawRule).lex()

                for token in tokens {
                    print(token)
                }

//                let boolExpression = parseText(text: childRule.rawRule)
//
//                if boolExpression.left != nil {
//
//                    for attribute in node.attributes {
//                        if let boolLeft = boolExpression.left,
//                           boolLeft.value.contains(attribute.name) {
//
//                            boolLeft.value = boolLeft.value.replacingOccurrences(of: attribute.name, with: attribute.value as! String)
//
//                            if boolLeft.value.contains("=") {
//                                let left = boolLeft.value.split(separator: "=")[0].trimmingCharacters(in: .whitespacesAndNewlines)
//                                let right = boolLeft.value.split(separator: "=")[1].trimmingCharacters(in: .whitespacesAndNewlines)
//
//                                if left == right {
//                                    return childRule.value
//                                }
//                            }
//                        }
//                    }
//                }
            }

//            parseText(text: parentRules.childRules[0].rawRule)
        }


//        guard let resolvedName = ruleNode.value else {
//            return node.name
//        }

        return node.name
    }
}