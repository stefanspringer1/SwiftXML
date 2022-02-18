//
//  Nodes.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation
import SwiftXMLInterfaces
import SwiftXMLParser

protocol Named: AnyObject {
    associatedtype WithName
    var _bareName: String? { get set }
    var _sharedName: XValue? { get set }
    var previousWithSameName: WithName? { get set }
    var nextWithSameName: WithName? { get set }
}

public class XNode {
    
    /**
     The reference to the original node after cloning.
     But this is a weak reference, the clone must be contained by
     other means to exist.
     */
    weak var _r: XNode? = nil
    
    public var r: XNode? {
        get {
            return _r
        }
    }
    
    /**
     The oldest source of cloning.
     */
    public var rr: XNode? {
        get {
            var ref = _r
            while let further = ref?._r {
                ref = further
            }
            return ref
        }
    }
    
    public var rpath: [XNode]? {
        get {
            var ref = _r
            if let theRef = ref {
                var path = [XNode]()
                path.append(theRef)
                while let further = ref?._r {
                    ref = further
                    path.append(further)
                }
                return path
            }
            else {
                return nil
            }
        }
    }
    
    public var document: XDocument? {
        get {
            return (self as? XBranch)?._document ?? self.parent?._document
        }
    }
    
    /**
     Usually the clone will have "r" pointed to the original node.
     If "forwardref", then this direction will be inversed, i.e.
     the original node is pointing to the clone.
     */
    public func shallowClone(forwardref: Bool = false) -> XNode {
        let theClone = XNode()
        if forwardref {
            theClone._r = _r
            _r = theClone
        }
        else {
            theClone._r = self
        }
        return theClone
    }
    
    public func clone(forwardref: Bool = false) -> XNode {
        return shallowClone(forwardref: forwardref)
    }
    
    private var _nodeIterators = WeakList<XNodeIterator>()
    
    func addNodeIterator(_ nodeIterator: XNodeIterator) {
        _nodeIterators.append(nodeIterator)
    }
    
    func removeNodeIterator(_ nodeIterator: XNodeIterator) {
        _nodeIterators.remove(nodeIterator)
    }
    
    func gotoPreviousOnNodeIterators() {
        _nodeIterators.forEach { _ = $0.previous() }
    }
    
    func prefetchOnNodeIterators() {
        _nodeIterators.forEach { $0.prefetch() }
    }
    
    func insertPrevious(_ node: XNode) {
        if let selfAsText = self as? XText, let newAsText = node as? XText {
            selfAsText._value = newAsText._value + selfAsText._value
            selfAsText.whitespace = .UNKNOWN
        }
        else {
            if parent?._firstChild === self {
                parent?._firstChild = node
            }
            
            node.detach()
            
            _previous?._next = node
            node._previous = _previous
            node._next = self
            _previous = node
            node._parent = _parent
            
            // set document:
            if let element = node as? XElement, let theDocument = parent?._document, !(element._document === theDocument) {
                element.setDocument(document: theDocument)
            }
        }
    }
    
    func insertPrevious(_ text: String) {
        if !text.isEmpty {
            if let selfAsText = self as? XText {
                selfAsText._value = text + selfAsText._value
                selfAsText.whitespace = .UNKNOWN
            }
            else {
                insertPrevious(XText(text))
            }
        }
    }
    
    public func insertPrevious(@XNodeBuilder builder: () -> XNodeLike) {
        (builder() as? [XNode])?.forEach { insertPrevious($0) }
    }
    
    func insertNext(_ node: XNode) {
        if let selfAsText = self as? XText, let newAsText = node as? XText {
            selfAsText._value = selfAsText._value + newAsText._value
            selfAsText.whitespace = .UNKNOWN
        }
        else if parent?._lastChild === self {
            parent?.add(node)
        }
        else {
            node.detach()
            
            _next?._previous = node
            node._previous = self
            node._next = _next
            _next = node
            node._parent = _parent
            
            // set document:
            if let element = node as? XElement, let theDocument = parent?._document, !(element._document === theDocument) {
                element.setDocument(document: theDocument)
            }
        }
    }
    
    func insertNext(_ text: String) {
        if !text.isEmpty {
            if let selfAsText = self as? XText {
                selfAsText._value = selfAsText._value + text
                selfAsText.whitespace = .UNKNOWN
            }
            else {
                insertNext(XText(text))
            }
        }
    }
    
