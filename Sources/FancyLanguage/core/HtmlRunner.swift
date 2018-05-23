//
// Created by dragoncodes on 30.04.18.

import Foundation


class HtmlRunner: Runner {

    func run(input: [FancyLanguageNode], rules: [String: RuleNode], outputFile: String) -> Maybe<String> {
        return Maybe<String>.create { observer in

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

            self.saveFile(
                    withName: outputFile,
                    withContent: output,
                    encoding: String.Encoding.utf8
            ).subscribe(onCompleted: {
                observer(.completed)
            }, onError: { _ in
                observer(.error(RunnerErrors.fileSavingError))
            })

            return Disposables.create()
        }
    }

}