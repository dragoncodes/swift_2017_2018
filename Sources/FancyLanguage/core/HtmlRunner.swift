//
// Created by dragoncodes on 30.04.18.

import Foundation


class HtmlRunner: BaseRunner {
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

            func traverseNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> String {
                var output = ""

                guard let nodeValue = node.value else {
                    return ""
                }

                let hasChildren = !node.children.isEmpty

                if hasChildren {
                    output += "<\(nodeValue)>"
                } else {

                    // TODO what is happening here

                    if !nodeValue.isEmpty {
                        output += nodeValue
                    } else {

                    }
                }

                for child in node.children {
                    output += traverseNode(node: child, parentNode: node)
                }

                if hasChildren {
                    output += "</\(nodeValue)>"
                }

                return output
            }

            var output = ""
            for node in input {
                output += traverseNode(node: node, parentNode: nil)
            }

            var saveFileOperations = [Observable<Never>]()
            for outputPath in outputPaths {
                saveFileOperations.append(
                        self.saveFile(withName: outputPath, withContent: output, encoding: String.Encoding.utf8).asObservable()
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