//
//  Compiler.swift
//  FancyCompiler
//
//  Created by dragoncodes on 24.03.18.
//  Copyright © 2018 dragoncodes. All rights reserved.
//

import Foundation

class Compiler {

    private let inputFile: String

    init(inputFile: String) {
        self.inputFile = inputFile
    }

    func compile() -> Either<CompilerError, [FancyLanguageNode]> {
        return self.parseInputFiles()
    }

    private func parseInputFiles() -> Either<CompilerError, [FancyLanguageNode]> {


        var result = [FancyLanguageNode]()

        let readFileData = readFile(inputFile)

        print("Input")
        if let error = readFileData.left {
            print("error", error)
        } else if let fileContents = readFileData.right,
                  let jsonDict = parseJson(from: fileContents).right {

            let parsedResult = jsonDict.forEach { key, value in

                print("Compilation \(key) \(value)")

                let node = toNode(from: (key: key, value: value))

                result.append(node)
            }

//                result.append(parsedResult)
        }

        return Either.fromRight(result)
    }

    private func toNode(from jsonObj: JsonNode) -> FancyLanguageNode {

        // TODO swiftify this

        var result = FancyLanguageNode(name: jsonObj.key)

        if jsonObj.value is [String: Any] {

            let childObjects = jsonObj.value as! [String: Any]

            childObjects.reversed().forEach { childObj in

                let childNode = toNode(from: childObj)

                if childNode.name.starts(with: "@") {
                    result.addAttribute(name: childNode.name, value: childNode.value)
                } else {
                    result.addChild(child: childNode)
                }
            }
        } else if jsonObj.value is Array<[String: Any]>,
                  let children = jsonObj.value as? Array<[String: Any]> {

            for childObj in children {
                let child = toNode(from: (key: "", value: childObj))

                result.addChild(child: child)
            }

        } else if jsonObj.value is String {

            do {
                let stringValue = jsonObj.value as! String

//                if jsonObj.key.starts(with: "@") {
//                    result.addAttribute(name: jsonObj.key, value: stringValue);
//                } else {
                result.value = stringValue
//                }
            }
        }

        return result
    }

    private func parseJson(from: String) -> Either<CompilerError, [String: Any]> {

        guard let json = from.data(using: .utf8) else {
            return Either.fromLeft(CompilerError.fileParsingError(message: "Cannot parse file \(from)"))
        }

        do {
            return Either.fromRight(try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any])
        } catch {
            return Either.fromLeft(CompilerError.fileParsingError(message: error.localizedDescription))
        }
    }

    enum CompilerError: Error {
        case invalidInputPath
        case fileParsingError(message: String)
    }

    typealias JsonNode = (key: String, value: Any)
}