    public func insertNext(@XNodeBuilder builder: () -> XNodeLike) {
        (builder() as? [XNode])?.reversed().forEach { insertNext($0) }
    }
    
    /**
     Replace the node by other nodes.
     If "forward", then detaching prefetches the next node in iterators.
     */
    public func set(forward: Bool = false, @XNodeBuilder builder: () -> XNodeLike) {
        if let theNext = _next {
            remove(forward: forward)
            (builder() as? [XNode])?.forEach { theNext.insertPrevious($0) }
            
        }
        else if let theParent = _parent {
            remove(forward: forward)
            (builder() as? [XNode])?.forEach { theParent.add($0) }
        }
    }
    
    weak var _parent: XBranch? = nil
    
    public var parent: XElement? {
        get {
            return _parent as? XElement
        }
    }
    
    weak var _previous: XNode? = nil
    var _next: XNode? = nil
    
    weak var _previousInTree: XNode? = nil
    weak var _nextInTree: XNode? = nil
    
    /**
     Removes the node from the tree structure and the tree order,
     but keeps it in the document.
     If "forward", then detaching prefetches the next node in iterators.
     Else, the iterators all told to go to the previous node.
     */
    public func detach(forward: Bool = false) {
        
        // correction in iterators:
        if forward {
            prefetchOnNodeIterators()
        }
        else {
            gotoPreviousOnNodeIterators()
        }
        
        // tree order:
        let theLastInTree = getLastInTree()
        _previousInTree?._nextInTree = theLastInTree._nextInTree
        theLastInTree._nextInTree?._previousInTree = _previousInTree
        theLastInTree._nextInTree = nil
        var ancestor = _parent
        while let theAncestor = ancestor, theAncestor.lastInTree === theLastInTree {
            theAncestor.lastInTree = _previousInTree ?? theAncestor
            ancestor = ancestor?._parent
        }
        _previousInTree = nil
        
        // tree structure:
        if let thePrevious = _previous {
            thePrevious._next = _next
        }
        if let theNext = _next {
            theNext._previous = _previous
        }
        if let theParent = _parent {
            if theParent._firstChild === self {
                theParent._firstChild = _next
            }
            if theParent._lastChild === self {
                theParent._lastChild = _previous
            }
        }
    }
    
    /**
     Removes the node from the tree structure and the tree order and
     the document.
     If "forward", then detaching prefetches the next node in iterators.
     Else, the iterators all told to go to the previous node.
     */
    public func remove(forward: Bool = false) {
        detach(forward: forward)
        if let meAsElement = self as? XElement {
            meAsElement.document?.unregisterElement(element: meAsElement)
        }
    }
    
    func getLastInTree() -> XNode {
        return self
    }
    
    public func traverse(down: @escaping (XNode) -> (), up: ((XBranch) -> ())? = nil) {
        let directionIndicator = XDirectionIndicator()
        XTraversalSequence(node: self, directionIndicator: directionIndicator).forEach { node in
            if directionIndicator.up {
                if let branch = node as? XBranch {
                    up?(branch)
                }
            }
            else {
                down(node)
            }
        }
    }
    
    public func traverseAsync(down: @escaping (XNode) async -> (), up: ((XBranch) async -> ())? = nil) async {
        let directionIndicator = XDirectionIndicator()
        await XTraversalSequence(node: self, directionIndicator: directionIndicator).forEachAsync { node in
            if directionIndicator.up {
                if let branch = node as? XBranch {
                    await up?(branch)
                }
            }
            else {
                await down(node)
            }
        }
    }
    
    public func traverseAsyncThrowing(down: @escaping (XNode) async throws -> (), up: ((XBranch) async throws -> ())? = nil) async throws {
        let directionIndicator = XDirectionIndicator()
        try await XTraversalSequence(node: self, directionIndicator: directionIndicator).forEachAsyncThrowing { node in
            if directionIndicator.up {
                if let branch = node as? XBranch {
                    try await up?(branch)
                }
            }
            else {
                try await down(node)
            }
        }
    }
    
    func produceEntering(production: XProduction) {
        // to be implemented by subclass
    }
    
    public func applyProduction(production: XProduction) {
        traverse { node in
            node.produceEntering(production: production)
        } up: { branch in
            branch.produceLeaving(production: production)
        }
    }
    
