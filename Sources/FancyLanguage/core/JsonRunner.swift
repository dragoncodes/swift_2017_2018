//
// Created by dragoncodes on 16.05.18.

import Foundation

class JsonRunner: BaseRunner {
    override func run(input: [FancyLanguageNode], rules: [String: RuleNode], inputFile: String) -> Maybe<String> {
        return Maybe<String>.create { observer in
            var outputPaths = [String]()

            let separatedPath = inputFile.components(separatedBy: "/")

            guard let fileName = separatedPath.last else {
                observer(.error(RunnerErrors.noOutputsDefined))

                return Disposables.create()
            }

            if let potentialOutput = rules[fileName] {
                outputPaths.append(potentialOutput.value)
            }

            if outputPaths.count == 0 {
                observer(.error(RunnerErrors.noOutputsDefined))

                return Disposables.create()
            }

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

            var saveFileOperations = [Observable<Never>]()
            for outputPath in outputPaths {

                do {

                    guard JSONSerialization.isValidJSONObject(root) else {
                        print(root)

                        return Disposables.create()
                    }

                    let jsonData = try JSONSerialization.data(withJSONObject: root, options: JSONSerialization.WritingOptions()) as NSData
                    let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String

                    saveFileOperations.append(
                            self.saveFile(withName: outputPath, withContent: jsonString, encoding: String.Encoding.utf8).asObservable()
                    )
                } catch _ {

                }
            }

            func onError() {
                observer(.error(RunnerErrors.fileSavingError))
            }

            func onCompleted() {
                observer(.completed)
            }

            Observable.zip(saveFileOperations).subscribe(onNext: nil, onError: nil, onCompleted: onCompleted, onDisposed: nil)

            return Disposables.create()
        }
    }

}