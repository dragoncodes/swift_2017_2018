//
// Created by dragoncodes on 16.05.18.

import Foundation

struct JsonTraversalNode {

    var name: String

    var dict: [String: Any]?

    var array: [Any]?

    var value: Any?

    init(name: String) {

        self.name = name

        self.dict = nil
        self.array = nil
        self.value = nil
    }
}

class JsonRunner: Runner {
    func traverseNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> Any? {
        guard let nodeValue = node.value else {
            return nil
        }

        var traversalResult = JsonTraversalNode(name: nodeValue)

        if node.hasChildren {

            var childrenArray = [Any]()

            for child in node.children {

                guard let childDictionaryElement: Any = traverseNode(node: child, parentNode: node) else {
                    continue
                }

                childrenArray.append(childDictionaryElement)
            }

            traversalResult.array = childrenArray
        } else {
            traversalResult.value = nodeValue
        }

        var output: Any? = nil

        if let traversalValue = traversalResult.value {
            output = traversalValue
        } else if let traversalDict = traversalResult.dict {

            var tempOutput = [String: Any]()
            tempOutput[traversalResult.name] = traversalResult.dict

            output = tempOutput

        } else if let traversalArray = traversalResult.array {

            var tempOutput = [String: Any]()
            tempOutput[traversalResult.name] = traversalResult.array

            output = tempOutput
        }

        return output
    }

    func formOutput(input: [FancyLanguageNode], rules: [String: RuleNode], outputFile: String) throws -> String {

        guard let firstNode = input.first else {
            throw RunnerErrors.validationError(message: "Multiple root nodes defined")
        }

        guard let root = traverseNode(node: firstNode, parentNode: nil) else {
            throw RunnerErrors.validationError(message: "Root node failed to be generated")
        }

        guard JSONSerialization.isValidJSONObject(root) else {
            throw RunnerErrors.validationError(message: "Not a valid output \(root)")
        }

        let jsonData = try JSONSerialization.data(withJSONObject: root, options: JSONSerialization.WritingOptions()) as NSData

        guard let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) else {
            throw RunnerErrors.validationError(message: "Could not create a json string")
        }

        return jsonString as String
    }
}