    public func write(toFileHandle fileHandle: FileHandle, production: XProduction = XDefaultProduction()) {
        production.setFile(fileHandle)
        self.applyProduction(production: production)
    }
    
    public func write(toFile path: String, production: XProduction = XDefaultProduction()) {
        let fileManager = FileManager.default
    
        fileManager.createFile(atPath: path,  contents:Data("".utf8), attributes: nil)
        
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            write(toFileHandle: fileHandle, production: production)
            fileHandle.closeFile()
        }
        else {
            print("ERROR: cannot write to [\(path)]");
        }
        
    }
    
    public func echo(production: XProduction? = nil) {
        applyProduction(production: production ?? XDefaultProduction())
    }
}

//public protocol XNodeLike: CustomStringConvertible {}

public class XBranch: XNode, WithAttic {
    
    weak var _document: XDocument? = nil
    
    var _firstChild: XNode? = nil
    var _lastChild: XNode? = nil
    
    var _attic: Index<String,AnyObject>? = nil
    
    public func intoAttic(_ value: AnyObject, forKey key: String) {
        if _attic == nil { _attic = Index<String,AnyObject>() }
        _attic?.add(value, forKey: key)
    }
    
    public func fromAttic(forKey key: String) -> Array<AnyObject>? {
        return _attic?[key]
    }
    
    public func removeFromAttic(_ value: AnyObject, forKey key: String) {
        _attic?.remove(value, forKey: key)
    }
    
    public func addClones(from source: XBranch, forwardref: Bool = false) {
        source.content.forEach { node in
            add(node.shallowClone())
        }
        allContent.forEach { node in
            if let element = node as? XElement {
                element._r?.content.forEach { node in
                    element.add(node.shallowClone())
                }
            }
            if forwardref {
                let source = node._r
                node._r = source?._r
                source?._r = node
            }
        }
    }
    
    public var first: XNode? {
        get {
            return _firstChild
        }
    }
    
    public var last: XNode? {
        get {
            return _lastChild
        }
    }
    
    weak var lastInTree: XNode!
    
    override init() {
        super.init()
        lastInTree = self
    }
    
    public var isEmpty: Bool {
        get {
            return _firstChild == nil
        }
    }
    
    override func getLastInTree() -> XNode {
        return lastInTree
    }
    
    /**
     Correct the tree order after a new child has been inserted.
     This is only necessary if the new child is the last child.
     */
    func setTreeOrder(withNewChild newChild: XNode) {
        if newChild === _lastChild {
            let newLastInTree = newChild.getLastInTree()
            
            newChild._previousInTree = lastInTree
            newLastInTree._nextInTree = lastInTree._nextInTree
            lastInTree._nextInTree?._previousInTree = newChild
            lastInTree._nextInTree = newChild
            
            if _firstChild === newChild {
                _nextInTree = newChild
            }
            
            var ancestor: XBranch? = self._parent
            while let theAncestor = ancestor, theAncestor.lastInTree === lastInTree {
                theAncestor.lastInTree = newLastInTree
                ancestor = theAncestor._parent ?? theAncestor._document
            }
            
            lastInTree = newLastInTree
        }
    }
    
    /**
     When adding content, setting skip = true let iterators continue _after_ the
     inserted content.
     Else, the iterator will iterate through the inserted content.
     */
    func add(_ node: XNode, skip: Bool = false) {
        if let lastAsText = last as? XText, let newAsText = node as? XText {
            lastAsText._value = lastAsText._value + newAsText._value
            lastAsText.whitespace = .UNKNOWN
        }
        else {
            node.detach(forward: skip)
            
            // insert into new chain:
            if let theLastChild = _lastChild {
                theLastChild._next = node
                node._previous = theLastChild
            }
            else {
                _firstChild = node
                node._previous = nil
            }
            _lastChild = node
            node._next = nil
            
            // set parent:
            node._parent = self
            
            // set tree order:
            setTreeOrder(withNewChild: node)
            
            // set document:
            if let element = node as? XElement, !(element._document === _document) {
                element.setDocument(document: _document)
            }
        }
    }
    
    func add(_ text: String) {
        if !text.isEmpty {
            if let lastAsText = last as? XText {
                lastAsText._value = lastAsText._value + text
                lastAsText.whitespace = .UNKNOWN
            }
            else {
                add(XText(text))
            }
        }
    }
    
