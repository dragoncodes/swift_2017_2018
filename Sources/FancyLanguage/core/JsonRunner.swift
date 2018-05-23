//
// Created by dragoncodes on 16.05.18.

import Foundation

class JsonRunner: Runner {
    func run(input: [FancyLanguageNode], rules: [String: RuleNode], outputFile: String) -> Maybe<String> {
        return Maybe<String>.create { observer in

            func traverseNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> [String: Any]? {

                guard let nodeValue = node.value else {
                    return nil
                }

                var output = [String: Any]()

                if node.hasChildren {

                    var childrenArray = [[String: Any]]()

                    for child in node.children {

                        guard let childDictionaryElement = traverseNode(node: child, parentNode: node) else {
                            continue
                        }

                        childrenArray.append(childDictionaryElement)
                    }

                    output[nodeValue] = childrenArray
                } else {
                    output[""] = nodeValue
                }

                return output
            }

            guard let firstNode = input.first,
                  let firstNodeValue = firstNode.value else {
                observer(.error(RunnerErrors.validationError(message: "Multiple root nodes defined")))

                return Disposables.create()
            }

            var root = [String: Any]()
            //Compiler.JsonNode(firstNodeValue, firstNodeValue)

            root[firstNodeValue] = traverseNode(node: firstNode, parentNode: nil)

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