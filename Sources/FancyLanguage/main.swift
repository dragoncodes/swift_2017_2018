//
// Created by dragoncodes on 6.04.18.

func run() {

    let inputFiles = ["testData/in.json"]
    let ruleParser = RuleParser(rulesFilePath: "testData/rules.txt")

    guard ruleParser.parseRules() else {
        return print("Error parsing rules")
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

                    guard let outputRule = ruleParser.rules[inputFile.substringFrom(phrase: "/")] else {
                        return
                    }

                    guard let outputFileExtension = FileExtension(rawValue: outputRule.value.substringFrom(phrase: ".")) else {
                        return
                    }

                    var runner: Runner? = nil

                    switch outputFileExtension {
                    case FileExtension.html:
                        runner = HtmlRunner()
                    case FileExtension.xml:
                        runner = XmlRunner()
//                    case FileExtension.json:
//                        runner = JsonRunner()
                    
                    default:
                        runner = HtmlRunner()
                    }

                    runner?.run(input: linkedResult, rules: ruleParser.rules, inputFile: inputFile)
                            .subscribe(onSuccess: nil, onError: { error in
                                print("Error while Running: \(error)")
                            }, onCompleted: {

                            })
                }
    }
}

run()