    public func add(skip: Bool = false, @XNodeBuilder builder: () -> XNodeLike) {
        (builder() as? [XNode])?.forEach { add($0, skip: skip) }
    }
    
    /**
     When adding content, setting skip = true let iterators continue _after_ the
     inserted content.
     Else, the iterator will iterate through the inserted content.
     */
    func addFirst(_ node: XNode, skip: Bool = false) {
        if let firstAsText = first as? XText, let newAsText = node as? XText {
            firstAsText._value = newAsText._value + firstAsText._value
            firstAsText.whitespace = .UNKNOWN
        }
        else {
            node.detach(forward: skip)
            
            // insert into new chain:
            if let theFirstChild = _firstChild {
                theFirstChild._previous = node
                node._next = theFirstChild
            }
            else {
                _lastChild = node
                node._next = nil
            }
            _firstChild = node
            node._previous = nil
            
            // set parent:
            node._parent = self
            
            // set tree order:
            setTreeOrder(withNewChild: node)
            
            // set document:
            if let element = node as? XElement, !(element._document === _document) {
                element.setDocument(document: _document)
            }
        }
    }
    
    func addFirst(_ text: String) {
        if !text.isEmpty {
            if let firstAsText = first as? XText {
                firstAsText._value = text + firstAsText._value
                firstAsText.whitespace = .UNKNOWN
            }
            else {
                addFirst(XText(text))
            }
        }
    }
    
    public func addFirst(skip: Bool = false, @XNodeBuilder builder: () -> XNodeLike) {
        (builder() as? [XNode])?.reversed().forEach { addFirst($0, skip: skip) }
    }
    
    func produceLeaving(production: XProduction) {
        // to be implemented by subclass
    }
}

public protocol XNodeLike {}

extension XNode: XNodeLike {}

extension String: XNodeLike {}

extension Array: XNodeLike where Element == XNodeLike {}

extension XContentSequence: XNodeLike {}

final class XAttribute: XNode, Named {
    
    var attributeIterators = WeakList<XAttributeIterator>()
    
    var _bareName: String?
    var _sharedName: XValue? = nil
    
    var name: String {
        get {
            return (_sharedName?.value ?? _bareName)!
        }
    }
    
    var value: String
    weak var element: XElement?
    
    weak var previousWithSameName: XAttribute? = nil
    var nextWithSameName: XAttribute? = nil
    
    init(name: String, value: String, element: XElement) {
        self._bareName = name
        self.value = value
        self.element = element
    }
    
    // prevent stack overflow when destroying the list of elements with same name,
    // to be applied on the first element in that list,
    // cf. https://forums.swift.org/t/deep-recursion-in-deinit-should-not-happen/54987
    func removeFollowingWithSameName() {
        var node = self
        while isKnownUniquelyReferenced(&node.nextWithSameName) {
            (node, node.nextWithSameName) = (node.nextWithSameName!, nil)
        }
    }
}

final class XNodeSampler {
    
    var nodes: [XNodeLike] = [XNode]()
    
    func add(_ thing: XNodeLike) {
        if let node = thing as? XNode {
            nodes.append(node)
        }
        else if let s = thing as? String {
            nodes.append(XText(s))
        }
        else if let contentsSequence = thing as? XContentSequence {
            contentsSequence.forEach { self.add($0) }
        }
        else if let contentsSequence = thing as? [XNodeLike] {
            contentsSequence.forEach { self.add($0) }
        }
        else if let p = thing as? CustomStringConvertible {
            nodes.append(XText(p.description))
        }
        else {
            nodes.append(XText("[\(type(of: thing))]"))
        }
    }
}

@resultBuilder
public struct XNodeBuilder {
    public static func buildBlock(_ components: XNodeLike?...) -> XNodeLike {
        let sampler = XNodeSampler()
        components.forEach { if let nodeLike = $0 { sampler.add(nodeLike) } }
        return sampler.nodes
    }
}

public protocol WithAttic {
    func intoAttic(_ value: AnyObject, forKey key: String)
    func fromAttic(forKey key: String) -> Array<AnyObject>?
    func removeFromAttic(_ value: AnyObject, forKey key: String)
}

public final class XElement: XBranch, CustomStringConvertible {
    
    var _treeIterators = WeakList<XElementTreeIterator>()
    var _nameIterators = WeakList<XElementNameIterator>()
    
