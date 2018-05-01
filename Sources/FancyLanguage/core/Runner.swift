//
// Created by dragoncodes on 30.04.18.

import Foundation

protocol Runner {
    func run(input: [FancyLanguageNode], rules: [RuleNode], inputFile: String) -> Maybe<String>
}

extension Runner {
    func saveFile(withName fileName: String, withContent content: String, encoding: String.Encoding) -> Completable {
        return Completable.create { observer in

            var success = true

            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

                let fileURL = dir.appendingPathComponent(fileName)

                do {
                    try content.write(to: fileURL, atomically: false, encoding: encoding)

                } catch {
                    success = false
                }
            } else {
                success = false
            }

            guard success else {
                observer(.error(RunnerErrors.fileSavingError))

                return Disposables.create()
            }

            observer(.completed)

            return Disposables.create()
        }
    }
}


enum RunnerErrors: Error {
    case fileSavingError

    case noOutputsDefined
}

class HtmlRunner: Runner {
    func run(input: [FancyLanguageNode], rules: [RuleNode], inputFile: String) -> Maybe<String> {
        return Maybe<String>.create { observer in

            var parsedRules = rules.toDict()

            var outputPaths = [String]()

            let separatedPath = inputFile.components(separatedBy: "/")

            guard let fileName = separatedPath.last else {
                observer(.error(RunnerErrors.noOutputsDefined))

                return Disposables.create()
            }

            if let potentialOutput = parsedRules[fileName] {
                outputPaths.append(potentialOutput)
            }

            if outputPaths.count == 0 {
                observer(.error(RunnerErrors.noOutputsDefined))

                return Disposables.create()
            }

            func traverseNode(node: FancyLanguageNode) -> String {
                var output = ""

                guard let nodeValue = node.value else {
                    return ""
                }

                let hasChildren = !node.children.isEmpty

                if hasChildren {
                    output += "<\(nodeValue)>"
                } else {
                    output += nodeValue
                }

                for child in node.children {
                    output += traverseNode(node: child)
                }

                if hasChildren {
                    output += "</\(nodeValue)>"
                }

                return output
            }

            var output = ""
            for node in input {
                output += traverseNode(node: node)
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


//                    .subscribe(onNext: {}, onError: {
//                observer(.error(RunnerErrors.fileSavingError))
//            }, onCompleted: {
//                observer(.completed)
//            }, onDisposed: {})

            return Disposables.create()
        }
    }

}

//class Runner {
//
//    static func run(input: [FancyLanguageNode], rules: [RuleNode], inputFile: String) -> Maybe<[String]> {
//
//        return Maybe<[String]>.create { observer in
//            var parsedRules: [String: String] = [:]
//
//            rules.forEach { node in
//                parsedRules[node.name] = node.value
//            }
//
//            var outputPaths = [String: String]()
//
//            let separatedPath = inputFile.components(separatedBy: "/")
//
//            guard let fileName = separatedPath.last else {
//                observer(.error(RunnerErrors.noOutputsDefined))
//
//                return Disposables.create {
//                }
//            }
//
//            if parsedRules[fileName] != nil {
//                outputPaths[fileName] = parsedRules[fileName]
//            }
//
//            if outputPaths.keys.count == 0 {
//                observer(.error(RunnerErrors.noOutputsDefined))
//
//                return Disposables.create {
//                }
//            }
//
//            print(parsedRules[fileName])
//
//            return Disposables.create {
//            }
//        }
//    }
//
//
//    enum RunnerErrors: Error {
//        case noOutputsDefined
//    }
//}
