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

                        if ruleNode.name.contains(".") {
                            if let indexOfDot = ruleNode.name.index(of: ".") {

                                let childrenRule = String(ruleNode.name.substring(from: indexOfDot).dropFirst())
                                let mainRuleName = ruleNode.name.substring(to: indexOfDot)

                                if !childrenRule.isSupportedFileExtension() {

                                    guard let mainRuleNode = parsedRuleNodes[mainRuleName] else {
                                        continue
                                    }

                                    for supportedChildSelector in supportedChildrenSelectors {
                                        if childrenRule.contains(supportedChildSelector) {
                                            let childRule = ChildRule(selector: supportedChildSelector,
                                                    rawRule: childrenRule.substringFrom(phrase: supportedChildSelector),
                                                    value: ruleNode.value)

                                            mainRuleNode.childRules.append(childRule)
                                        }
                                    }
                                } else {
                                    parsedRuleNodes[ruleNode.name] = ruleNode
                                }

                                print(childrenRule)
                            } else {
                                parsedRuleNodes[ruleNode.name] = ruleNode
                            }
                        } else {
                            parsedRuleNodes[ruleNode.name] = ruleNode
                        }

                        print("\(ruleNode.name) \(ruleNode.value)")

                    }

                    rules = parsedRuleNodes
                }

        return result
    }
}

let supportedChildrenSelectors = ["*"]

let supportedFileExtensions = ["json", "xml", "html"]

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

    func isSupportedFileExtension() -> Bool {
        return supportedFileExtensions.contains(self)
    }
}