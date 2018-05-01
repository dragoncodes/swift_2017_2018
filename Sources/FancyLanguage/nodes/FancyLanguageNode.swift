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

        // TODO check if the child isn't self

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

struct FancyLanguageProperty {
    let name: String

    let value: Any?
}
