class FancyLanguageNode {

    let name: String

    var value: String?

    var children: [FancyLanguageNode]

    var attributes: [FancyLanguageProperty]

    public var description: String {

        var stringifiedChildren = ""

        children.forEach { node in
            stringifiedChildren += node.name + node.description
        }

        return "\(name)"
    }

    public var hasChildren: Bool {
        get {
            return !children.isEmpty
        }
    }

    init(name: String) {

        self.name = name

        children = []

        attributes = []
    }

    func addChild(child: FancyLanguageNode) {

        let isChildContained = children.contains { definedChild -> Bool in
            return definedChild === child
        }

        if isChildContained {
            return
        }

        children.append(child)
    }

    func addAttribute(name: String, value: String?) {
        attributes.append(FancyLanguageProperty(name: name, value: value))
    }
}

class FancyLanguageProperty {
    let name: String

    let value: Any?

    init(name: String, value: Any? = nil) {
        self.name = name
        self.value = value
    }
}

extension Array where Element: FancyLanguageProperty {

    func toDictionary() -> [String: FancyLanguageProperty] {
        var result = [String: FancyLanguageProperty]()

        for property in self {
            result[property.name] = property
        }

        return result
    }
}