    var _attributes: [String:XAttribute]? = nil
    var _attributeNames: [String]? = nil
    
    public var description: String {
        get {
            """
            <\(name)\(_attributes?.isEmpty == false ? " " : "")\(_attributes?.sorted { $0.0 < $1.0 }.map { (name, value) in
                "\(name)=\"\(escapeDoubleQuotedValue(value.value))\""
            }.joined(separator: " ") ?? "")>
            """
        }
    }
    
    public func copyAttributes(from other: XElement) {
        other.attributeNames.forEach { attributeName in
            if let theValue = other[attributeName] {
                self[attributeName] = theValue
            }
        }
    }
    
    public override func shallowClone(forwardref: Bool = false) -> XElement {
        let theClone = XElement(name)
        if forwardref {
            theClone._r = _r
            _r = theClone
        }
        else {
            theClone._r = self
        }
        theClone.copyAttributes(from: self)
        return theClone
    }
    
    public override func clone(forwardref: Bool = false) -> XElement {
        let theClone = shallowClone(forwardref: forwardref)
        theClone.addClones(from: self, forwardref: forwardref)
        return theClone
    }
    
    var _name: String
    
    public var name: String {
        get { _name }
        set(newName) {
            if newName != _name {
                if let theDocument = _document {
                    _nameIterators.forEach { _ = $0.previous() }
                    theDocument.unregisterElement(element: self)
                    _name = newName
                    theDocument.registerElement(element: self)
                }
                else {
                    _name = newName
                }
            }
        }
    }
    
    public var xpath: String {
        get {
            let myName = name
            return "/" + ([
                self.ancestors.reversed().map {
                    let itsName = $0.name
                    return "\(itsName)[\($0.previousElements.filter { $0.name == itsName }.count+1)]"
                }.joined(separator: "/"),
                "\(name)[\(previousElements.filter { $0.name == myName }.count+1)]"
            ].joinedNonEmpties(separator: "/") ?? "")
        }
    }
    
    private let EMPTY: [String] = []
    
    public var attributeNames: [String] {
        get {
            return _attributeNames ?? EMPTY
        }
    }
    
    weak var previousWithSameName: XElement? = nil
    var nextWithSameName: XElement? = nil
    
    // prevent stack overflow when destroying the list of elements with same name,
    // to be applied on the first element in that list,
    // cf. https://forums.swift.org/t/deep-recursion-in-deinit-should-not-happen/54987
    func removeFollowingWithSameName() {
        var node = self
        while isKnownUniquelyReferenced(&node.nextWithSameName) {
            (node, node.nextWithSameName) = (node.nextWithSameName!, nil)
        }
    }
    
    public subscript(attributeName: String) -> String? {
        get {
            _attributes?[attributeName]?.value
        }
        set(newValue) {
            var oldValue: String? = nil
            if let theNewValue = newValue {
                if let existing = self._attributes?[attributeName] {
                    oldValue = existing.value
                    existing.value = theNewValue
                    _document?.attributeValueChanged(element: self, name: attributeName, oldValue: oldValue, newValue: theNewValue)
                }
                else {
                    let newAttribute = XAttribute(name: attributeName, value: theNewValue, element: self)
                    if self._attributes == nil {
                        self._attributes = [String:XAttribute]()
                    }
                    self._attributes?[attributeName] = newAttribute
                    if self._attributeNames == nil {
                        self._attributeNames = [String]()
                    }
                    self._attributeNames?.append(attributeName)
                    _document?.registerAttribute(attribute: newAttribute)
                    _document?.attributeValueChanged(element: self, name: attributeName, oldValue: nil, newValue: theNewValue)
                }
            }
            else if let existing = self._attributes?[attributeName] {
                oldValue = existing.value
                self._attributes?[attributeName] = nil
                if _attributes?.isEmpty == true {
                    _attributes = nil
                }
                if var theAttributeNames = _attributeNames {
                    var i = 0
                    var takeNext = false
                    while i < theAttributeNames.count - 1 {
                        if theAttributeNames[i] == attributeName {
                            takeNext = true
                        }
                        if takeNext {
                            theAttributeNames[i] = theAttributeNames[i+1]
                        }
                        i += 1
                    }
                    theAttributeNames.removeLast()
                }
                _document?.unregisterAttribute(attribute: existing)
                _document?.attributeValueChanged(element: self, name: attributeName, oldValue: oldValue, newValue: nil)
            }
        }
    }
    
