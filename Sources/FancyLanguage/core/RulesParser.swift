//
// Created by dragoncodes on 25.04.18.

import Foundation

class RuleParser {

    private let rulesFilePath: String

    var rules: [String: RuleNode]

    init(rulesFilePath: String) {
        self.rulesFilePath = rulesFilePath;

        rules = [String: RuleNode]()
    }

    func parseRules() -> Bool {

        var result = true

        readFile(rulesFilePath)

                .foldLeft { _ in
                    result = false
                }

                .foldRight { fileContents -> () in

                    var parsedRuleNodes = [String: RuleNode]()

                    let fileLines = fileContents.split(separator: "\n")

                    for fileLine in fileLines {

                        if fileLine.contains("#") {
                            continue
                        }

                        let ruleComponents = fileLine.components(separatedBy: "=>")

                        let ruleNode = RuleNode(name: ruleComponents[0], value: ruleComponents[1])

                        // if the name contains a dot it's either a child rule or an output rule
                        if ruleNode.name.contains("."),
                           let indexOfDot = ruleNode.name.indexOfDot() {

                            let childrenRule = String(ruleNode.name.substring(from: indexOfDot).dropFirst())
                            let mainRuleName = ruleNode.name.substring(to: indexOfDot)

                            guard !childrenRule.isSupportedFileExtension() else {

                                // If the rule is for input/output pair it is expected to have multiple outputs for a single input
                                parsedRuleNodes.addNode(node: ruleNode, forKey: ruleNode.name)

                                continue
                            }

                            guard let mainRuleNode = parsedRuleNodes[mainRuleName] else {
                                continue
                            }

                            for supportedChildSelector in supportedChildrenSelectors {
                                let rawChildSelectorValue = supportedChildSelector.rawValue
                                
                                if childrenRule.contains(rawChildSelectorValue) {

                                    let childRule = ChildRule(selector: rawChildSelectorValue,
                                            rawRule: childrenRule.substringFrom(phrase: rawChildSelectorValue),
                                            value: ruleNode.value)

                                    mainRuleNode.childRules.append(childRule)
                                }
                            }
                        } else {
                            parsedRuleNodes[ruleNode.name] = ruleNode
                        }
                    }

                    rules = parsedRuleNodes
                }

        return result
    }
}

let supportedChildrenSelectors = [ChildSelector.all, ChildSelector.firstChild]

enum ChildSelector: String {
    case all = "*", firstChild = ">"
}

let supportedFileExtensions = [FileExtension.json, FileExtension.xml, FileExtension.html]

enum FileExtension: String {
    case json = "json", xml = "xml", html = "html"
}

extension Dictionary where Key == String, Value == RuleNode {

    mutating func addNode(node: RuleNode, forKey key: String) {

        guard let oldValue: RuleNode = self[key] else {
            self[key] = node

            return
        }

        oldValue.values.append(oldValue.value)
        oldValue.values.append(node.value)
    }
}

extension String {

    func substringFrom(phrase: String) -> String {

        guard let firstCharacter = phrase.first else {
            return ""
        }

        guard let indexOfString = index(of: firstCharacter) else {
            return ""
        }

        return String(self[indexOfString...].dropFirst())
    }

    func indexOfDot() -> String.Index? {
        return self.index(of: ".")
    }

    func isSupportedFileExtension() -> Bool {
        guard let enumValue = FileExtension(rawValue: self) else {
            return false
        }

        return supportedFileExtensions.contains(enumValue)
    }
}