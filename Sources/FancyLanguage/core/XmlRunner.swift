//
// Created by dragoncodes on 15.05.18.

import Foundation

class XmlRunner: BaseRunner {

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

            func traverseNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> XMLElement? {

                guard var nodeValue = node.value else {
                    return nil
                }

                var output: XMLElement? = nil

                if nodeValue.contains("<") {
                    do {
                        output = try XMLElement(xmlString: nodeValue)
                    } catch {

                        output = XMLElement(name: nodeValue)
                    }
                } else {
                    output = XMLElement(name: nodeValue)
                }

                if output == nil {
                    return nil
                }

                for child in node.children {

                    guard let childXmlElement = traverseNode(node: child, parentNode: node) else {
                        continue
                    }

                    output!.addChild(childXmlElement)
                }

                return output
            }

            if input.count > 1 {

                observer(.error(RunnerErrors.validationError(message: "XmlRunner supports only one root one")))

                return Disposables.create()
            }

            guard let firstNode = input.first,
                  let rootNodeName = firstNode.value else {

                return Disposables.create()
            }

            let root = XMLElement(name: rootNodeName)
            let xml = XMLDocument(rootElement: root)

            for child in firstNode.children {
                guard let childXmlElement = traverseNode(node: child, parentNode: firstNode) else {
                    continue
                }

                root.addChild(childXmlElement)
            }

            var saveFileOperations = [Observable<Never>]()
            for outputPath in outputPaths {
                saveFileOperations.append(
                        self.saveFile(withName: outputPath, withContent: xml.xmlString, encoding: String.Encoding.utf8).asObservable()
                )
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