    public init(_ name: String, _ attributes: [String:String?]? = nil) {
        self._name = name
        super.init()
        if let theAttributes = attributes {
            setAttributes(attributes: theAttributes)
        }
    }
    
    public init(_ name: String, _ attributes: [String:String?]? = nil, @XNodeBuilder builder: () -> XNodeLike) {
        self._name = name
        super.init()
        if let theAttributes = attributes {
            setAttributes(attributes: theAttributes)
        }
        (builder() as? [XNode])?.forEach { add($0) }
    }
    
    init(_ name: String, document: XDocument) {
        self._name = name
        super.init()
        self._document = document
    }
    
    public override func detach(forward: Bool = false) {
        
        // correction in iterators:
        if forward {
            _treeIterators.forEach { $0.prefetch() }
            _nameIterators.forEach { $0.prefetch() }
        }
        else {
            _treeIterators.forEach { _ = $0.previous() }
            _nameIterators.forEach { _ = $0.previous() }
        }
        
        super.detach(forward: forward)
    }
    
    func setAttributes(attributes newAtttributeValues: [String:String?]? = nil) {
        if self._attributes == nil {
            self._attributes = [String:XAttribute]()
        }
        newAtttributeValues?.forEach { name, value in
            self[name] = value
        }
    }
    
    func setDocument(document newDocument: XDocument?) {
        var node: XNode? = self
        repeat {
            if let element = node as? XElement {
                element._document?.unregisterElement(element: element)
                element._document = newDocument
                newDocument?.registerElement(element: element)
            }
            if self.getLastInTree() === node {
                break
            }
            node = node?._nextInTree
        } while node != nil
    }
    
    override func produceEntering(production: XProduction) {
        production.writeElementStartBeforeAttributes(element: self)
        if let theAttributes = _attributes {
            production.sortAttributeNames(attributeNames: Array(theAttributes.keys), element: self).forEach { attributeName in
                if let theAttribute = theAttributes[attributeName] {
                    production.writeAttribute(name: theAttribute.name, value: theAttribute.value, element: self)
                }
            }
        }
        production.writeElementStartAfterAttributes(element: self)
    }
    
    override func produceLeaving(production: XProduction) {
        production.writeElementEnd(element: self)
    }
}

public final class XText: XNode, CustomStringConvertible {
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set (newText) {
            if newText.isEmpty {
                self.remove()
            }
            else {
                _value = newText
                whitespace = .UNKNOWN
            }
        }
    }
    
    public var description: String {
        get {
            _value
        }
    }
    
    public var whitespace: WhitespaceIndicator
    
    public init(_ text: String, whitespace: WhitespaceIndicator = .UNKNOWN) {
        self._value = text
        self.whitespace = whitespace
    }
    
    public override func produceEntering(production: XProduction) {
        production.writeText(text: self)
    }
    
    public override func shallowClone(forwardref: Bool = false) -> XText {
        let theClone = XText(_value, whitespace: whitespace)
        if forwardref {
            theClone._r = _r
            _r = theClone
        }
        else {
            theClone._r = self
        }
        return theClone
    }
    
    public override func clone(forwardref: Bool = false) -> XText {
        return shallowClone(forwardref: forwardref)
    }
}

public final class XInternalEntity: XNode {
    
    var _name: String
    
    public var name: String {
        get {
            return _name
        }
        set(newName) {
            _name = newName
        }
    }
    
    init(_ name: String) {
        self._name = name
    }
    
    override func produceEntering(production: XProduction) {
        production.writeInternalEntity(internalEntity: self)
    }
    
    public override func shallowClone(forwardref: Bool = false) -> XInternalEntity {
        let theClone = XInternalEntity(_name)
        if forwardref {
            theClone._r = _r
            _r = theClone
        }
        else {
            theClone._r = self
        }
        return theClone
    }
    
    public override func clone(forwardref: Bool = false) -> XInternalEntity {
        return shallowClone(forwardref: forwardref)
    }
}

public final class XExternalEntity: XNode {
    
    var _name: String
    
    public var name: String {
        get {
            return _name
        }
        set(newName) {
            _name = newName
        }
    }
    
    init(_ name: String) {
        self._name = name
    }
    
