//
// Created by dragoncodes on 15.05.18.

import Foundation

class XmlRunner: Runner {
    func traverseNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> Any? {
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

            guard let childXmlElement = self.traverseNode(node: child, parentNode: node) as? XMLElement else {
                continue
            }

            output!.addChild(childXmlElement)
        }

        return output
    }

    func formOutput(input: [FancyLanguageNode], rules: [String: RuleNode], outputFile: String) throws -> String {

        if input.count > 1 {

            throw  RunnerErrors.validationError(message: "XmlRunner supports only one root node")
        }

        guard let firstNode = input.first,
              let rootNodeName = firstNode.value else {

            throw RunnerErrors.validationError(message: "No root node defined")
        }

        let root = XMLElement(name: rootNodeName)
//        let xml = XMLDocument(rootElement: root)

        for child in firstNode.children {
            guard let childXmlElement = self.traverseNode(node: child, parentNode: firstNode) as? XMLElement else {
                continue
            }

            root.addChild(childXmlElement)
        }

        return root.xmlString
    }

//    func run(input: [FancyLanguageNode], rules: [String: RuleNode], outputFile: String) -> Maybe<String> {
//        return Maybe<String>.create { observer in
//
//            func traverseNode(node: FancyLanguageNode, parentNode: FancyLanguageNode?) -> XMLElement? {
//
//                guard var nodeValue = node.value else {
//                    return nil
//                }
//
//                var output: XMLElement? = nil
//
//                if nodeValue.contains("<") {
//                    do {
//                        output = try XMLElement(xmlString: nodeValue)
//                    } catch {
//
//                        output = XMLElement(name: nodeValue)
//                    }
//                } else {
//                    output = XMLElement(name: nodeValue)
//                }
//
//                if output == nil {
//                    return nil
//                }
//
//                for child in node.children {
//
//                    guard let childXmlElement = traverseNode(node: child, parentNode: node) else {
//                        continue
//                    }
//
//                    output!.addChild(childXmlElement)
//                }
//
//                return output
//            }
//
//            if input.count > 1 {
//
//                observer(.error(RunnerErrors.validationError(message: "XmlRunner supports only one root node")))
//
//                return Disposables.create()
//            }
//
//            guard let firstNode = input.first,
//                  let rootNodeName = firstNode.value else {
//
//                return Disposables.create()
//            }
//
//            let root = XMLElement(name: rootNodeName)
//            let xml = XMLDocument(rootElement: root)
//
//            for child in firstNode.children {
//                guard let childXmlElement = traverseNode(node: child, parentNode: firstNode) else {
//                    continue
//                }
//
//                root.addChild(childXmlElement)
//            }
//
//            self.saveFile(withName: outputFile, withContent: xml.xmlString, encoding: String.Encoding.utf8)
//                    .subscribe(onCompleted: {
//                        observer(.completed)
//                    }, onError: { _ in
//                        observer(.error(RunnerErrors.fileSavingError))
//                    })
//
//            return Disposables.create()
//        }
//    }
}