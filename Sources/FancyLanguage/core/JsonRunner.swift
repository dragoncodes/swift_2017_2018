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
    func run(input: [FancyLanguageNode], rules: [String: RuleNode], outputFile: String) -> Maybe<String> {
        return Maybe<String>.create { observer in

            func traverseNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> Any? {

                guard let nodeValue = node.value else {
                    return nil
                }

                var traversalResult = JsonTraversalNode(name: nodeValue)

                if node.hasChildren {

                    var childrenArray = [Any]()

                    for child in node.children {

                        guard let childDictionaryElement = traverseNode(node: child, parentNode: node) else {
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

            guard let firstNode = input.first,
                  let firstNodeValue = firstNode.value else {
                observer(.error(RunnerErrors.validationError(message: "Multiple root nodes defined")))

                return Disposables.create()
            }

            var root = traverseNode(node: firstNode, parentNode: nil)

            //Compiler.JsonNode(firstNodeValue, firstNodeValue)

            func onCompleted() {
                observer(.completed)
            }

            do {

                guard JSONSerialization.isValidJSONObject(root) else {
                    print(root)

                    return Disposables.create()
                }

                let jsonData = try JSONSerialization.data(withJSONObject: root, options: JSONSerialization.WritingOptions()) as NSData
                let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String

                self.saveFile(withName: outputFile, withContent: jsonString, encoding: String.Encoding.utf8)
                        .subscribe(onCompleted: onCompleted, onError: { _ in
                            observer(.error(RunnerErrors.fileSavingError))
                        })
            } catch _ {

            }

            return Disposables.create()
        }
    }

}