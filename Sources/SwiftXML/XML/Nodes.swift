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
    
    public func r(where condition: (XNode) -> Bool) -> XNode? {
        let node = _r
        if let theNode = node, condition(theNode) {
            return node
        }
        else {
            return nil
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
    
    public func rr(where condition: (XNode) -> Bool) -> XNode? {
        let node = rr
        if let theNode = node, condition(theNode) {
            return node
        }
        else {
            return nil
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
            return (self as? XBranchInternal)?._document ?? self.parent?._document
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
    
    public func clone(pointingFromClone: Bool = false) -> XNode {
        return shallowClone(forwardref: pointingFromClone)
    }
    
    private var _contentIterators = WeakList<XBidirectionalContentIterator>()
    
    func addContentIterator(_ nodeIterator: XBidirectionalContentIterator) {
        _contentIterators.append(nodeIterator)
    }
    
    func removeContentIterator(_ nodeIterator: XBidirectionalContentIterator) {
        _contentIterators.remove(nodeIterator)
    }
    
    func gotoPreviousOnContentIterators() {
        _contentIterators.forEach { _ = $0.previous() }
    }
    
    func prefetchOnContentIterators() {
        _contentIterators.forEach { $0.prefetch() }
    }
    
    weak var _parent: XBranchInternal? = nil
    
    public var parent: XElement? {
        get {
            return _parent as? XElement
        }
    }
    
    public func parent(where condition: (XElement) -> Bool) -> XElement? {
        let element = parent
        if let theElement = element, condition(theElement) {
            return theElement
        }
        else {
            return nil
        }
    }
    
    public func parent(_ name: String) -> XElement? {
        let element = parent
        if let theElement = element, theElement.name == name {
            return theElement
        }
        else {
            return nil
        }
    }
    
    weak var _previous: XContent? = nil
    var _next: XContent? = nil
    
    public var previousTouching: XContent? { get { _next } }
    public var nextTouching: XContent? { get { _next } }
    
    weak var _previousInTree: XNode? = nil
    weak var _nextInTree: XNode? = nil
    
    public var previousTouchingInTree: XContent? { get { _previousInTree as? XContent } }
    public var nextTouchingInTree: XContent? { get { _nextInTree as? XContent } }
    
    public func previousTouchingInTree(where condition: (XContent) -> Bool) -> XContent? {
        let content = previousTouchingInTree
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    public func nextTouchingInTree(where condition: (XContent) -> Bool) -> XContent? {
        let content = nextTouchingInTree
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    func getLastInTree() -> XNode {
        return self
    }
    
    public var lastInTree: XNode { get { return getLastInTree() } }
    
    public func traverse(down: @escaping (XNode) -> (), up: ((XNode) -> ())? = nil) {
        let directionIndicator = XDirectionIndicator()
        XTraversalSequence(node: self, directionIndicator: directionIndicator).forEach { node in
            if directionIndicator.up {
                if let branch = node as? XBranchInternal {
                    up?(branch)
                }
            }
            else {
                down(node)
            }
        }
    }
    
    public func traverseThrowing(down: @escaping (XNode) throws -> (), up: ((XNode) throws -> ())? = nil) throws {
        let directionIndicator = XDirectionIndicator()
        try XTraversalSequence(node: self, directionIndicator: directionIndicator).forEach { node in
            if directionIndicator.up {
                if let branch = node as? XBranchInternal {
                    try up?(branch)
                }
            }
            else {
                try down(node)
            }
        }
    }
    
    public func traverseAsync(down: @escaping (XNode) async -> (), up: ((XNode) async -> ())? = nil) async {
        let directionIndicator = XDirectionIndicator()
        await XTraversalSequence(node: self, directionIndicator: directionIndicator).forEachAsync { node in
            if directionIndicator.up {
                if let branch = node as? XBranchInternal {
                    await up?(branch)
                }
            }
            else {
                await down(node)
            }
        }
    }
    
    public func traverseAsyncThrowing(down: @escaping (XNode) async throws -> (), up: ((XNode) async throws -> ())? = nil) async throws {
        let directionIndicator = XDirectionIndicator()
        try await XTraversalSequence(node: self, directionIndicator: directionIndicator).forEachAsyncThrowing { node in
            if directionIndicator.up {
                if let branch = node as? XBranchInternal {
                    try await up?(branch)
                }
            }
            else {
                try await down(node)
            }
        }
    }
    
    func produceEntering(production: XProduction) throws {
        // to be implemented by subclass
    }
    
    public func applyProduction(production: XProduction) throws {
        try (self as? XDocument)?.produceEntering(production: production)
        try traverseThrowing { node in
            try node.produceEntering(production: production)
        } up: { branch in
            if let element = branch as? XElement {
                try element.produceLeaving(production: production)
            }
            else if let document = branch as? XDocument {
                try document.produceLeaving(production: production)
            }
        }
        try (self as? XDocument)?.produceLeaving(production: production)
    }
    
    public func write(toWriter writer: Writer, production: XProduction = XDefaultProduction()) throws {
        production.setWriter(writer)
        try self.applyProduction(production: production)
    }
    
    public func write(toFileHandle fileHandle: FileHandle, production: XProduction = XDefaultProduction()) throws {
        try write(toWriter: FileWriter(fileHandle), production: production)
    }
    
    public func write(toFile path: String, production: XProduction = XDefaultProduction()) throws {
        let fileManager = FileManager.default
    
        fileManager.createFile(atPath: path,  contents:Data("".utf8), attributes: nil)
        
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            try write(toFileHandle: fileHandle, production: production)
            fileHandle.closeFile()
        }
        else {
            print("ERROR: cannot write to [\(path)]");
        }
        
    }
    
    public func write(toURL url: URL, production: XProduction = XDefaultProduction()) throws {
        try write(toFile: url.path, production: production)
    }
    
    public func echo(usingProduction production: XProduction = XDefaultProduction(), terminator: String = "\n") {
        do {
            try write(toFileHandle: FileHandle.standardOutput, production: production); print(terminator, terminator: "")
        }
        catch {
            // writing to standard output does not really throw
        }
    }
    
    public func serialized(usingProduction production: XProduction = XDefaultProduction()) -> String {
        let writer = CollectingWriter()
        do {
            try write(toWriter: writer, production: production)
        }
        catch {
            // CollectingWriter does not really throw
        }
        return writer.description
    }
}

public class XContent: XNode {
    
    /**
     Correct the tree order after this node has been inserted.
     */
    func setTreeOrderWhenInserting() {
        
        let lastInMyTree = getLastInTree()
        
        // set _previousInTree & _nextInTree for self:
        self._previousInTree = _previous?.getLastInTree() ?? _parent
        lastInMyTree._nextInTree = self._previousInTree?._nextInTree
        
        // set _previousInTree or _nextInTree for them:
        self._previousInTree?._nextInTree = self
        lastInMyTree._nextInTree?._previousInTree = lastInMyTree
        
        // set _lastInTree:
        if self === _parent?._lastContent, let oldParentLastInTree = _parent?.lastInTree {
            var ancestor = _parent
            repeat {
                if let element = ancestor as? XElement {
                    element._lastInTree = lastInMyTree
                }
                else if let document = ancestor as? XDocument {
                    document._lastInTree = lastInMyTree
                }
                ancestor = ancestor?._parent
            } while ancestor?.getLastInTree() === oldParentLastInTree
        }
    }
    
    func setTreeOrderWhenRemoving() {
        
        let theLastInTree = getLastInTree()
        
        // correct _previousInTree and _nextInTree for remaining tree:
        _previousInTree?._nextInTree = theLastInTree._nextInTree
        theLastInTree._nextInTree?._previousInTree = _previousInTree
        
        // set _lastInTree for remaining tree:
        var ancestor = _parent
        while let theAncestor = ancestor, theAncestor.getLastInTree() === theLastInTree {
            if let element = theAncestor as? XElement {
                element._lastInTree = _previousInTree ?? theAncestor
            }
            else if let document = theAncestor as? XDocument {
                document._lastInTree = _previousInTree ?? theAncestor
            }
            ancestor = ancestor?._parent
        }
        
        // correct in own tree:
        _previousInTree = nil
        theLastInTree._nextInTree = nil
    }
    
    /**
     Removes the node from the tree structure and the tree order,
     but keeps it in the document.
     If "forward", then detaching prefetches the next node in iterators.
     Else, the iterators all told to go to the previous node.
     */
    func removeKeep(forward: Bool = false) {
        
        // correction in iterators:
        if forward {
            prefetchOnContentIterators()
        }
        else {
            gotoPreviousOnContentIterators()
        }
        
        // tree order:
        
        setTreeOrderWhenRemoving()
        
        // tree structure:
        if let thePrevious = _previous {
            thePrevious._next = _next
        }
        if let theNext = _next {
            theNext._previous = _previous
        }
        if let theParent = _parent {
            if theParent._firstContent === self {
                theParent._firstContent = _next
            }
            if theParent._lastContent === self {
                theParent._lastContent = _previous
            }
        }
    }
    
    /**
     Removes the content from the tree structure and the tree order and
     the document.
     If "forward", then detaching prefetches the next node in iterators.
     Else, the iterators all told to go to the previous node.
     */
    func _remove(forward: Bool = false) {
        removeKeep(forward: forward)
        if let meAsElement = self as? XElement {
            meAsElement.document?.unregisterElement(element: meAsElement)
        }
    }
    
    public override var previousTouchingInTree: XContent? { get { _previousInTree as? XContent } }
    public override var nextTouchingInTree: XContent? { get { _nextInTree as? XContent } }
    
    public override var lastInTree: XContent { get { return getLastInTree() as! XContent } }
    
    func insertPrevious(_ node: XContent) {
        if let selfAsText = self as? XText, let newAsText = node as? XText {
            selfAsText._value = newAsText._value + selfAsText._value
            selfAsText.whitespace = .UNKNOWN
        }
        else {
            if _parent?._firstContent === self {
                _parent?._firstContent = node
            }
            
            node.removeKeep()
            
            _previous?._next = node
            node._previous = _previous
            node._next = self
            _previous = node
            node._parent = _parent
            
            // set tree order:
            node.setTreeOrderWhenInserting()
            
            // set document:
            if let theDocument = _parent?._document, let element = node as? XElement, !(element._document === theDocument) {
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
    
    func _insertPrevious(@XNodeBuilder builder: () -> [XContent]) {
        builder().forEach { insertPrevious($0) }
    }
    
    public func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XContent {
        _insertNext(builder: builder)
        return self
    }
    
    func insertNext(_ node: XContent) {
        if let selfAsText = self as? XText, let newAsText = node as? XText {
            selfAsText._value = selfAsText._value + newAsText._value
            selfAsText.whitespace = .UNKNOWN
        }
        else if _parent?._lastContent === self {
            _parent?.add(node)
        }
        else {
            node.removeKeep()
            
            _next?._previous = node
            node._previous = self
            node._next = _next
            _next = node
            node._parent = _parent
            
            // set tree order:
            node.setTreeOrderWhenInserting()
            
            // set document:
            if let theDocument = _parent?._document, let element = node as? XElement, !(element._document === theDocument) {
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
    
    func _insertNext(@XNodeBuilder builder: () -> [XContent]) {
        builder().reversed().forEach { insertNext($0) }
    }
    
    public func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XContent {
        _insertNext(builder: builder)
        return self
    }
    
    /**
     Removes the node from the tree structure and the tree order and
     the document.
     If "forward", then detaching prefetches the next node in iterators.
     Else, the iterators all told to go to the previous node.
     */
    @discardableResult public func remove(forward: Bool = false) -> XContent {
        _remove(forward: forward)
        return self
    }
    
    /**
     Replace the node by other nodes.
     If "forward", then detaching prefetches the next node in iterators.
     */
    public func replace(forward: Bool = false, @XNodeBuilder builder: () -> [XContent]) {
        let placeholder = XSpot() // do not use text as a place holder!
        insertNext(placeholder)
        _remove(forward: forward)
        builder().forEach { placeholder.insertPrevious($0) }
        placeholder._remove()
    }
    
    /**
     Replace the node by another node.
     If "forward", then detaching prefetches the next node in iterators.
     */
    func replace1(forward: Bool = false, _ node: XContent) {
        if let theNext = _next {
            _remove(forward: forward)
            theNext.insertPrevious(node)
            
        }
        else if let theParent = _parent {
            _remove(forward: forward)
            theParent.add(node)
        }
    }
    
    public var asContentSequence: XContentSequence { get { return XContentSelfSequence(content: self) } }
    
}

public class XSpot: XContent {
    
    public override var r: XSpot? { get { super.r as? XSpot } }
    public override var rr: XSpot? { get { super.rr as? XSpot } }
    
    public var attached = Attachments()
    
    public override init() {
        super.init()
    }
    
    @discardableResult public override func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XSpot {
        _insertPrevious(builder: builder)
        return self
    }
    
    @discardableResult public override func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XSpot {
        _insertNext(builder: builder)
        return self
    }
    
}

public protocol XBranch: XNode {
    var firstContent: XContent? { get }
    func firstContent(where condition: (XNode) -> Bool) -> XContent?
    var lastContent: XContent? { get }
    func lastContent(where condition: (XNode) -> Bool) -> XContent?
    var isEmpty: Bool { get }
    @discardableResult func add(@XNodeBuilder builder: () -> [XContent]) -> XBranch
    @discardableResult func add(skip: Bool, @XNodeBuilder builder: () -> [XContent]) -> XBranch
    @discardableResult func addFirst(@XNodeBuilder builder: () -> [XContent]) -> XBranch
    @discardableResult func addFirst(skip: Bool, @XNodeBuilder builder: () -> [XContent]) -> XBranch
    @discardableResult func setContent(@XNodeBuilder builder: () -> [XContent]) -> XBranch
    @discardableResult func setContent(forward: Bool, @XNodeBuilder builder: () -> [XContent]) -> XBranch
    @discardableResult func clear() -> XBranch
    @discardableResult func clear(forward: Bool) -> XBranch
}

protocol XBranchInternal: XBranch {
    var _firstContent: XContent? { get set }
    var _lastContent: XContent? { get set }
    var _document: XDocument? { get set }
    //var _lastInTree: XNode! { get set }
}

extension XBranchInternal {
    
    func addClones(from source: XBranchInternal, forwardref: Bool = false) {
        source.content.forEach { node in
            if let content = node.shallowClone() as? XContent {
                add(content)
            }
        }
        allContent.forEach { node in
            if let element = node as? XElement {
                (element._r as? XBranchInternal)?.content.forEach { node in
                    if let content = node.shallowClone() as? XContent {
                        element.add(content)
                    }
                }
            }
            if forwardref {
                let source = node._r
                node._r = source?._r
                source?._r = node
            }
        }
    }
    
    public var firstContent: XContent? {
        get {
            return _firstContent
        }
    }
    
    public func firstContent(where condition: (XNode) -> Bool) -> XContent? {
        let node = _firstContent
        if let theNode = node, condition(theNode) {
            return node
        }
        else {
            return nil
        }
    }
    
    public var lastContent: XContent? {
        get {
            return _lastContent
        }
    }
    
    public func lastContent(where condition: (XNode) -> Bool) -> XContent? {
        let node = _lastContent
        if let theNode = node, condition(theNode) {
            return node
        }
        else {
            return nil
        }
    }
    
    public var isEmpty: Bool {
        get {
            return _firstContent == nil
        }
    }
    
    /**
     Clear the contents of the node.
     If "forward", then detaching prefetches the next node in iterators.
     */
    public func clear(forward: Bool) -> XBranch {
        var node = self._firstContent
        var nextNode = node?._next
        while let toRemove = node {
            toRemove._remove(forward: forward)
            node = nextNode
            nextNode = node?._next
        }
        return self
    }
    
    /**
     Clear the contents of the node.
     If "forward", then detaching prefetches the next node in iterators.
     */
    public func clear() -> XBranch {
        clear(forward: false)
        return self
    }
    
    /**
     When adding content, setting skip = true let iterators continue _after_ the
     inserted content.
     Else, the iterator will iterate through the inserted content.
     */
    func add(_ node: XContent, skip: Bool = false) {
        if let lastAsText = lastContent as? XText, let newAsText = node as? XText {
            lastAsText._value = lastAsText._value + newAsText._value
            lastAsText.whitespace = .UNKNOWN
        }
        else {
            node.removeKeep(forward: skip)
            
            // insert into new chain:
            if let theLastChild = _lastContent {
                theLastChild._next = node
                node._previous = theLastChild
            }
            else {
                _firstContent = node
                node._previous = nil
            }
            _lastContent = node
            node._next = nil
            
            // set parent:
            node._parent = self
            
            // set tree order:
            node.setTreeOrderWhenInserting()
            
            // set document:
            if _document != nil, let element = node as? XElement, !(element._document === _document) {
                element.setDocument(document: _document)
            }
        }
    }
    
    func add(_ text: String) {
        if !text.isEmpty {
            if let lastAsText = lastContent as? XText {
                lastAsText._value = lastAsText._value + text
                lastAsText.whitespace = .UNKNOWN
            }
            else {
                add(XText(text))
            }
        }
    }
    
    @discardableResult public func add(skip: Bool, @XNodeBuilder builder: () -> [XContent]) -> XBranch {
        builder().forEach { add($0, skip: skip) }
        return self
    }
    
    @discardableResult public func add(@XNodeBuilder builder: () -> [XContent]) -> XBranch {
        return add(skip: false, builder: builder)
    }
    
    /**
     When adding content, setting skip = true let iterators continue _after_ the
     inserted content.
     Else, the iterator will iterate through the inserted content.
     */
    func addFirst(_ node: XContent, skip: Bool = false) {
        if let firstAsText = firstContent as? XText, let newAsText = node as? XText {
            firstAsText._value = newAsText._value + firstAsText._value
            firstAsText.whitespace = .UNKNOWN
        }
        else {
            node.removeKeep(forward: skip)
            
            // insert into new chain:
            if let theFirstChild = _firstContent {
                theFirstChild._previous = node
                node._next = theFirstChild
            }
            else {
                _lastContent = node
                node._next = nil
            }
            _firstContent = node
            node._previous = nil
            
            // set parent:
            node._parent = self
            
            // set tree order:
            node.setTreeOrderWhenInserting()
            
            // set document:
            if _document != nil, let element = node as? XElement, !(element._document === _document) {
                element.setDocument(document: _document)
            }
        }
    }
    
    func addFirst(_ text: String) {
        if !text.isEmpty {
            if let firstAsText = firstContent as? XText {
                firstAsText._value = text + firstAsText._value
                firstAsText.whitespace = .UNKNOWN
            }
            else {
                addFirst(XText(text))
            }
        }
    }
    
    @discardableResult public func addFirst(skip: Bool, @XNodeBuilder builder: () -> [XContent]) -> XBranch {
        builder().reversed().forEach { addFirst($0, skip: skip) }
        return self
    }
    
    @discardableResult public func addFirst(@XNodeBuilder builder: () -> [XContent]) -> XBranch {
        addFirst(skip: false, builder: builder)
        return self
    }
    
    /**
     Set the contents of the branch.
     If "forward", then detaching prefetches the next node in iterators.
     */
    @discardableResult public func setContent(forward: Bool = false, @XNodeBuilder builder: () -> [XContent]) -> XBranch {
        let endMarker = XSpot()
        add(endMarker)
        builder().forEach { endMarker.insertPrevious($0) }
        endMarker.previous.forEach { $0._remove(forward: forward) }
        endMarker._remove()
        return self
    }
    
    /**
     Set the contents of the branch.
     */
    @discardableResult public func setContent(@XNodeBuilder builder: () -> [XContent]) -> XBranch {
        return setContent(forward: false, builder: builder)
    }
    
    func produceLeaving(production: XProduction) throws {
        // to be implemented by subclass
    }
}

public protocol XContentLike {}

extension XContent: XContentLike {}

extension String: XContentLike {}

extension XContentSequence: XContentLike {}
extension XElementSequence: XContentLike {}
extension XContentLikeSequence: XContentLike {}

public extension Array where Element == XContentLike? {
    var xml: XContentLikeSequence {
        get { return XContentLikeSequenceFromArray(formArray: self) }
    }
}

final class XAttribute: Named {
    
    var attributeIterators = WeakList<XBidirectionalAttributeIterator>()
    
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
    
    var nodes = [XContent]()
    
    func add(_ thing: XContentLike) {
        if let node = thing as? XContent {
            nodes.append(node)
        }
        else if let s = thing as? String {
            nodes.append(XText(s))
        }
        else if let sequence = thing as? XContentSequence {
            sequence.forEach { self.add($0) }
        }
        else if let sequence = thing as? XElementSequence {
            sequence.forEach { self.add($0) }
        }
        else if let sequence = thing as? XContentLikeSequence {
            sequence.forEach { self.add($0) }
        }
    }
}

@resultBuilder
public struct XNodeBuilder {
    public static func buildBlock(_ components: XContentLike?...) -> [XContent] {
        let sampler = XNodeSampler()
        components.forEach { if let nodeLike = $0 { sampler.add(nodeLike) } }
        return sampler.nodes
    }
}

public class Attachments {
    
    private var values: [String:Any]? = nil
    
    public func clear() {
        values = nil
    }
    
    public subscript(key: String) -> Any? {
        get {
            values?[key]
        }
        set(newValue) {
            if newValue == nil {
                values?[key] = nil
                if values?.isEmpty == true {
                    values = nil
                }
            }
            else {
                if values == nil {
                    values = [String:Any]()
                }
                values?[key] = newValue
            }
        }
    }
}

public final class XElement: XContent, XBranchInternal, CustomStringConvertible {
    
    func setDocument(document newDocument: XDocument?) {
        
        // set document:
        var node: XNode? = self
        repeat {
            if let element = node as? XElement {
                if !(newDocument === element._document) {
                    element._document?.unregisterElement(element: element)
                    element._document = newDocument
                    newDocument?.registerElement(element: element)
                }
            }
            if self._lastInTree === node {
                break
            }
            node = node?._nextInTree
        } while node != nil
    }
    
    var _firstContent: XContent?
    
    var _lastContent: XContent?
    
    var _lastInTree: XNode!
    
    override func getLastInTree() -> XNode {
        return _lastInTree
    }
    
    var _document: XDocument? = nil
    
    var _treeIterators = WeakList<XBidirectionalElementIterator>()
    var _nameIterators = WeakList<XElementNameIterator>()
    
    var _attributes: [String:XAttribute]? = nil
    var _attributeNames: [String]? = nil
    
    public override var r: XElement? { get { super.r as? XElement } }
    public override var rr: XElement? { get { super.rr as? XElement } }
    
    public var attached = Attachments()
    
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
    
    public override func clone(pointingFromClone: Bool = false) -> XElement {
        let theClone = shallowClone(forwardref: pointingFromClone)
        theClone.addClones(from: self, forwardref: pointingFromClone)
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
    
    public var asElementSequence: XElementSequence { get { return XElementSelfSequence(element: self) } }
    
    // ------------------------------------------------------------------------
    // more precisely typed versions for methods from XContent:
    
    @discardableResult public override func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XElement {
        _insertPrevious(builder: builder)
        return self
    }
    
    @discardableResult public override func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XElement {
        _insertNext(builder: builder)
        return self
    }
    
    // ------------------------------------------------------------------------
    // more precisely typed versions for methods from XBranch:
    
    @discardableResult public func add(skip: Bool = false, @XNodeBuilder builder: () -> [XContent]) -> XElement {
        _ = (self as XBranch).add(skip: skip, builder: builder)
        return self
    }
    
    @discardableResult public func addFirst(skip: Bool = false, @XNodeBuilder builder: () -> [XContent]) -> XElement {
        _ = (self as XBranch).addFirst(skip: skip, builder: builder)
        return self
    }
    
    /**
     Set the contents of the element.
     If "forward", then detaching prefetches the next node in iterators.
     */
    @discardableResult public func setContent(forward: Bool = false, @XNodeBuilder builder: () -> [XContent]) -> XElement {
        _ = (self as XBranch).setContent(forward: forward, builder: builder)
        return self
    }
    
    @discardableResult func clear(forward: Bool) -> XElement {
        _ = (self as XBranch).clear(forward: forward)
        return self
    }
    
    // ------------------------------------------------------------------------
    
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
        self._lastInTree = self
        if let theAttributes = attributes {
            setAttributes(attributes: theAttributes)
        }
    }
    
    public init(_ name: String, _ attributes: [String:String?]? = nil, adjustDocument _adjustDocument: Bool = false, @XNodeBuilder builder: () -> [XContent]) {
        self._name = name
        super.init()
        self._lastInTree = self
        if let theAttributes = attributes {
            setAttributes(attributes: theAttributes)
        }
        builder().forEach { node in
            add(node)
        }
        if _adjustDocument {
            adjustDocument()
        }
    }
    
    init(_ name: String, document: XDocument) {
        self._name = name
        super.init()
        self._document = document
    }
    
    public override func removeKeep(forward: Bool = false) {
        
        // correction in iterators:
        if forward {
            _treeIterators.forEach { $0.prefetch() }
        }
        else {
            _treeIterators.forEach { _ = $0.previous() }
        }
        
        super.removeKeep(forward: forward)
    }
    
    func setAttributes(attributes newAtttributeValues: [String:String?]? = nil) {
        if self._attributes == nil {
            self._attributes = [String:XAttribute]()
        }
        newAtttributeValues?.forEach { name, value in
            self[name] = value
        }
    }
    
    public func adjustDocument() {
        setDocument(document: _document)
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeElementStartBeforeAttributes(element: self)
        if let theAttributes = _attributes {
            try production.sortAttributeNames(attributeNames: Array(theAttributes.keys), element: self).forEach { attributeName in
                if let theAttribute = theAttributes[attributeName] {
                    try production.writeAttribute(name: theAttribute.name, value: theAttribute.value, element: self)
                }
            }
        }
        try production.writeElementStartAfterAttributes(element: self)
    }
    
    func produceLeaving(production: XProduction) throws {
        try production.writeElementEnd(element: self)
    }
}

public final class XText: XContent, CustomStringConvertible {
    
    public override var r: XText? { get { super.r as? XText } }
    public override var rr: XText? { get { super.rr as? XText } }
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set (newText) {
            if newText.isEmpty {
                self._remove()
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
    
    @discardableResult public override func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XText {
        _insertPrevious(builder: builder)
        return self
    }
    
    @discardableResult public override func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XText {
        _insertNext(builder: builder)
        return self
    }
    
    public override func produceEntering(production: XProduction) throws {
        try production.writeText(text: self)
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
    
    public override func clone(pointingFromClone: Bool = false) -> XText {
        return shallowClone(forwardref: pointingFromClone)
    }
}

public final class XInternalEntity: XContent {
    
    public override var r: XInternalEntity? { get { super.r as? XInternalEntity } }
    public override var rr: XInternalEntity? { get { super.rr as? XInternalEntity } }
    
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
    
    @discardableResult public override func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XInternalEntity {
        _insertPrevious(builder: builder)
        return self
    }
    
    @discardableResult public override func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XInternalEntity {
        _insertNext(builder: builder)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeInternalEntity(internalEntity: self)
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
    
    public override func clone(pointingFromClone: Bool = false) -> XInternalEntity {
        return shallowClone(forwardref: pointingFromClone)
    }
}

public final class XExternalEntity: XContent {
    
    public override var r: XExternalEntity? { get { super.r as? XExternalEntity } }
    public override var rr: XExternalEntity? { get { super.rr as? XExternalEntity } }
    
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
    
    @discardableResult public override func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XExternalEntity {
        _insertPrevious(builder: builder)
        return self
    }
    
    @discardableResult public override func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XExternalEntity {
        _insertNext(builder: builder)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeExternalEntity(externalEntity: self)
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
    
    public override func clone(pointingFromClone: Bool = false) -> XExternalEntity {
        return shallowClone(forwardref: pointingFromClone)
    }
}

public final class XProcessingInstruction: XContent, CustomStringConvertible {
    
    public override var r: XProcessingInstruction? { get { super.r as? XProcessingInstruction } }
    public override var rr: XProcessingInstruction? { get { super.rr as? XProcessingInstruction } }
    
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
    
    @discardableResult public override func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XProcessingInstruction {
        _insertPrevious(builder: builder)
        return self
    }
    
    @discardableResult public override func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XProcessingInstruction {
        _insertNext(builder: builder)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeProcessingInstruction(processingInstruction: self)
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
    
    public override func clone(pointingFromClone: Bool = false) -> XProcessingInstruction {
        return shallowClone(forwardref: pointingFromClone)
    }
}

public final class XComment: XContent {
    
    public override var r: XComment? { get { super.r as? XComment } }
    public override var rr: XComment? { get { super.rr as? XComment } }
    
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
    
    @discardableResult public override func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XComment {
        _insertPrevious(builder: builder)
        return self
    }
    
    @discardableResult public override func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XComment {
        _insertNext(builder: builder)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeComment(comment: self)
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
    
    public override func clone(pointingFromClone: Bool = false) -> XComment {
        return shallowClone(forwardref: pointingFromClone)
    }
}

public final class XCDATASection: XContent {
    
    public override var r: XCDATASection? { get { super.r as? XCDATASection } }
    public override var rr: XCDATASection? { get { super.rr as? XCDATASection } }
    
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
    
    @discardableResult public override func insertPrevious(@XNodeBuilder builder: () -> [XContent]) -> XCDATASection {
        _insertPrevious(builder: builder)
        return self
    }
    
    @discardableResult public override func insertNext(@XNodeBuilder builder: () -> [XContent]) -> XCDATASection {
        _insertNext(builder: builder)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeCDATASection(cdataSection: self)
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
    
    public override func clone(pointingFromClone: Bool = false) -> XCDATASection {
        return shallowClone(forwardref: pointingFromClone)
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
    
    func produceEntering(production: XProduction) throws {}
    
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
    
    override func produceEntering(production: XProduction) throws {
        try production.writeInternalEntityDeclaration(internalEntityDeclaration: self)
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
    
    override func produceEntering(production: XProduction) throws {
        try production.writeExternalEntityDeclaration(externalEntityDeclaration: self)
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
    
    override func produceEntering(production: XProduction) throws {
        try production.writeUnparsedEntityDeclaration(unparsedEntityDeclaration: self)
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
    
    override func produceEntering(production: XProduction) throws {
        try production.writeNotationDeclaration(notationDeclaration: self)
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
    
    override func produceEntering(production: XProduction) throws {
        try production.writeElementDeclaration(elementDeclaration: self)
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
    
    override func produceEntering(production: XProduction) throws {
        try production.writeAttributeListDeclaration(attributeListDeclaration: self)
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
    
    override func produceEntering(production: XProduction) throws {
        try production.writeParameterEntityDeclaration(parameterEntityDeclaration: self)
    }
    
    public override func shallowClone() -> XParameterEntityDeclaration {
        return XParameterEntityDeclaration(name: _name, value: _value)
    }
}