    override func produceEntering(production: XProduction) {
        production.writeExternalEntity(externalEntity: self)
    }
    
    public override func shallowClone(forwardref: Bool = false) -> XExternalEntity {
        let theClone = XExternalEntity(_name)
        if forwardref {
            theClone._r = _r
            _r = theClone
        }
        else {
            theClone._r = self
        }
        return theClone
    }
    
    public override func clone(forwardref: Bool = false) -> XExternalEntity {
        return shallowClone(forwardref: forwardref)
    }
}

public final class XProcessingInstruction: XNode, CustomStringConvertible {
    
    var _target: String
    var _data: String?
    
    public var description: String {
        get {
            """
            <?\(_target)\(_data?.isEmpty == false ? " " : "")\(_data ?? "")?>
            """
        }
    }
    
    public var target: String {
        get {
            return _target
        }
        set(newTarget) {
            _target = newTarget
        }
    }
    
    public var data: String? {
        get {
            return _data
        }
        set(newData) {
            _data = newData
        }
    }
    
    init(target: String, data: String?) {
        self._target = target
        self._data = data
    }
    
    override func produceEntering(production: XProduction) {
        production.writeProcessingInstruction(processingInstruction: self)
    }
    
    public override func shallowClone(forwardref: Bool = false) -> XProcessingInstruction {
        let theClone = XProcessingInstruction(target: _target, data: _data)
        if forwardref {
            theClone._r = _r
            _r = theClone
        }
        else {
            theClone._r = self
        }
        return theClone
    }
    
    public override func clone(forwardref: Bool = false) -> XProcessingInstruction {
        return shallowClone(forwardref: forwardref)
    }
}

public final class XComment: XNode {
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set(newText) {
            _value = newText
        }
    }
    
    init(text: String) {
        self._value = text
    }
    
    override func produceEntering(production: XProduction) {
        production.writeComment(comment: self)
    }
    
    public override func shallowClone(forwardref: Bool = false) -> XComment {
        let theClone = XComment(text: _value)
        if forwardref {
            theClone._r = _r
            _r = theClone
        }
        else {
            theClone._r = self
        }
        return theClone
    }
    
    public override func clone(forwardref: Bool = false) -> XComment {
        return shallowClone(forwardref: forwardref)
    }
}

public final class XCDATASection: XNode {
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set(newText) {
            _value = newText
        }
    }
    
    init(text: String) {
        self._value = text
    }
    
    override func produceEntering(production: XProduction) {
        production.writeCDATASection(cdataSection: self)
    }
    
    public override func shallowClone(forwardref: Bool = false) -> XCDATASection {
        let theClone = XCDATASection(text: _value)
        if forwardref {
            theClone._r = _r
            _r = theClone
        }
        else {
            theClone._r = self
        }
        return theClone
    }
    
    public override func clone(forwardref: Bool = false) -> XCDATASection {
        return shallowClone(forwardref: forwardref)
    }
}

public class XDeclarationInInternalSubset {
    
    var _name: String = ""
    
    public var name: String {
        get {
            return _name
        }
        set(newName) {
            _name = newName
        }
    }
    
    public init(name: String) {
        self._name = name
    }
    
    func produceEntering(production: XProduction) {}
    
    func shallowClone() -> XDeclarationInInternalSubset {
        return XDeclarationInInternalSubset(name: _name)
    }
}

/**
 internal entity declaration
 */
public final class XInternalEntityDeclaration: XDeclarationInInternalSubset {
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set(newValue) {
            _value = newValue
        }
    }
    
    public init(name: String, value: String) {
        self._value = value
        super.init(name: name)
    }
    
    override func produceEntering(production: XProduction) {
        production.writeInternalEntityDeclaration(internalEntityDeclaration: self)
    }
    
    public override func shallowClone() -> XInternalEntityDeclaration {
        return XInternalEntityDeclaration(name: _name, value: _value)
    }
}

/**
 parsed external entity declaration
 */
public final class XExternalEntityDeclaration: XDeclarationInInternalSubset {
    var _publicID: String?
    var _systemID: String
    
    public var publicID: String? {
        get {
            return _publicID
        }
        set(newPublicID) {
            _publicID = newPublicID
        }
    }
    
    public var systemID: String {
        get {
            return _systemID
        }
        set(newSystemID) {
            _systemID = newSystemID
        }
    }
    
