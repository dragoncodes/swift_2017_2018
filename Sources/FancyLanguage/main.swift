//
// Created by dragoncodes on 6.04.18.

func run() {

    let inputFiles = ["testData/in.json"]
    let ruleParser = RuleParser(rulesFilePath: "testData/rules.txt")


    for inputFile in inputFiles {

        let compiler = Compiler(inputFile: inputFile)

        guard ruleParser.parseRules() else {
            return print("Error parsing rules")
        }

        var linkedResult = [FancyLanguageNode]()

        compiler.compile()
                .foldLeft { error in
                    print("Compiler error \(error)")
                }
                .foldRight { nodes in
                    let linker = Linker(input: nodes, rules: ruleParser.rules)

                    linkedResult = linker.link()

                    HtmlRunner().run(input: linkedResult, rules: ruleParser.rules, inputFile: inputFile)
                            .subscribe(onSuccess: nil, onError: { error in
                                print("Error while Running: \(error)")
                            }, onCompleted: {
                        
                            })

//                    Runner.run(input: linkedResult, rules: ruleParser.rules, inputFile: inputFile)
                }
    }
}

run()
