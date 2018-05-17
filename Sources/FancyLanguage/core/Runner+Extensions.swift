//
// Created by dragoncodes on 12.05.18.

import Foundation

protocol Runner {

    func run(input: [FancyLanguageNode], rules: [String: RuleNode], inputFile: String) -> Maybe<String>
}

class BaseRunner: Runner {
    func run(input: [FancyLanguageNode], rules: [String: RuleNode], inputFile: String) -> Maybe<String> {
        return Maybe<String>.create { observer in

            return Disposables.create()
        }
    }
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

    case validationError(message: String)
}