    public init(name: String, publicID: String?, systemID: String) {
        self._publicID = publicID
        self._systemID = systemID
        super.init(name: name)
    }
    
    override func produceEntering(production: XProduction) {
        production.writeExternalEntityDeclaration(externalEntityDeclaration: self)
    }
    
    public override func shallowClone() -> XExternalEntityDeclaration {
        return XExternalEntityDeclaration(name: _name, publicID: _publicID, systemID: _systemID)
    }
}

/**
 unparsed external entity declaration
 */
public final class XUnparsedEntityDeclaration: XDeclarationInInternalSubset {
    var _publicID: String?
    var _systemID: String
    var _notationName: String
    
    public var publicID: String? {
        get {
            return _publicID
        }
        set(newPublicID) {
            _publicID = newPublicID
        }
    }
    
    public var systemID: String {
        get {
            return _systemID
        }
        set(newSystemID) {
            _systemID = newSystemID
        }
    }
    
    public var notationName: String {
        get {
            return _notationName
        }
        set(newNotationName) {
            _notationName = newNotationName
        }
    }
    
    public init(name: String, publicID: String?, systemID: String, notationName: String) {
        self._publicID = publicID
        self._systemID = systemID
        self._notationName = notationName
        super.init(name: name)
    }
    
    override func produceEntering(production: XProduction) {
        production.writeUnparsedEntityDeclaration(unparsedEntityDeclaration: self)
    }
    
    public override func shallowClone() -> XUnparsedEntityDeclaration {
        return XUnparsedEntityDeclaration(name: _name, publicID: _publicID, systemID: _systemID, notationName: _notationName)
    }
}

/**
 notation declaration
 */
public final class XNotationDeclaration: XDeclarationInInternalSubset {
    
    var _publicID: String?
    var _systemID: String?
    
    public var publicID: String? {
        get {
            return _publicID
        }
        set(newPublicID) {
            _publicID = newPublicID
        }
    }
    
    public var systemID: String? {
        get {
            return _systemID
        }
        set(newSystemID) {
            _systemID = newSystemID
        }
    }
    
    public init(name: String, publicID: String?, systemID: String?) {
        self._publicID = publicID
        self._systemID = systemID
        super.init(name: name)
    }
    
    override func produceEntering(production: XProduction) {
        production.writeNotationDeclaration(notationDeclaration: self)
    }
    
    public override func shallowClone() -> XNotationDeclaration {
        return XNotationDeclaration(name: _name, publicID: _publicID, systemID: _systemID)
    }
}

/**
 element declaration
 */
public final class XElementDeclaration: XDeclarationInInternalSubset {
    
    var _literal: String
    
    public var literal: String {
        get {
            return _literal
        }
        set(newLiteral) {
            _literal = newLiteral
        }
    }
    
    public init(name: String, literal: String) {
        self._literal = literal
        super.init(name: name)
    }
    
    override func produceEntering(production: XProduction) {
        production.writeElementDeclaration(elementDeclaration: self)
    }
    
    public override func shallowClone() -> XElementDeclaration {
        return XElementDeclaration(name: _name, literal: _literal)
    }
}

/**
 attribute list declaration
 */
public final class XAttributeListDeclaration: XDeclarationInInternalSubset {
    
    var _literal: String
    
    public var literal: String {
        get {
            return _literal
        }
        set(newLiteral) {
            _literal = newLiteral
        }
    }
    
    public init(name: String, literal: String) {
        self._literal = literal
        super.init(name: name)
    }
    
    override func produceEntering(production: XProduction) {
        production.writeAttributeListDeclaration(attributeListDeclaration: self)
    }
    
    public override func shallowClone() -> XAttributeListDeclaration {
        return XAttributeListDeclaration(name: _name, literal: _literal)
    }
}

/**
 parameter entity declaration
 */
public final class XParameterEntityDeclaration: XDeclarationInInternalSubset {
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set(newValue) {
            _value = newValue
        }
    }
    
    public init(name: String, value: String) {
        self._value = value
        super.init(name: name)
    }
    
    override func produceEntering(production: XProduction) {
        production.writeParameterEntityDeclaration(parameterEntityDeclaration: self)
    }
    
    public override func shallowClone() -> XParameterEntityDeclaration {
        return XParameterEntityDeclaration(name: _name, value: _value)
    }
}
