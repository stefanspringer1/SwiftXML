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
    weak var _backLink: XNode? = nil
    
    public var backLink: XNode? {
        get {
            return _backLink
        }
    }
    
    public func backLink(_ condition: (XNode) -> Bool) -> XNode? {
        let node = _backLink
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
    public var ultimateBackLink: XNode? {
        get {
            var ref = _backLink
            while let further = ref?._backLink {
                ref = further
            }
            return ref
        }
    }
    
    public func ultimateBackLink(_ condition: (XNode) -> Bool) -> XNode? {
        let node = ultimateBackLink
        if let theNode = node, condition(theNode) {
            return node
        }
        else {
            return nil
        }
    }
    
    public var backLinkPath: [XNode]? {
        get {
            var ref = _backLink
            if let theRef = ref {
                var path = [XNode]()
                path.append(theRef)
                while let further = ref?._backLink {
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
     Make a shallow clone (without content).
     */
    public func shallowClone() -> XNode {
        let theClone = XNode()
        theClone._backLink = self
        return theClone
    }
    
    public func clone() -> XNode {
        return shallowClone()
    }
    
    var _contentIterators = WeakList<XBidirectionalContentIterator>()
    
    func addContentIterator(_ nodeIterator: XBidirectionalContentIterator) {
        _contentIterators.append(nodeIterator)
    }
    
    func removeContentIterator(_ nodeIterator: XBidirectionalContentIterator) {
        _contentIterators.remove(nodeIterator)
    }
    
    weak var _parent: XBranchInternal? = nil
    
    public var parent: XElement? {
        get {
            return _parent as? XElement
        }
    }
    
    public func parent(_ condition: (XElement) -> Bool) -> XElement? {
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
    
    public var previousTouching: XContent? { get { _previous } }
    public var nextTouching: XContent? { get { _next } }
    
    public func previousTouching(_ condition: (XContent) -> Bool) -> XContent? {
        let content = _previous
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    public func nextTouching(_ condition: (XContent) -> Bool) -> XContent? {
        let content = _next
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    weak var _previousInTree: XNode? = nil
    weak var _nextInTree: XNode? = nil
    
    public var previousInTreeTouching: XContent? { get { _previousInTree as? XContent } }
    public var nextInTreeTouching: XContent? { get { _nextInTree as? XContent } }
    
    public func previousInTreeTouching(_ condition: (XContent) -> Bool) -> XContent? {
        let content = previousInTreeTouching
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    public func nextInTreeTouching(_ condition: (XContent) -> Bool) -> XContent? {
        let content = nextInTreeTouching
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
    
    public var lastInTree: XNode { get { getLastInTree() } }
    
    public func applying(_ f: (XNode) -> ()) -> XNode {
        f(self)
        return self
    }
    
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
    
    public func echo(usingProduction production: XProduction, terminator: String = "\n") {
        do {
            try write(toFileHandle: FileHandle.standardOutput, production: production); print(terminator, terminator: "")
        }
        catch {
            // writing to standard output does not really throw
        }
    }
    
    public func echo(pretty: Bool = false, terminator: String = "\n") {
        echo(usingProduction: pretty ? XPrettyPrintProduction() : XDefaultProduction(), terminator: terminator)
    }
    
    public func serialized(usingProduction production: XProduction) -> String {
        let writer = CollectingWriter()
        do {
            try write(toWriter: writer, production: production)
        }
        catch {
            // CollectingWriter does not really throw
        }
        return writer.description
    }
    
    public func serialized(pretty: Bool = false) -> String {
        serialized(usingProduction: pretty ? XPrettyPrintProduction() : XDefaultProduction())
    }
}

public class XContent: XNode {
    
    public override func clone() -> XContent {
        _ = super.clone()
        return self
    }
    
    public override func shallowClone() -> XContent {
        _ = super.shallowClone()
        return self
    }
    
    /**
     Correct the tree order after this node has been inserted.
     */
    func setTreeOrderWhenInserting() {
        
        let lastInMyTree = getLastInTree()
        
        // set _previousInTree & _nextInTree for "self" tree:
        self._previousInTree = _previous?.getLastInTree() ?? _parent
        lastInMyTree._nextInTree = self._previousInTree?._nextInTree // let it be nil for the last node in the document!
        
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
    
    func gotoPreviousOnContentIterators() {
        _contentIterators.forEach { _ = $0.previous() }
    }
    
    func prefetchOnContentIterators() {
        _contentIterators.forEach { $0.prefetch() }
    }
    
    /**
     Removes the node from the tree structure and the tree order,
     but keeps it in the document.
     */
    func _removeKeep() {
        
        // correction in iterators:
        gotoPreviousOnContentIterators()
        
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
     */
    public func remove() {
        _removeKeep()
        if let meAsElement = self as? XElement {
            meAsElement.document?.unregisterElement(element: meAsElement)
        }
    }
    
    public override var previousInTreeTouching: XContent? { get { _previousInTree as? XContent } }
    public override var nextInTreeTouching: XContent? { get { _nextInTree as? XContent } }
    
    public override var lastInTree: XContent { get { getLastInTree() as! XContent } }
    
    func _insertPrevious(_ node: XContent) {
        if let selfAsText = self as? XText, let newAsText = node as? XText {
            selfAsText._value = newAsText._value + selfAsText._value
            selfAsText.whitespace = .UNKNOWN
        }
        else if let selfAsLiteral = self as? XLiteral, let newAsLiteral = node as? XLiteral {
            selfAsLiteral._value = newAsLiteral._value + selfAsLiteral._value
        }
        else {
            node._removeKeep()
            
            if _parent?._firstContent === self {
                _parent?._firstContent = node
            }
            
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
    
    func _insertPrevious(_ text: String) {
        if !text.isEmpty {
            if let selfAsText = self as? XText {
                selfAsText._value = text + selfAsText._value
                selfAsText.whitespace = .UNKNOWN
            }
            else {
                _insertPrevious(XText(text))
            }
        }
    }
    
    func _insertPrevious(keepPosition: Bool, _ content: [XContent]) {
        if !keepPosition {
            prefetchOnContentIterators()
        }
        content.forEach { _insertPrevious($0) }
    }
    
    public func insertPrevious(keepPosition: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        _insertPrevious(keepPosition: keepPosition, builder())
    }
    
    func _insertNext(_ node: XContent) {
        if let selfAsText = self as? XText, let newAsText = node as? XText {
            selfAsText._value = selfAsText._value + newAsText._value
            selfAsText.whitespace = .UNKNOWN
        }
        else if let selfAsLiteral = self as? XLiteral, let newAsLiteral = node as? XLiteral {
            selfAsLiteral._value = selfAsLiteral._value + newAsLiteral._value
        }
        else if _parent?._lastContent === self {
            _parent?._add(node)
        }
        else {
            node._removeKeep()
            
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
    
    func _insertNext(_ text: String) {
        if !text.isEmpty {
            if let selfAsText = self as? XText {
                selfAsText._value = selfAsText._value + text
                selfAsText.whitespace = .UNKNOWN
            }
            else {
                _insertNext(XText(text))
            }
        }
    }
    
    func _insertNext(keepPosition: Bool, _ content: [XContent]) {
        if !keepPosition {
            prefetchOnContentIterators()
        }
        content.reversed().forEach { _insertNext($0) }
    }
    
    public func insertNext(keepPosition: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        _insertNext(keepPosition: keepPosition, builder())
    }
    
    /**
     Replace the node by other nodes.
     */
    func _replace(follow: Bool, by content: [XContent]) {
        if follow {
            gotoPreviousOnContentIterators()
        }
        else {
            prefetchOnContentIterators()
        }
        let placeholder = XSpot() // do not use text as a place holder!
        _insertNext(placeholder)
        remove()
        content.forEach { placeholder._insertPrevious($0) }
        placeholder.remove()
    }
    
    /**
     Replace the node by other nodes.
     */
    public func replace(follow: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        _replace(follow: follow, by: builder())
    }
    
    public var asSequence: XContentSequence { get { XContentSelfSequence(content: self) } }
    
}

public extension String {
    var asSequence: XContentSequence { get { XText(self).asSequence } }
}

public class XSpot: XContent {
    
    public override var backLink: XSpot? { get { super.backLink as? XSpot } }
    public override var ultimateBackLink: XSpot? { get { super.ultimateBackLink as? XSpot } }
    
    public var attached = Attachments()
    
    public init(attached: [String:Any?]? = nil) {
        super.init()
        attached?.forEach{ (key,value) in self.attached[key] = value }
    }
    
}

public protocol XBranch: XNode {
    var firstContent: XContent? { get }
    func firstContent(_ condition: (XContent) -> Bool) -> XContent?
    var lastContent: XContent? { get }
    func lastContent(_ condition: (XContent) -> Bool) -> XContent?
    var isEmpty: Bool { get }
    func add(@XContentBuilder builder: () -> [XContent])
    func addFirst(@XContentBuilder builder: () -> [XContent])
    func setContent(@XContentBuilder builder: () -> [XContent])
    func clear()
}

protocol XBranchInternal: XBranch {
    var _firstContent: XContent? { get set }
    var _lastContent: XContent? { get set }
    var _document: XDocument? { get set }
    //var _lastInTree: XNode! { get set }
}

extension XBranchInternal {
    
    /**
     I am the clone, add the content!
     */
    func _addClones(from source: XBranchInternal, pointingToClone: Bool = false) {
        source.content.forEach { node in
            // we need a reference from the clone to the origin first:
            _add(node.shallowClone())
        }
        allContent.forEach { node in
            if let element = node as? XElement {
                // using the reference to the origin here:
                (element._backLink as? XElement)?.content.forEach { node in
                    element._add(node.shallowClone())
                }
            }
            // change the reference if desired differently:
            if pointingToClone {
                let source = node._backLink
                node._backLink = source?._backLink
                source?._backLink = node
            }
        }
    }
    
    public var firstContent: XContent? {
        get { _firstContent }
    }
    
    public func _firstContent(_ condition: (XContent) -> Bool) -> XContent? {
        let node = _firstContent
        if let theNode = node, condition(theNode) {
            return node
        }
        else {
            return nil
        }
    }
    
    public func firstContent(_ condition: (XContent) -> Bool) -> XContent? {
        return _firstContent(condition)
    }
    
    public var lastContent: XContent? {
        get { _lastContent }
    }
    
    public func _lastContent(_ condition: (XContent) -> Bool) -> XContent? {
        let node = _lastContent
        if let theNode = node, condition(theNode) {
            return node
        }
        else {
            return nil
        }
    }
    
    public func lastContent(_ condition: (XContent) -> Bool) -> XContent? {
        return _lastContent(condition)
    }
    
    public var isEmpty: Bool {
        get {
            return _firstContent == nil
        }
    }
    
    /**
     Clear the contents of the node.
     */
    public func _clear() {
        var node = _firstContent
        while let theNode = node {
            theNode.remove()
            node = theNode._next
        }
    }
    
    /**
     Clear the contents of the node.
     */
    public func clear() {
        _clear()
    }
    
    /**
     Add content as last content.
     */
    func _add(_ node: XContent) {
        if let lastAsText = lastContent as? XText, let newAsText = node as? XText {
            lastAsText._value = lastAsText._value + newAsText._value
            lastAsText.whitespace = .UNKNOWN
        }
        else if let lastAsLiteral = lastContent as? XLiteral, let newAsLiteral = node as? XLiteral {
            lastAsLiteral._value = lastAsLiteral._value + newAsLiteral._value
        }
        else {
            node._removeKeep()
            
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
    
    func _add(_ text: String) {
        if !text.isEmpty {
            if let lastAsText = lastContent as? XText {
                lastAsText._value = lastAsText._value + text
                lastAsText.whitespace = .UNKNOWN
            }
            else {
                _add(XText(text))
            }
        }
    }
    
    func _add(_ content: [XContent]) {
        content.forEach { _add($0) }
    }
    
    public func add(@XContentBuilder builder: () -> [XContent]) {
        return _add(builder())
    }
    
    /**
     Add content as first content.
     */
    func _addFirst(_ node: XContent) {
        if let firstAsText = firstContent as? XText, let newAsText = node as? XText {
            firstAsText._value = newAsText._value + firstAsText._value
            firstAsText.whitespace = .UNKNOWN
        }
        else if let firstAsLiteral = firstContent as? XLiteral, let newAsLiteral = node as? XLiteral {
            firstAsLiteral._value = newAsLiteral._value + firstAsLiteral._value
        }
        else {
            node._removeKeep()
            
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
    
    func _addFirst(_ text: String) {
        if !text.isEmpty {
            if let firstAsText = firstContent as? XText {
                firstAsText._value = text + firstAsText._value
                firstAsText.whitespace = .UNKNOWN
            }
            else {
                _addFirst(XText(text))
            }
        }
    }
    
    func _addFirst(_ content: [XContent]) {
        content.reversed().forEach { _addFirst($0) }
    }
    
    public func addFirst(@XContentBuilder builder: () -> [XContent]) {
        _addFirst(builder())
    }
    
    /**
     Set the contents of the branch.
     */
    func _setContent(_ content: [XContent]) {
        let endMarker = XSpot()
        _addFirst(endMarker)
        content.forEach { endMarker._insertPrevious($0) }
        endMarker.next.forEach { $0.remove() }
        endMarker.remove()
    }
    
    /**
     Set the contents of the branch.
     */
    public func setContent(@XContentBuilder builder: () -> [XContent]) {
        _setContent(builder())
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
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XElement {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XElement? {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XText {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XText? {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XInternalEntity {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XInternalEntity? {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XExternalEntity {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XExternalEntity? {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XCDATASection {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XCDATASection? {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XProcessingInstruction {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XProcessingInstruction? {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XComment {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XComment? {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XSpot {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension Array where Element == XSpot? {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromArray(fromArray: self) }
    }
}

public extension LazyFilterSequence where Base == XElementSequence {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromLazyElementFilterSequence(fromSequence: self) }
    }
}

public extension LazyFilterSequence where Base == XContentSequence {
    var asContent: XContentLikeSequence {
        get { XContentLikeSequenceFromLazyContentFilterSequence(fromSequence: self) }
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
public struct XContentBuilder {
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
    
    var _elementIterators = WeakList<XBidirectionalElementIterator>()
    var _nameIterators = WeakList<XElementNameIterator>()
    
    func gotoPreviousOnElementIterators() {
        _elementIterators.forEach { _ = $0.previous() }
    }
    
    func prefetchOnElementIterators() {
        _elementIterators.forEach { $0.prefetch() }
    }
    
    var _attributes: [String:XAttribute]? = nil
    var _attributeNames: [String]? = nil
    
    public override var backLink: XElement? { get { super.backLink as? XElement } }
    public override var ultimateBackLink: XElement? { get { super.ultimateBackLink as? XElement } }
    
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
    
    public override func shallowClone() -> XElement {
        let theClone = XElement(name)
        theClone._backLink = self
        theClone.copyAttributes(from: self)
        return theClone
    }
    
    public override func clone() -> XElement {
        let theClone = shallowClone()
        theClone._addClones(from: self)
        return theClone
    }
    
    public override func applying(_ f: (XElement) -> ()) -> XElement {
        f(self)
        return self
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
    
    public var asElementSequence: XElementSequence { get { XElementSelfSequence(element: self) } }
    
    override func _insertPrevious(keepPosition: Bool, _ content: [XContent]) {
        if !keepPosition {
            prefetchOnElementIterators()
        }
        super._insertPrevious(keepPosition: keepPosition, content)
    }
    
    override func _insertNext(keepPosition: Bool, _ content: [XContent]) {
        if !keepPosition {
            prefetchOnElementIterators()
        }
        super._insertNext(keepPosition: keepPosition, content)
    }
    
    /**
     Replace the node by other nodes.
     */
    override func _replace(follow: Bool, by content: [XContent]) {
        if follow {
            gotoPreviousOnElementIterators()
        }
        else {
            prefetchOnElementIterators()
        }
        super._replace(follow: follow, by: content)
    }
    
    // ------------------------------------------------------------------------
    // repeat methods from XBranchInternal:
    
    public var firstContent: XContent? {
        get { _firstContent }
    }
    
    public func firstContent(_ condition: (XContent) -> Bool) -> XContent? {
        return _firstContent(condition)
    }
    
    public var lastContent: XContent? {
        get { _lastContent }
    }
    
    public func lastContent(_ condition: (XContent) -> Bool) -> XContent? {
        return _lastContent(condition)
    }
    
    public var isEmpty: Bool {
        get { _firstContent == nil }
    }
    
    public func add(@XContentBuilder builder: () -> [XContent]) {
        return _add(builder())
    }
    
    public func addFirst(@XContentBuilder builder: () -> [XContent]) {
        return _addFirst(builder())
    }
    
    public func setContent(@XContentBuilder builder: () -> [XContent]) {
        return _setContent(builder())
    }
    
    public func clear() {
        return _clear()
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
    
    public init(_ name: String, _ attributes: [String:String?]? = nil, attached: [String:Any?]? = nil) {
        self._name = name
        super.init()
        self._lastInTree = self
        if let theAttributes = attributes {
            setAttributes(attributes: theAttributes)
        }
        attached?.forEach{ (key,value) in self.attached[key] = value }
    }
    
    public convenience init(_ name: String, _ attributes: [String:String?]? = nil, attached: [String:Any?]? = nil, adjustDocument _adjustDocument: Bool = false, @XContentBuilder builder: () -> [XContent]) {
        self.init(name, attributes, attached: attached)
        builder().forEach { node in
            _add(node)
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
    
    public override func _removeKeep() {
        
        // correction in iterators:
        _elementIterators.forEach { _ = $0.previous() }
        
        super._removeKeep()
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
    
    public override var backLink: XText? { get { super.backLink as? XText } }
    public override var ultimateBackLink: XText? { get { super.ultimateBackLink as? XText } }
    
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
    
    public override func applying(_ f: (XText) -> ()) -> XText {
        f(self)
        return self
    }
    
    public override func produceEntering(production: XProduction) throws {
        try production.writeText(text: self)
    }
    
    public override func shallowClone() -> XText {
        let theClone = XText(_value, whitespace: whitespace)
        theClone._backLink = self
        return theClone
    }
    
    public override func clone() -> XText {
        return shallowClone()
    }
}

/*
 `XLiteral` has a text value that is meant to be serialized "as is" without XML-escaping.
 */
public final class XLiteral: XContent, CustomStringConvertible {
    
    public override var backLink: XLiteral? { get { super.backLink as? XLiteral } }
    public override var ultimateBackLink: XLiteral? { get { super.ultimateBackLink as? XLiteral } }
    
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
            }
        }
    }
    
    public var description: String {
        get {
            _value
        }
    }
    
    public init(_ text: String) {
        self._value = text
    }
    
    public override func applying(_ f: (XLiteral) -> ()) -> XLiteral {
        f(self)
        return self
    }
    
    public override func produceEntering(production: XProduction) throws {
        try production.writeLiteral(literal: self)
    }
    
    public override func shallowClone() -> XLiteral {
        let theClone = XLiteral(_value)
        theClone._backLink = self
        return theClone
    }
    
    public override func clone() -> XLiteral {
        return shallowClone()
    }
}

public final class XInternalEntity: XContent {
    
    public override var backLink: XInternalEntity? { get { super.backLink as? XInternalEntity } }
    public override var ultimateBackLink: XInternalEntity? { get { super.ultimateBackLink as? XInternalEntity } }
    
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
    
    public override func applying(_ f: (XInternalEntity) -> ()) -> XInternalEntity {
        f(self)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeInternalEntity(internalEntity: self)
    }
    
    public override func shallowClone() -> XInternalEntity {
        let theClone = XInternalEntity(_name)
        theClone._backLink = self
        return theClone
    }
    
    public override func clone() -> XInternalEntity {
        return shallowClone()
    }
}

public final class XExternalEntity: XContent {
    
    public override var backLink: XExternalEntity? { get { super.backLink as? XExternalEntity } }
    public override var ultimateBackLink: XExternalEntity? { get { super.ultimateBackLink as? XExternalEntity } }
    
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
    
    public override func applying(_ f: (XExternalEntity) -> ()) -> XExternalEntity {
        f(self)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeExternalEntity(externalEntity: self)
    }
    
    public override func shallowClone() -> XExternalEntity {
        let theClone = XExternalEntity(_name)
        theClone._backLink = self
        return theClone
    }
    
    public override func clone() -> XExternalEntity {
        return shallowClone()
    }
}

public final class XProcessingInstruction: XContent, CustomStringConvertible {
    
    public override var backLink: XProcessingInstruction? { get { super.backLink as? XProcessingInstruction } }
    public override var ultimateBackLink: XProcessingInstruction? { get { super.ultimateBackLink as? XProcessingInstruction } }
    
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
    
    public override func applying(_ f: (XProcessingInstruction) -> ()) -> XProcessingInstruction {
        f(self)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeProcessingInstruction(processingInstruction: self)
    }
    
    public override func shallowClone() -> XProcessingInstruction {
        let theClone = XProcessingInstruction(target: _target, data: _data)
        theClone._backLink = self
        return theClone
    }
    
    public override func clone() -> XProcessingInstruction {
        return shallowClone()
    }
}

public final class XComment: XContent {
    
    public override var backLink: XComment? { get { super.backLink as? XComment } }
    public override var ultimateBackLink: XComment? { get { super.ultimateBackLink as? XComment } }
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set(newText) {
            _value = newText
        }
    }
    
    init(_ text: String) {
        self._value = text
    }
    
    public override func applying(_ f: (XComment) -> ()) -> XComment {
        f(self)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeComment(comment: self)
    }
    
    public override func shallowClone() -> XComment {
        let theClone = XComment(_value)
        theClone._backLink = self
        return theClone
    }
    
    public override func clone() -> XComment {
        return shallowClone()
    }
}

public final class XCDATASection: XContent {
    
    public override var backLink: XCDATASection? { get { super.backLink as? XCDATASection } }
    public override var ultimateBackLink: XCDATASection? { get { super.ultimateBackLink as? XCDATASection } }
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set(newText) {
            _value = newText
        }
    }
    
    init(_ text: String) {
        self._value = text
    }
    
    public override func applying(_ f: (XCDATASection) -> ()) -> XCDATASection {
        f(self)
        return self
    }
    
    override func produceEntering(production: XProduction) throws {
        try production.writeCDATASection(cdataSection: self)
    }
    
    public override func shallowClone() -> XCDATASection {
        let theClone = XCDATASection(_value)
        theClone._backLink = self
        return theClone
    }
    
    public override func clone() -> XCDATASection {
        return shallowClone()
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
