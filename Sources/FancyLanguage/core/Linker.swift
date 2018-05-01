//
// Created by dragoncodes on 25.04.18.

import Foundation

class Linker {

    private var input: [FancyLanguageNode]

    private var rules: [RuleNode]

    var linkedNodes: [FancyLanguageNode]

    init(input: [FancyLanguageNode], rules: [RuleNode]) {

        self.input = input

        self.rules = rules

        linkedNodes = [FancyLanguageNode]()
    }

    func link() -> [FancyLanguageNode] {

        linkedNodes = [FancyLanguageNode]()

        var parsedRules: [String: String] = [:]

        rules.forEach { node in
            parsedRules[node.name] = node.value
        }

        input.forEach { node in
            parseLanguageNode(node: node, parsedRules: parsedRules)

            linkedNodes.append(node)
        }

        return linkedNodes.reversed()
    }

    private func parseLanguageNode(node: FancyLanguageNode, parsedRules: [String: String]) {

        var resolvedValue = resolveLanguageNode(node: node, parsedRules: parsedRules)

        node.attributes.forEach { property in

            if property.value is String {
                resolvedValue = resolvedValue.replacingOccurrences(of: property.name, with: property.value as! String)
            }
        }

        node.children.forEach { childNode in
            parseLanguageNode(node: childNode, parsedRules: parsedRules)
        }

        node.value = resolvedValue
    }

    private func resolveLanguageNode(node: FancyLanguageNode, parsedRules: [String: String]) -> String {
        guard let resolvedName = parsedRules[node.name] else {
            return node.name
        }

        return resolvedName
    }
}