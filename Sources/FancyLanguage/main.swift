//
// Created by dragoncodes on 6.04.18.

func run() {

    let inputFiles = ["testData/in.json"]
    let ruleParser = RuleParser(rulesFilePath: "testData/rules.txt")

    guard ruleParser.parseRules() else {
        return print("Error parsing rules")
    }

    func runFor(outputFile: String, linkedResult: [FancyLanguageNode]) {
        guard let outputFileExtension = FileExtension(rawValue: outputFile.substringFrom(phrase: ".")) else {
            return
        }

        var runner: Runner? = nil

        switch outputFileExtension {
        case FileExtension.html:
            runner = HtmlRunner()
        case FileExtension.xml:
            runner = XmlRunner()
        case FileExtension.json:
            runner = JsonRunner()
        }

        runner?.run(input: linkedResult, rules: ruleParser.rules, outputFile: outputFile)
                .subscribe(onSuccess: nil, onError: { error in
                    print("Error while Running: \(error)")
                }, onCompleted: {

                })
    }

    for inputFile in inputFiles {

        let compiler = Compiler(inputFile: inputFile)

        var linkedResult = [FancyLanguageNode]()

        compiler.compile()
                .foldLeft { error in
                    print("Compiler error \(error)")
                }
                .foldRight { nodes in
                    let linker = Linker(input: nodes, rules: ruleParser.rules)

                    linkedResult = linker.link()

                    let inputFileName = inputFile.substringFrom(phrase: "/")

                    guard let outputRule = ruleParser.rules[inputFileName] else {
                        return
                    }

                    outputRule.traverse { ruleNodeValue in

                        runFor(outputFile: ruleNodeValue, linkedResult: linkedResult)
                    }
                }
    }
}


run()
