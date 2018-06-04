//
// Created by dragoncodes on 30.04.18.

import Foundation

class HtmlRunner: Runner {

    func formOutput(input: [FancyLanguageNode], rules: [String: RuleNode], outputFile: String) throws -> String {
        var output = ""
        for node in input {

            guard let traversalOutput = self.traverseNode(node: node, parentNode: nil) as? String else {
                continue
            }

            output += traversalOutput
        }

        return output
    }

    func traverseNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> Any? {
        var output = ""

        guard let nodeValue = node.value else {
            return output
        }

        let hasChildren = !node.children.isEmpty

        if hasChildren {
            output += "<\(nodeValue)>"
        } else {

            if !nodeValue.isEmpty {
                output += nodeValue
            }
        }

        for child in node.children {
            output += self.traverseNode(node: child, parentNode: node) as! String
        }

        if hasChildren {
            output += "</\(nodeValue)>"
        }

        return output
    }
}