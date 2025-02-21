//===--- Nodes.swift ------------------------------------------------------===//
//
// This source file is part of the SwiftXML.org open source project
//
// Copyright (c) 2021-2023 Stefan Springer (https://stefanspringer.com)
// and the SwiftXML project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
//===----------------------------------------------------------------------===//

import Foundation
import SwiftXMLInterfaces
import SwiftXMLParser

public enum WriteTarget {
    case url(_: URL); case path(_: String); case file(_: FileHandle); case writer(_: Writer)
}

/// Use this function to announce that certain content (denoted by an array array of `XContent`)
/// is being moved inside the `action` closure.
///
/// The content will then first be prepared for being moved, and at the end this preparation
/// will be repealed.
///
/// Actually, only for content conforming to protocol `ToBePeparedForMoving` such a preparation
/// and the according repeal will be done by calling the according members of the protocol.
func moving(_ content: [XContent], action: () -> ()) {
    for node in content { (node as? ToBePeparedForMoving)?.prepareForMove() }
    action()
    for node in content { (node as? ToBePeparedForMoving)?.resetAfterMove() }
}

/// The insertion mode determines if when insertion content into the tree,
/// should an iteration at an appropriate place also iterate through this
/// inserted content or should it be skipped instead.
public enum InsertionMode { case skipping; case following }

/// This is the general kind of thing that can occur as the content in the body of an XML document.
/// (The body of an XML document is everything except the XML declaration and the XML document
/// declaration with the optional internal subset.
public class XNode {
    
    /// Return the first ancestor with a certain name if it exists.
    public func ancestor(_ name: String) -> XElement? {
        var element = parent
        while let theElement = element {
            if theElement.name == name {
                return theElement
            }
            element = theElement.parent
        }
        return nil
    }
    
    /// Return the first ancestor with a certain name if it exists.
    public func ancestor(_ names: [String]) -> XElement? {
        var element = parent
        while let theElement = element {
            if names.contains(theElement.name) {
                return theElement
            }
            element = theElement.parent
        }
        return nil
    }
    
    public var top: XElement? {
        guard var element = parent else { return nil }
        while let nextParent = element.parent {
            element = nextParent
        }
        return element
    }
    
    /// Return the first ancestor with a certain name if it exists.
    public func ancestor(_ names: String...) -> XElement? {
        ancestor(names)
    }
    
    /// Every node can have attachments (of any type).
    public var attached = [String:Any]()
    
    var _sourceRange: XTextRange? = nil
    
    /// For every node its range in the source text can be noted.
    public var sourceRange: XTextRange? { _sourceRange }
    
    weak var _backlink: XNode? = nil
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public var backlink: XNode? { _backlink }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public var backlinkOrSelf: XNode { _backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XNode) -> XNode {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XNode) -> XNode {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public var finalBacklink: XNode? {
        get {
            var ref = _backlink
            while let further = ref?._backlink {
                ref = further
            }
            return ref
        }
    }
    
    /// Follows the ´backlink´ property and finally returns an array of the according nodes.
    public var backlinkPath: [XNode]? {
        get {
            var ref = _backlink
            if let theRef = ref {
                var path = [XNode]()
                path.append(theRef)
                while let further = ref?._backlink {
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
    
    /// Return the document that the node belongs to if it exists.
    public weak var document: XDocument? {
        get {
            return (self as? XBranchInternal)?._document ?? self._parent?._document
        }
    }
    
    /// Make a shallow clone (without content).
    public var shallowClone: XNode {
        let theClone = XNode()
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        return theClone
    }
    
    /// Make a full clone, i.e. including clones of the content (in the same tree order), recursively.
    public var clone: XNode {
        return shallowClone
    }
    
    private var contentIterators = WeakList<XBidirectionalContentIterator>()
    
    /// Register a content iterator which have this node as the current position.
    ///
    /// This will be called for the found node when `previous`, `next`, or `prefetch` is called on the iterator.
    func addContentIterator(_ nodeIterator: XBidirectionalContentIterator) {
        contentIterators.append(nodeIterator)
    }
    
    /// Deregister a content iterator, because its current position will not be this node after some operation.
    ///
    /// This will be called for this node when `previous`, `next`, or `prefetch` is called on the iterator.
    func removeContentIterator(_ nodeIterator: XBidirectionalContentIterator) {
        contentIterators.remove(nodeIterator)
    }
    
    /// Go to previous on all registered content operators, because this node will not be at same position after some operation.
    func gotoPreviousOnContentIterators() {
        for content in contentIterators { _ = content.previous() }
    }
    
    func prefetchOnContentIterators() {
        for content in contentIterators { content.prefetch() }
    }
    
    weak var _parent: XBranchInternal? = nil
    
    // Get the parent of the node.
    public weak var parent: XElement? {
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
    
    public func parent(_ names: [String]) -> XElement? {
        let element = parent
        if let theElement = element, names.contains(theElement.name) {
            return theElement
        }
        else {
            return nil
        }
    }
    
    public func parent(_ names: String...) -> XElement? {
        parent(names)
    }
    
    weak var _previous: XContent? = nil
    var _next: XContent? = nil
    
    public var hasPrevious: Bool { previousTouching != nil }
    public var hasNext: Bool { nextTouching != nil }
    
    public var previousTouching: XContent? {
        get {
            var content = _previous
            while let spot = content as? _Isolator_ {
                content = spot._previous
            }
            return content
        }
    }
    
    public var nextTouching: XContent? {
        get {
            var content = _next
            while let spot = content as? _Isolator_ {
                content = spot._next
            }
            return content
        }
    }
    
    public var previousElement: XElement? {
        get {
            var content = _previous
            while let theContent = content, !(theContent is XElement) {
                content = theContent._previous
            }
            return content as? XElement
        }
    }
    
    public var hasPreviousElement: Bool {
        previousElement != nil
    }
    
    public var nextElement: XElement? {
        get {
            var content = _next
            while let theContent = content, !(theContent is XElement) {
                content = theContent._next
            }
            return content as? XElement
        }
    }
    
    public var hasNextElement: Bool {
        nextElement != nil
    }
    
    public func previousTouching(_ condition: (XContent) -> Bool) -> XContent? {
        let content = previousTouching
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    public func hasPreviousTouching(_ condition: (XContent) -> Bool) -> Bool {
        previousTouching(condition) != nil
    }
    
    public func nextTouching(_ condition: (XContent) -> Bool) -> XContent? {
        let content = nextTouching
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    public func hasNextTouching(_ condition: (XContent) -> Bool) -> Bool {
        nextTouching(condition) != nil
    }
    
    weak var _previousInTree: XNode? = nil
    weak var _nextInTree: XNode? = nil
    
    public var previousInTree: XContent? {
        get {
            var content = _previousInTree
            while let spot = content as? _Isolator_ {
                content = spot._previousInTree
            }
            return content as? XContent
        }
    }
    
    public var hasPreviousInTree: Bool {
        previousInTree != nil
    }
    
    public var nextInTree: XContent? {
        get {
            var content = _nextInTree
            while let spot = content as? _Isolator_ {
                content = spot._nextInTree
            }
            return content as? XContent
        }
    }
    
    public var hasNextInTree: Bool {
        nextInTree != nil
    }
    
    public func previousInTreeTouching(_ condition: (XContent) -> Bool) -> XContent? {
        let content = previousInTree
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    public func hasPreviousInTreeTouching(_ condition: (XContent) -> Bool) -> Bool {
        previousInTreeTouching(condition) != nil
    }
    
    public func nextInTreeTouching(_ condition: (XContent) -> Bool) -> XContent? {
        let content = nextInTree
        if let theContent = content, condition(theContent) {
            return theContent
        }
        else {
            return nil
        }
    }
    
    public func hasNextInTreeTouching(_ condition: (XContent) -> Bool) -> Bool {
        nextInTreeTouching(condition) != nil
    }
    
    func getLastInTree() -> XNode {
        return self
    }
    
    public var lastInTree: XNode { get { getLastInTree() } }
    
    public func traverse(down: (XNode) throws -> (), up: ((XNode) throws -> ())? = nil) rethrows {
        let directionIndicator = XDirectionIndicator()
        for  node in XTraversalSequence(node: self, directionIndicator: directionIndicator) {
            switch directionIndicator.direction {
            case .down:
                try down(node)
            case .up:
                if let branch = node as? XBranchInternal {
                    try up?(branch)
                }
            }
        }
    }
    
    public func traverse(down: (XNode) async throws -> (), up: ((XNode) async throws -> ())? = nil) async rethrows {
        let directionIndicator = XDirectionIndicator()
        for node in XTraversalSequence(node: self, directionIndicator: directionIndicator) {
            switch directionIndicator.direction {
            case .down:
                try await down(node)
            case .up:
                if let branch = node as? XBranchInternal {
                    try await up?(branch)
                }
            }
        }
    }
    
    func produceEntering(activeProduction: XActiveProduction) throws {
        // to be implemented by subclass
    }
    
    public func applyProduction(activeProduction: XActiveProduction) throws {
        try (self as? XDocument)?.produceEntering(activeProduction: activeProduction)
        try traverse { node in
            try node.produceEntering(activeProduction: activeProduction)
        } up: { branch in
            if let element = branch as? XElement {
                try element.produceLeaving(activeProduction: activeProduction)
            }
            else if let document = branch as? XDocument {
                try document.produceLeaving(activeProduction: activeProduction)
            }
        }
        try (self as? XDocument)?.produceLeaving(activeProduction: activeProduction)
    }
    
    public func write(toWriter writer: Writer, usingProductionTemplate productionTemplate: XProductionTemplate = DefaultProductionTemplate()) throws {
        let activeProduction = productionTemplate.activeProduction(for: writer, atNode: self)
        try self.applyProduction(activeProduction: activeProduction)
    }
    
    public func write(toFile fileHandle: FileHandle, usingProductionTemplate productionTemplate: XProductionTemplate = DefaultProductionTemplate()) throws {
        try write(toWriter: FileWriter(fileHandle), usingProductionTemplate: productionTemplate)
    }
    
    public func write(toPath path: String, usingProductionTemplate productionTemplate: XProductionTemplate = DefaultProductionTemplate()) throws {
        let fileManager = FileManager.default
        
        fileManager.createFile(atPath: path,  contents:Data("".utf8), attributes: nil)
        
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            try write(toFile: fileHandle, usingProductionTemplate: productionTemplate)
            fileHandle.closeFile()
        }
        else {
            print("ERROR: cannot write to [\(path)]");
        }
        
    }
    
    public func write(toURL url: URL, usingProductionTemplate productionTemplate: XProductionTemplate = DefaultProductionTemplate()) throws {
        try write(toPath: url.path, usingProductionTemplate: productionTemplate)
    }
    
    public func write(to writeTarget: WriteTarget, usingProductionTemplate productionTemplate: XProductionTemplate = DefaultProductionTemplate()) throws {
        switch writeTarget {case .url(let url):
            try write(toURL: url, usingProductionTemplate: productionTemplate)
        case .path(let path):
            try write(toPath: path, usingProductionTemplate: productionTemplate)
        case .file(let fileHandle):
            try write(toFile: fileHandle, usingProductionTemplate: productionTemplate)
        case .writer(let writer):
            try write(toWriter: writer, usingProductionTemplate: productionTemplate)
        }
    }
    
    public func echo(usingProductionTemplate productionTemplate: XProductionTemplate, terminator: String = "\n") {
        do {
            try write(toFile: FileHandle.standardOutput, usingProductionTemplate: productionTemplate); print(terminator, terminator: "")
        }
        catch {
            // writing to standard output does not really throw
        }
    }
    
    public func echo(pretty: Bool = false, indentation: String = X_DEFAULT_INDENTATION, terminator: String = "\n") {
        echo(usingProductionTemplate: pretty ? PrettyPrintProductionTemplate(indentation: indentation) : DefaultProductionTemplate(), terminator: terminator)
    }
    
    public func serialized(usingProductionTemplate productionTemplate: XProductionTemplate) -> String {
        let writer = CollectingWriter()
        do {
            try write(toWriter: writer, usingProductionTemplate: productionTemplate)
        }
        catch {
            // CollectingWriter does not really throw
        }
        return writer.description
    }
    
    public func serialized(pretty: Bool = false, indentation: String = X_DEFAULT_INDENTATION) -> String {
        serialized(usingProductionTemplate: pretty ? PrettyPrintProductionTemplate(indentation: indentation) : DefaultProductionTemplate())
    }
    
    public var immediateTextsCombined: String {
        immediateTexts.map{ $0.value }.joined()
    }
    
    public var allTextsCombined: String {
        if let meAsText = self as? XText {
            return meAsText.value
        } else if let meAsBranch = self as? XBranch {
            if let text = meAsBranch.firstContent as? XText, text._next == nil {
                return text.value
            }
            var texts = [String]()
            meAsBranch.traverse { node in
                if let text = node as? XText {
                    texts.append(text.value)
                }
            }
            return texts.joined()
        } else {
            return ""
        }
    }
    
    public var description: String { String(describing: self) }

}

public class XContent: XNode {
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XContent? { super.backlink as? XContent }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XContent { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XContent) -> XContent {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XContent) -> XContent {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XContent? { super.finalBacklink as? XContent }
    
    public override var clone: XContent {
        _ = super.clone
        return self
    }
    
    public override var shallowClone: XContent {
        _ = super.shallowClone
        return self
    }
    
    public func removed() -> XNode {
        remove()
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
        if self === _parent?.__lastContent, let oldParentLastInTree = _parent?.lastInTree {
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
     */
    func _removeKeep() {
        
        let oldPrevious = _previous
        let oldNext = _next
        
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
            if theParent.__firstContent === self {
                theParent.__firstContent = _next
            }
            if theParent.__lastContent === self {
                theParent.__lastContent = _previous
            }
        }
        
        _next = nil
        _previous = nil
        _parent = nil
        
        if let thePreviousText = oldPrevious as? XText, let theNextText = oldNext as? XText, !(thePreviousText.isolated || theNextText.isolated) {
            thePreviousText.value += theNextText.value
            thePreviousText._whitespace = thePreviousText._whitespace + theNextText._whitespace
            theNextText.value = ""
        } else if let thePreviousLiteral = oldPrevious as? XLiteral, let theNextLiteral = oldNext as? XLiteral, !(thePreviousLiteral.isolated || theNextLiteral.isolated) {
            thePreviousLiteral.value += theNextLiteral.value
            theNextLiteral.value = ""
        }
    }
    
    /**
     Removes the content from the tree structure and the tree order and
     the document.
     */
    public func remove() {
        _removeKeep()
        if let meAsElement = self as? XElement {
            //meAsElement.gotoPreviousOnNameIterators()
            meAsElement.document?.unregisterElement(element: meAsElement)
            for descendant in meAsElement.descendants {
                //descendant.gotoPreviousOnNameIterators()
                descendant.document?.unregisterElement(element: descendant)
            }
        }
    }
    
    public override var previousInTree: XContent? { get { _previousInTree as? XContent } }
    public override var nextInTree: XContent? { get { _nextInTree as? XContent } }
    
    public override var lastInTree: XContent { get { getLastInTree() as! XContent } }
    
    func _insertPrevious(_ node: XContent) {
        
        func _insertPreviousBase(_ node: XContent) {
            node._removeKeep()
            
            if _parent?.__firstContent === self {
                _parent?.__firstContent = node
            }
            
            _previous?._next = node
            node._previous = _previous
            node._next = self
            _previous = node
            node._parent = _parent
            
            // set tree order:
            node.setTreeOrderWhenInserting()
            
            // set document:
            let document = document
            if let element = node as? XElement, !(element._document === document) {
                for insertedElement in element.descendantsIncludingSelf {
                    insertedElement.setDocument(document: document)
                }
            }
        }
        
        if let newAsText = node as? XText {
            guard !newAsText.value.isEmpty else { return }
            if !newAsText.isolated {
                if let selfAsText = self as? XText, !selfAsText.isolated {
                    selfAsText._value = newAsText._value + selfAsText._value
                    selfAsText._whitespace = newAsText._whitespace + selfAsText._whitespace
                    newAsText.value = ""
                    return
                }
                if let previousAsText = _previous as? XText, !previousAsText.isolated {
                    previousAsText._value = previousAsText._value + newAsText._value
                    previousAsText._whitespace = previousAsText._whitespace + newAsText._whitespace
                    newAsText.value = ""
                    return
                }
            }
        }
        
        if let newAsLiteral = node as? XLiteral {
            guard !newAsLiteral.value.isEmpty else { return }
            if !newAsLiteral.isolated {
                if let selfAsLiteral = self as? XLiteral, !selfAsLiteral.isolated {
                    selfAsLiteral._value = newAsLiteral._value + selfAsLiteral._value
                    newAsLiteral.value = ""
                    return
                }
                if let previousAsLiteral = _previous as? XLiteral, !previousAsLiteral.isolated {
                    previousAsLiteral._value = previousAsLiteral._value + newAsLiteral._value
                    newAsLiteral.value = ""
                    return
                }
            }
        }
        
        _insertPreviousBase(node)
    }
    
    func _insertPrevious(_ text: String) {
        if !text.isEmpty {
            if let selfAsText = self as? XText, !selfAsText.isolated {
                selfAsText._value = text + selfAsText._value
                selfAsText._whitespace = .UNKNOWN
            } else if let previousAsText = _previous as? XText, !previousAsText.isolated {
                previousAsText._value = previousAsText._value + text
                previousAsText._whitespace = .UNKNOWN
            } else {
                _insertPrevious(XText(text))
            }
        }
    }
    
    func _insertPrevious(_ insertionMode: InsertionMode, _ content: [XContent]) {
        if insertionMode == .skipping {
            prefetchOnContentIterators()
        }
        let isolator = _Isolator_(inDocument: self.document)
        _insertPrevious(isolator)
        moving(content) {
            for node in content { isolator._insertPrevious(node) }
        }
        isolator.remove()
    }
    
    public func insertPrevious(_ insertionMode: InsertionMode = .following, @XContentBuilder builder: () -> [XContent]) {
        _insertPrevious(insertionMode, builder())
    }
    
    func _insertNext(_ node: XContent) {
        
        func _insertNextBase(_ node: XContent) {
            node._removeKeep()
            
            if _parent?.__lastContent === self {
                _parent?.__lastContent = node
            }
            
            _next?._previous = node
            node._previous = self
            node._next = _next
            _next = node
            node._parent = _parent
            
            // set tree order:
            node.setTreeOrderWhenInserting()
            
            // set document:
            let document = document
            if let element = node as? XElement, !(element._document === document) {
                for insertedElement in element.descendantsIncludingSelf {
                    insertedElement.setDocument(document: document)
                }
            }
        }
        
        if let newAsText = node as? XText {
            guard !newAsText.value.isEmpty else { return }
            if !newAsText.isolated {
                if let selfAsText = self as? XText, !selfAsText.isolated {
                    selfAsText._value = selfAsText._value + newAsText._value
                    selfAsText._whitespace = selfAsText._whitespace + newAsText._whitespace
                    newAsText.value = ""
                    return
                }
                if let nextAsText = _next as? XText, !nextAsText.isolated {
                    nextAsText._value = newAsText._value + nextAsText._value
                    nextAsText._whitespace = newAsText._whitespace + nextAsText._whitespace
                    newAsText.value = ""
                    return
                }
            }
        }
        
        if let newAsLiteral = node as? XLiteral {
            guard !newAsLiteral.value.isEmpty else { return }
            if !newAsLiteral.isolated {
                if let selfAsLiteral = self as? XLiteral, !selfAsLiteral.isolated {
                    selfAsLiteral._value = selfAsLiteral._value + newAsLiteral._value
                    newAsLiteral.value = ""
                    return
                }
                if let nextAsLiteral = _next as? XLiteral, !nextAsLiteral.isolated {
                    nextAsLiteral._value = newAsLiteral._value + nextAsLiteral._value
                    newAsLiteral.value = ""
                    return
                }
            }
        }
        
        _insertNextBase(node)
    }
    
    func _insertNext(_ text: String) {
        if !text.isEmpty {
            if let selfAsText = self as? XText, !selfAsText.isolated {
                selfAsText._value = selfAsText._value + text
                selfAsText._whitespace = .UNKNOWN
            } else if let nextAsText = self as? XText, !nextAsText.isolated {
                nextAsText._value = text + nextAsText._value
                nextAsText._whitespace = .UNKNOWN
            } else {
                _insertNext(XText(text))
            }
        }
    }
    
    func _insertNext(_ insertionMode: InsertionMode, _ content: [XContent]) {
        if insertionMode == .skipping {
            prefetchOnContentIterators()
        }
        let isolator = _Isolator_(inDocument: self.document)
        _insertNext(isolator)
        moving(content) {
            for node in content { isolator._insertPrevious(node) }
        }
        isolator.remove()
    }
    
    public func insertNext(_ insertionMode: InsertionMode = .following, @XContentBuilder builder: () -> [XContent]) {
        _insertNext(insertionMode, builder())
    }
    
    /**
     Replace the node by other nodes.
     */
    private func _replace(insertionMode: InsertionMode, content: [XContent], previousIsolator: _Isolator_) {
        if insertionMode == .following {
            gotoPreviousOnContentIterators()
        }
        else {
            prefetchOnContentIterators()
        }
        moving(content) {
            for node in content { previousIsolator._insertPrevious(node) }
        }
        if previousIsolator._next === self {
            remove()
        }
        previousIsolator.remove()
    }
    
    public func replace(_ insertionMode: InsertionMode = .following, _ content: [XContent]) {
        let isolator = _Isolator_(inDocument: self.document)
        _insertPrevious(isolator)
        _replace(insertionMode: insertionMode, content: content, previousIsolator: isolator)
    }
    
    public func replace(_ insertionMode: InsertionMode = .following, @XContentBuilder builder: () -> [XContent]) {
        let isolator = _Isolator_(inDocument: self.document)
        _insertPrevious(isolator)
        _replace(insertionMode: insertionMode, content: builder(), previousIsolator: isolator)
    }
    
    public var asSequence: XContentSequence { get { XContentSelfSequence(content: self) } }

}

public extension String {
    var asSequence: XContentSequence { get { XText(self).asSequence } }
}

final class _Isolator_: XContent {
    
    private let _document: XDocument?
    
    public override var document: XDocument? {
        _document
    }
    
    init(inDocument document: XDocument?) {
        _document = document
    }
}

public protocol XBranch: XNode {
    var firstContent: XContent? { get }
    func firstContent(_ condition: (XContent) -> Bool) -> XContent?
    var lastContent: XContent? { get }
    func lastContent(_ condition: (XContent) -> Bool) -> XContent?
    var firstChild: XElement? { get }
    func firstChild(_ name: String) -> XElement?
    func firstChild(_ names: [String]) -> XElement?
    func firstChild(_ names: String...) -> XElement?
    func firstChild(_ condition: (XElement) -> Bool) -> XElement?
    var isEmpty: Bool { get }
    func add(@XContentBuilder builder: () -> [XContent])
    func addFirst(@XContentBuilder builder: () -> [XContent])
    func setContent(@XContentBuilder builder: () -> [XContent])
    func clear()
    func trimWhiteSpace()
    var xPath: String { get }
}

protocol XBranchInternal: XBranch {
    var __firstContent: XContent? { get set }
    var __lastContent: XContent? { get set }
    var _document: XDocument? { get set }
    //var _lastInTree: XNode! { get set }
}

extension XBranchInternal {
    
    public var _firstChild: XElement? {
        var node = __firstContent
        while let theNode = node {
            if let child = theNode as? XElement {
                return child
            }
            node = theNode._next
        }
        return nil
    }
    
    public func _firstChild(_ name: String) -> XElement? {
        var node = __firstContent
        while let theNode = node {
            if let child = theNode as? XElement, child.name == name {
                return child
            }
            node = theNode._next
        }
        return nil
    }
    
    public func _firstChild(_ names: [String]) -> XElement? {
        var node = __firstContent
        while let theNode = node {
            if let child = theNode as? XElement, names.contains(child.name) {
                return child
            }
            node = theNode._next
        }
        return nil
    }
    
    public func _firstChild(_ names: String...) -> XElement? {
        firstChild(names)
    }
    
    public func _firstChild(_ condition: (XElement) -> Bool) -> XElement? {
        var node = __firstContent
        while let theNode = node {
            if let child = theNode as? XElement, condition(child) {
                return child
            }
            node = theNode._next
        }
        return nil
    }
    
    /**
     I am the clone, add the content!
     */
    func _addClones(from source: XBranchInternal, pointingToClone: Bool = false) {
        for node in source.content {
            // we need a reference from the clone to the origin first:
            _add(node.shallowClone)
        }
        for node in allContent {
            if let element = node as? XElement {
                // using the reference to the origin here:
                if let backlink = element._backlink as? XElement {
                    for node in backlink.content {
                        element._add(node.shallowClone)
                    }
                }
            }
            // change the reference if desired differently:
            if pointingToClone {
                let source = node._backlink
                node._backlink = source?._backlink
                source?._backlink = node
            }
        }
    }
    
    var _firstContent: XContent? {
        get {
            var content = __firstContent
            while let spot = content as? _Isolator_ {
                content = spot._next
            }
            return content
        }
    }
    
    public var firstContent: XContent? { _firstContent }
    
    func _firstContent(_ condition: (XContent) -> Bool) -> XContent? {
        let node = firstContent
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
    
    var _lastContent: XContent? {
        get {
            var content = __lastContent
            while let spot = content as? _Isolator_ {
                content = spot._previous
            }
            return content
        }
    }
    
    public var lastContent: XContent? { _lastContent }
    
    func _lastContent(_ condition: (XContent) -> Bool) -> XContent? {
        let node = lastContent
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
    
    public var singleContent: XContent? { _singleContent }
    
    public var _singleContent: XContent? {
        if let firstContent, firstContent.nextTouching == nil {
            return firstContent
        } else {
            return nil
        }
    }
    
    var _isEmpty: Bool { _firstContent == nil }
    
    public var isEmpty: Bool { _isEmpty }
    
    /**
     Clear the contents of the node.
     */
    public func _clear() {
        var node = __firstContent
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
        
        if let newAsText = node as? XText {
            guard !newAsText.value.isEmpty else { return }
            if let lastAsText = lastContent as? XText, !(lastAsText.isolated || newAsText.isolated) {
                lastAsText._value = lastAsText._value + newAsText._value
                lastAsText._whitespace = lastAsText._whitespace + newAsText._whitespace
                newAsText.value = ""
                return
            }
        }
        
        if let newAsLiteral = node as? XLiteral {
            guard !newAsLiteral.value.isEmpty else { return }
            if let lastAsLiteral = lastContent as? XLiteral, !(lastAsLiteral.isolated || newAsLiteral.isolated) {
                lastAsLiteral._value = lastAsLiteral._value + newAsLiteral._value
                newAsLiteral.value = ""
                return
            }
        }
        
        node._removeKeep()

        // insert into new chain:
        if let theLastChild = __lastContent {
            theLastChild._next = node
            node._previous = theLastChild
        }
        else {
            __firstContent = node
            node._previous = nil
        }
        __lastContent = node
        node._next = nil

        // set parent:
        node._parent = self

        // set tree order:
        node.setTreeOrderWhenInserting()

        // set document:
        if _document != nil, let element = node as? XElement, !(element._document === _document) {
            for insertedElement in element.descendantsIncludingSelf {
                insertedElement.setDocument(document: _document)
            }
        }
    }
    
    func _add(_ text: String) {
        if !text.isEmpty {
            if let lastAsText = lastContent as? XText {
                lastAsText._value = lastAsText._value + text
                lastAsText._whitespace = .UNKNOWN
            }
            else {
                _add(XText(text))
            }
        }
    }
    
    func _add(_ content: [XContent]) {
        moving(content) {
            for node in content { _add(node) }
        }
    }
    
    public func add(@XContentBuilder builder: () -> [XContent]) {
        return _add(builder())
    }
    
    /**
     Add content as first content.
     */
    func _addFirst(_ node: XContent) {
        
        if let newAsText = node as? XText {
            guard !newAsText.value.isEmpty else { return }
            if let firstAsText = firstContent as? XText, !(firstAsText.isolated || newAsText.isolated) {
                firstAsText._value = newAsText._value + firstAsText._value
                firstAsText._whitespace = newAsText._whitespace + firstAsText._whitespace
                newAsText.value = ""
                return
            }
        }
        
        if let newAsLiteral = node as? XLiteral {
            guard !newAsLiteral.value.isEmpty else { return }
            if let firstAsLiteral = firstContent as? XLiteral, !(firstAsLiteral.isolated || newAsLiteral.isolated) {
                firstAsLiteral._value = newAsLiteral._value + firstAsLiteral._value
                newAsLiteral.value = ""
                return
            }
        }
        
        node._removeKeep()

        // insert into new chain:
        if let theFirstChild = __firstContent {
            theFirstChild._previous = node
            node._next = theFirstChild
        }
        else {
            __lastContent = node
            node._next = nil
        }
        __firstContent = node
        node._previous = nil

        // set parent:
        node._parent = self

        // set tree order:
        node.setTreeOrderWhenInserting()
        
        // set document:
        if _document != nil, let element = node as? XElement, !(element._document === _document) {
            for insertedElement in element.descendantsIncludingSelf {
                insertedElement.setDocument(document: _document)
            }
        }
    }
    
    func _addFirst(_ text: String) {
        if !text.isEmpty {
            if let firstAsText = firstContent as? XText {
                firstAsText._value = text + firstAsText._value
                firstAsText._whitespace = .UNKNOWN
            }
            else {
                _addFirst(XText(text))
            }
        }
    }
    
    func _addFirst(_ content: [XContent]) {
        moving(content) {
            for node in content.reversed() { _addFirst(node) }
        }
    }
    
    public func addFirst(@XContentBuilder builder: () -> [XContent]) {
        _addFirst(builder())
    }
    
    /**
     Set the contents of the branch.
     */
    func _setContent(_ content: [XContent]) {
        let isolator = _Isolator_(inDocument: self.document)
        _addFirst(isolator)
        moving(content) {
            for node in content { isolator._insertPrevious(node) }
        }
        for node in isolator.next { node.remove() }
        isolator.remove()
    }
    
    /**
     Set the contents of the branch.
     */
    public func setContent(@XContentBuilder builder: () -> [XContent]) {
        _setContent(builder())
    }
    
    func produceLeaving(activeProduction: XActiveProduction) throws {
        // to be implemented by subclass
    }
    
    func _trimWhiteSpace() {
        self.traverse { node in
            if let text = node as? XText {
                text.value = text.value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
}

public protocol XTextualContentRepresentation {
    var value: String { get set }
}

final class AttributeProperties {
    
    private var attributeIterators = WeakList<XBidirectionalAttributeIterator>()
    
    func addAttributeIterator(_ attributeIterator: XBidirectionalAttributeIterator) {
        attributeIterators.append(attributeIterator)
    }
    
    func removeAttributeIterator(_ attributeIterator: XBidirectionalAttributeIterator) {
        attributeIterators.remove(attributeIterator)
    }
    
    func gotoPreviousOnAttributeIterators() {
        attributeIterators.forEach { _ = $0.previous() }
    }
    
    func prefetchOnAttributeIterators() {
        attributeIterators.forEach { $0.prefetch() }
    }
    
    var value: String
    weak var element: XElement?
    
    weak var previousWithSameName: AttributeProperties? = nil
    var nextWithSameName: AttributeProperties? = nil
    
    init(value: String, element: XElement) {
        self.value = value
        self.element = element
    }
    
    // prevent stack overflow when destroying the list of elements with same name,
    // to be applied on the first element in that list,
    // cf. https://forums.swift.org/t/deep-recursion-in-deinit-should-not-happen/54987
    // !!! This should not be necessary anymore with Swift 5.7 or on masOS 13. !!!
    func removeFollowingWithSameName() {
        var node = self
        while isKnownUniquelyReferenced(&node.nextWithSameName) {
            (node, node.nextWithSameName) = (node.nextWithSameName!, nil)
        }
    }
}

public struct XMLCollector {
    
    private var contents = [XContent]()
    
    public var collected: [XContent] { contents }
    
    mutating public func collect(_ content: XContent) {
        contents.append(content)
    }
}

public protocol XContentConvertible {
    func collectXML(by xmlCollector: inout XMLCollector)
}

public extension XContentConvertible {
    var xml: [XContent] {
        var xmlCollector = XMLCollector()
        self.collectXML(by: &xmlCollector)
        return xmlCollector.collected
    }
}

extension XContent: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        xmlCollector.collect(self)
    }
}

extension String: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        xmlCollector.collect(XText(self))
    }
}

extension String.SubSequence: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        xmlCollector.collect(XText(String(self)))
    }
}

extension Int: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        xmlCollector.collect(XText(String(self)))
    }
}

extension XContentSequence: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            xmlCollector.collect(content)
        }
    }
}

extension XContentConvertibleSequence: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            content.collectXML(by: &xmlCollector)
        }
    }
}

extension XElementSequence: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            xmlCollector.collect(content)
        }
    }
}

extension XTextSequence: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            xmlCollector.collect(content)
        }
    }
}

extension LazyMapSequence<XContentSequence, XContentConvertible>: XContentConvertible {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            content.collectXML(by: &xmlCollector)
        }
    }
}

extension Sequence<XContentConvertible> {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            content.collectXML(by: &xmlCollector)
        }
    }
}

extension LazyFilterSequence: XContentConvertible where Base.Element == XElement {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            content.collectXML(by: &xmlCollector)
        }
    }
}

extension LazyDropWhileSequence: XContentConvertible where Base.Element == XElement {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            content.collectXML(by: &xmlCollector)
        }
    }
}

extension Array: XContentConvertible where Element == XContent {
    public func collectXML(by xmlCollector: inout XMLCollector) {
        for content in self {
            content.collectXML(by: &xmlCollector)
        }
    }
}

@resultBuilder
public struct XContentBuilder {
    
    // empty:
    public static func buildBlock() -> [XContent] {
        return [XContent]()
    }
    
    public static func buildBlock(_ components: XContentConvertible?...) -> [XContent] {
        var xmlCollector = XMLCollector()
        for component in components{ if let component { component.collectXML(by: &xmlCollector) } }
        return xmlCollector.collected
    }
    
    public static func buildBlock(_ sequences: any Sequence<XContentConvertible>...) -> [XContent] {
        var xmlCollector = XMLCollector()
        for sequence in sequences {
            for content in sequence {
                content.collectXML(by: &xmlCollector)
            }
        }
        return xmlCollector.collected
    }
    
    public static func buildExpression(_ expression: XContentConvertible) -> [XContent] {
        var xmlCollector = XMLCollector()
        expression.collectXML(by: &xmlCollector)
        return xmlCollector.collected
    }
    
    public static func buildExpression(_ expression: XContentConvertible?) -> [XContent] {
        if let expression {
            return buildExpression(expression)
        } else {
            return [XContent]()
        }
    }
    
    public static func buildExpression(_ array: [XContentConvertible]) -> [XContent] {
        var xmlCollector = XMLCollector()
        for item in array {
            item.collectXML(by: &xmlCollector)
        }
        return xmlCollector.collected
    }
    
    public static func buildExpression(_ array: [XContentConvertible?]) -> [XContent] {
        var xmlCollector = XMLCollector()
        for item in array {
            if let item {
                item.collectXML(by: &xmlCollector)
            }
        }
        return xmlCollector.collected
    }
    
    public static func buildEither(first component: [XContent]) -> [XContent] {
        component
    }
    
    public static func buildEither(second component: [XContent]) -> [XContent] {
        component
    }
    
    public static func buildOptional(_ component: [XContent]?) -> [XContent]? {
        component
    }
    
}

public final class XElement: XContent, XBranchInternal, CustomStringConvertible {

    public var firstChild: XElement? { _firstChild }
    
    public func firstChild(_ name: String) -> XElement? {
        _firstChild(name)
    }
    
    public func firstChild(_ names: [String]) -> XElement? {
        _firstChild(names)
    }
    
    public func firstChild(_ names: String...) -> XElement? {
        _firstChild(names)
    }
    
    public func firstChild(_ condition: (XElement) -> Bool) -> XElement? {
        _firstChild(condition)
    }

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
    
    var __firstContent: XContent?
    
    var __lastContent: XContent?
    
    weak var _lastInTree: XNode!
    
    override func getLastInTree() -> XNode {
        return _lastInTree
    }
    
    public override var top: XElement {
        super.top ?? self
    }
    
    weak var _document: XDocument? = nil
    
    private var elementIterators = WeakList<XBidirectionalElementIterator>()
    
    func addElementIterator(_ elementIterator: XBidirectionalElementIterator) {
        elementIterators.append(elementIterator)
    }
    
    func removeElementIterator(_ elementIterator: XBidirectionalElementIterator) {
        elementIterators.remove(elementIterator)
    }

    func gotoPreviousOnElementIterators() {
        for node in elementIterators { _ = node.previous() }
    }

    func prefetchOnElementIterators() {
        for node in elementIterators { node.prefetch() }
    }
    
    private var nameIterators = WeakList<XXBidirectionalElementNameIterator>()
    
    func addNameIterator(_ elementIterator: XXBidirectionalElementNameIterator) {
        nameIterators.append(elementIterator)
    }
    
    func removeNameIterator(_ elementIterator: XXBidirectionalElementNameIterator) {
        nameIterators.remove(elementIterator)
    }
    
    func gotoPreviousOnNameIterators() {
        for node in nameIterators { _ = node.previous() }
    }
    
    func prefetchOnNameIterators() {
        for node in nameIterators { node.prefetch() }
    }
    
    var _attributes = [String:String]() // contains all attributes, including the registered ones
    var _registeredAttributes = [String:AttributeProperties]() // the registered attributes
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XElement? { super.backlink as? XElement }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XElement { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XElement) -> XElement {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XElement) -> XElement {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XElement? { super.finalBacklink as? XElement }

    public override var description: String {
        get {
            """
            <\(name)\(_attributes.isEmpty == false ? " " : "")\(_attributes.sorted{ $0.0.caseInsensitiveCompare($1.0) == .orderedAscending }.map { (attributeName,attributeValue) in "\(attributeName)=\"\(attributeValue.escapingDoubleQuotedValueForXML)\"" }.joined(separator: " ") ?? "")>
            """
        }
    }
    
    public func copyAttributes(from other: XElement) {
        for (attributeName,attributeValue) in other._attributes {
            self[attributeName] = attributeValue
        }
    }
    
    public override var shallowClone: XElement {
        let theClone = XElement(name)
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        theClone.copyAttributes(from: self)
        return theClone
    }
    
    public override var clone: XElement {
        let theClone = shallowClone
        theClone._addClones(from: self)
        return theClone
    }
    
    public override func removed() -> XElement {
        remove()
        return self
    }
    
    var _name: String
    
    public var name: String {
        get { _name }
        set(newName) {
            if newName != _name {
                if let theDocument = _document {
                    gotoPreviousOnNameIterators()
                    for nameIterator in nameIterators { _ = nameIterator.previous() }
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
    
    public func hasEqualValues(as other: XElement) -> Bool {
        return self.name == other.name
        && self._attributes.keys.allSatisfy { self[$0] == other[$0] }
            && other._attributes.keys.allSatisfy { self[$0] != nil }
    }
    
    public var xPath: String {
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
    
    public var attributeNames: [String] {
        get {
            return _attributes.keys.sorted{ $0.caseInsensitiveCompare($1) == .orderedAscending }
        }
    }
    
    weak var previousWithSameName: XElement? = nil
    var nextWithSameName: XElement? = nil
    
    public var asElementSequence: XElementSequence { get { XElementSelfSequence(element: self) } }
    
    override func _insertPrevious(_ insertionMode: InsertionMode, _ content: [XContent]) {
        if insertionMode == .skipping {
            prefetchOnElementIterators()
        }
        super._insertPrevious(insertionMode, content)
    }
    
    override func _insertNext(_ insertionMode: InsertionMode, _ content: [XContent]) {
        if insertionMode == .skipping {
            prefetchOnElementIterators()
        }
        super._insertNext(insertionMode, content)
    }
    
    /**
     Replace the node by other nodes.
     */
    public override func replace(_ insertionMode: InsertionMode = .following, @XContentBuilder builder: () -> [XContent]) {
        if insertionMode == .following {
            gotoPreviousOnElementIterators()
        }
        else {
            prefetchOnElementIterators()
        }
        super.replace(insertionMode, builder: builder)
    }
    
    // ------------------------------------------------------------------------
    // repeat methods from XBranchInternal:
    
    public var firstContent: XContent? { _firstContent }
    
    public func firstContent(_ condition: (XContent) -> Bool) -> XContent? {
        return _firstContent(condition)
    }
    
    public var lastContent: XContent? { _lastContent }
    
    public func lastContent(_ condition: (XContent) -> Bool) -> XContent? {
        return _lastContent(condition)
    }
    
    public var singleContent: XContent? { _singleContent }
    
    public var isEmpty: Bool { _isEmpty }
    
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
    // !!! This should not be necessary anymore with Swift 5.7 or on masOS 13. !!!
    func removeFollowingWithSameName() {
        var node = self
        while isKnownUniquelyReferenced(&node.nextWithSameName) {
            (node, node.nextWithSameName) = (node.nextWithSameName!, nil)
        }
    }
    
    public subscript(attributeName: String) -> String? {
        get {
            _attributes[attributeName]
        }
        set {
            _attributes[attributeName] = newValue
            if let theDocument = _document, theDocument.attributeToBeRegistered(withName: attributeName) {
                if let newValue {
                    if let existingAttribute = _registeredAttributes[attributeName] {
                        existingAttribute.value = newValue
                    }
                    else {
                        let newAttribute = AttributeProperties(value: newValue, element: self)
                        _registeredAttributes[attributeName] = newAttribute
                        theDocument.registerAttribute(attributeProperties: newAttribute, withName: attributeName)
                    }
                }
                else if let existingAttribute = _registeredAttributes.removeValue(forKey: attributeName) {
                    _registeredAttributes[attributeName] = nil
                    theDocument.unregisterAttribute(attributeProperties: existingAttribute, withName: attributeName)
                }
            }
        }
    }
    
    public func pullAttribute(_ name: String) -> String? {
        if let value = self[name] {
            self[name] = nil
            return value
        } else {
            return nil
        }
    }

    public init(
        _ name: String,
        _ attributes: [String:String?]? = nil,
        withBackLinkFrom backlinkSource: XElement? = nil,
        attached: [String:Any?]? = nil
    ) {
        self._name = name
        super.init()
        self._lastInTree = self
        if let theAttributes = attributes {
            setAttributes(attributes: theAttributes)
        }
        if let attached {
            for (key,value) in attached {
                if let value {
                    self.attached[key] =  value
                }
            }
        }
        if let backlinkSource {
            self._backlink = backlinkSource._backlink
        }
    }
    
    public convenience init(
        _ name: String,
        _ attributes: [String:String?]? = nil,
        withBackLinkFrom backlinkSource: XElement? = nil,
        attached: [String:Any?]? = nil,
        adjustDocument _adjustDocument: Bool = false,
        @XContentBuilder builder: () -> [XContent]
    ) {
        self.init(name, attributes, withBackLinkFrom: backlinkSource, attached: attached)
        self.add(builder: builder)
        if _adjustDocument {
            adjustDocument()
        }
    }
    
    init(_ name: String, document: XDocument) {
        self._name = name
        super.init()
        setDocument(document: _document)
    }
    
    public override func _removeKeep() {

        // correction in iterators:
        gotoPreviousOnElementIterators()

        super._removeKeep()
    }
    
    func setAttributes(attributes newAtttributeValues: [String:String?]? = nil) {
        if let newAtttributeValues {
            for (name, value) in newAtttributeValues {
                self[name] = value
            }
        }
    }
    
    public func adjustDocument() {
        setDocument(document: _document)
    }
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeElementStartBeforeAttributes(element: self)
        for attributeName in activeProduction.sortAttributeNames(attributeNames: attributeNames, element: self) {
            try activeProduction.writeAttribute(name: attributeName, value: self[attributeName]!, element: self)
        }
        try activeProduction.writeElementStartAfterAttributes(element: self)
    }
    
    func produceLeaving(activeProduction: XActiveProduction) throws {
        try activeProduction.writeElementEnd(element: self)
    }
    
    public func trimWhiteSpace() {
        self._trimWhiteSpace()
    }
    
    public func trimmimgWhiteSpace() -> XElement {
        self._trimWhiteSpace()
        return self
    }
}

protocol ToBePeparedForMoving {
    func prepareForMove()
    func resetAfterMove()
}

public final class XText: XContent, XTextualContentRepresentation, ToBePeparedForMoving, CustomStringConvertible, ExpressibleByStringLiteral {

    public static func fromOptional(_ text: String?) -> XText? {
        if let text { return XText(text) } else { return nil }
    }
    
    var _textIterators = WeakList<XBidirectionalTextIterator>()
    
    func gotoPreviousOnTextIterators() {
        for textIterator in _textIterators { _ = textIterator.previous() }
    }
    
    func prefetchOnTextIterators() {
        for textIterator in _textIterators { textIterator.prefetch() }
    }
    
    func addTextIterator(_ textIterator: XBidirectionalTextIterator) {
        _textIterators.append(textIterator)
    }
    
    func removeTextIterator(_ textIterator: XBidirectionalTextIterator) {
        _textIterators.remove(textIterator)
    }
    
    public override func _removeKeep() {
        
        // correction in iterators:
        for textIterator in _textIterators { _ = textIterator.previous() }
        
        super._removeKeep()
    }
    
    override func _insertPrevious(_ insertionMode: InsertionMode, _ content: [XContent]) {
        if insertionMode == .skipping {
            prefetchOnTextIterators()
        }
        super._insertPrevious(insertionMode, content)
    }
    
    override func _insertNext(_ insertionMode: InsertionMode, _ content: [XContent]) {
        if insertionMode == .skipping {
            prefetchOnTextIterators()
        }
        super._insertNext(insertionMode, content)
    }
    
    public override func replace(_ insertionMode: InsertionMode = .following, @XContentBuilder builder: () -> [XContent]) {
        if insertionMode == .following {
            gotoPreviousOnTextIterators()
        }
        else {
            prefetchOnTextIterators()
        }
        super.replace(insertionMode, builder: builder)
    }
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XText? { super.backlink as? XText }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XText { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XText) -> XText {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XText) -> XText {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XText? { super.finalBacklink as? XText }
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set (newText) {
            _value = newText
            _whitespace = .UNKNOWN
            if newText.isEmpty {
                self.remove()
            }
        }
    }
    
    public override var description: String {
        get {
            "\"\(_value)\""
        }
    }
    
    var _isolated: Bool = false
    var _moving: Bool = false
    
    func prepareForMove() {
        _moving = true
    }
    
    func resetAfterMove() {
        _moving = false
        if !_isolated {
            intendCombiningWithNeighbours()
        }
    }
    
    func intendCombiningWithNeighbours() {
        if let previous = _previous as? XText, !previous.isolated {
            _value = previous._value + _value
            previous.value = ""
        }
        if let next = _next as? XText, !next.isolated {
            _value = _value + next._value
            next.value = ""
        }
    }
    
    public var isolated: Bool {
        get {
            return _moving || _isolated
        }
        set (newIsolatedValue) {
            if _isolated && newIsolatedValue == false {
                intendCombiningWithNeighbours()
            }
            _isolated = newIsolatedValue
        }
    }
    
    var _whitespace: WhitespaceIndicator
    
    public var whitespace: WhitespaceIndicator { _whitespace }
    
    public init(_ text: String, isolated: Bool = false, whitespace: WhitespaceIndicator = .UNKNOWN) {
        _value = text
        _isolated = isolated
        _whitespace = whitespace
    }
    
    public init (stringLiteral text: String) {
        _value = text
        _isolated = false
        _whitespace = .UNKNOWN
    }
    
    public var isWhitespace: Bool {
        if _whitespace == .UNKNOWN {
            if _value.contains(regex: #"^\s+$"#) {
                _whitespace = .WHITESPACE
            }
            else {
                _whitespace = .NOT_WHITESPACE
            }
        }
        return _whitespace == .WHITESPACE
    }
    
    public func trim() {
        self.value = self.value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func trimming() -> XText {
        self.value = self.value.trimmingCharacters(in: .whitespacesAndNewlines)
        return self
    }
    
    public override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeText(text: self)
    }
    
    public override var shallowClone: XText {
        let theClone = XText(_value, whitespace: _whitespace)
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        theClone.isolated = isolated
        return theClone
    }
    
    public override var clone: XText {
        return shallowClone
    }
    
    public override func removed() -> XText {
        remove()
        return self
    }
}

/*
 `XLiteral` has a text value that is meant to be serialized "as is" without XML-escaping.
 */
public final class XLiteral: XContent, XTextualContentRepresentation, ToBePeparedForMoving, CustomStringConvertible {
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XLiteral? { super.backlink as? XLiteral }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XLiteral { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XLiteral) -> XLiteral {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XLiteral) -> XLiteral {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XLiteral? { super.finalBacklink as? XLiteral }
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set (newText) {
            _value = newText
            if newText.isEmpty {
                self.remove()
            }
        }
    }
    
    public override var description: String {
        get {
            _value
        }
    }
    
    var _isolated: Bool = false
    var _moving: Bool = false
    
    func prepareForMove() {
        _moving = true
    }
    
    func resetAfterMove() {
        _moving = false
        if !_isolated {
            intendCombiningWithNeighbours()
        }
    }
    
    func intendCombiningWithNeighbours() {
        if let previous = _previous as? XLiteral, !previous.isolated {
            _value = previous._value + _value
            previous.value = ""
        }
        if let next = _next as? XLiteral, !next.isolated {
            _value = _value + next._value
            next.value = ""
        }
    }
    
    public var isolated: Bool {
        get {
            return _moving || _isolated
        }
        set (newIsolatedValue) {
            if _isolated && newIsolatedValue == false {
                intendCombiningWithNeighbours()
            }
            _isolated = newIsolatedValue
        }
    }
    
    public init(_ text: String) {
        self._value = text
    }
    
    public override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeLiteral(literal: self)
    }
    
    public override var shallowClone: XLiteral {
        let theClone = XLiteral(_value)
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        return theClone
    }
    
    public override var clone: XLiteral {
        return shallowClone
    }
    
    public override func removed() -> XLiteral {
        remove()
        return self
    }
}

public final class XInternalEntity: XContent {
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XInternalEntity? { super.backlink as? XInternalEntity }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XInternalEntity { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XInternalEntity) -> XInternalEntity {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XInternalEntity) -> XInternalEntity {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XInternalEntity? { super.finalBacklink as? XInternalEntity }
    
    var _name: String
    
    public var name: String {
        get {
            return _name
        }
        set(newName) {
            _name = newName
        }
    }
    
    public init(_ name: String) {
        self._name = name
    }
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeInternalEntity(internalEntity: self)
    }
    
    public override var shallowClone: XInternalEntity {
        let theClone = XInternalEntity(_name)
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        return theClone
    }
    
    public override var clone: XInternalEntity {
        return shallowClone
    }
    
    public override func removed() -> XInternalEntity {
        remove()
        return self
    }
}

public final class XExternalEntity: XContent {
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XExternalEntity? { super.backlink as? XExternalEntity }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XExternalEntity { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XExternalEntity) -> XExternalEntity {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XExternalEntity) -> XExternalEntity {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XExternalEntity? { super.finalBacklink as? XExternalEntity }
    
    var _name: String
    
    public var name: String {
        get {
            return _name
        }
        set(newName) {
            _name = newName
        }
    }
    
    public init(_ name: String) {
        self._name = name
    }
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeExternalEntity(externalEntity: self)
    }
    
    public override var shallowClone: XExternalEntity {
        let theClone = XExternalEntity(_name)
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        return theClone
    }
    
    public override var clone: XExternalEntity {
        return shallowClone
    }
    
    public override func removed() -> XExternalEntity {
        remove()
        return self
    }
}

public final class XProcessingInstruction: XContent, CustomStringConvertible {
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XProcessingInstruction? { super.backlink as? XProcessingInstruction }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XProcessingInstruction { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XProcessingInstruction) -> XProcessingInstruction {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XProcessingInstruction) -> XProcessingInstruction {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XProcessingInstruction? { super.finalBacklink as? XProcessingInstruction }
    
    var _target: String
    var _data: String?
    
    public override var description: String {
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
    
    public init(target: String, data: String?) {
        self._target = target
        self._data = data
    }
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeProcessingInstruction(processingInstruction: self)
    }
    
    public override var shallowClone: XProcessingInstruction {
        let theClone = XProcessingInstruction(target: _target, data: _data)
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        return theClone
    }
    
    public override var clone: XProcessingInstruction {
        return shallowClone
    }
    
    public override func removed() -> XProcessingInstruction {
        remove()
        return self
    }
}

public final class XComment: XContent {
    
    public static func fromOptional(_ text: String?, withAdditionalSpace: Bool = true) -> XComment? {
        if let text { return XComment(text, withAdditionalSpace: withAdditionalSpace) } else { return nil }
    }
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XComment? { super.backlink as? XComment }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XComment { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XComment) -> XComment {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XComment) -> XComment {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XComment? { super.finalBacklink as? XComment }
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set(newText) {
            _value = newText
        }
    }
    
    public init(_ text: String, withAdditionalSpace: Bool = true) {
        self._value = withAdditionalSpace ? " \(text) " : text
    }
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeComment(comment: self)
    }
    
    public override var shallowClone: XComment {
        let theClone = XComment(_value)
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        return theClone
    }
    
    public override var clone: XComment {
        return shallowClone
    }
    
    public override func removed() -> XComment {
        remove()
        return self
    }
}

public final class XCDATASection: XContent, XTextualContentRepresentation {
    
    /// After cloning, this is the reference to the original node or to the cloned node respectively,
    /// acoording to the parameter used when cloning.
    ///
    /// Note that this is a weak reference, the clone must be contained by other means to exist.
    public override var backlink: XCDATASection? { super.backlink as? XCDATASection }
    
    /// Get the backlink or – if it is `nil` – the subject itself.
    public override var backlinkOrSelf: XCDATASection { self.backlink ?? self }
    
    /// Setting the backlink manually. The identical node is returned.
    public func setting(backlink: XCDATASection) -> XCDATASection {
        _backlink = backlink
        return self
    }
    
    /// Copying the backlink from another node. The identical node is returned.
    public func copyingBacklink(from node: XCDATASection) -> XCDATASection {
        _backlink = node._backlink
        return self
    }
    
    /// Here, the `backlink` reference are followed while they are non-nil.
    ///
    /// It is thhe oldest source or furthest target of cloning respectively, so to speak.
    public override var finalBacklink: XCDATASection? { super.finalBacklink as? XCDATASection }
    
    var _value: String
    
    public var value: String {
        get {
            return _value
        }
        set(newText) {
            _value = newText
        }
    }
    
    public init(_ text: String) {
        self._value = text
    }
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeCDATASection(cdataSection: self)
    }
    
    public override var shallowClone: XCDATASection {
        let theClone = XCDATASection(_value)
        theClone._backlink = self
        theClone._sourceRange = self._sourceRange
        return theClone
    }
    
    public override var clone: XCDATASection {
        return shallowClone
    }
    
    public override func removed() -> XCDATASection {
        remove()
        return self
    }
}

public class XDeclarationInInternalSubset {
    
    var _sourceRange: XTextRange? = nil
    
    public var sourceRange: XTextRange? { _sourceRange }
    
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
    
    func produceEntering(activeProduction: XActiveProduction) throws {}
    
    var clone: XDeclarationInInternalSubset {
        let theClone = XDeclarationInInternalSubset(name: _name)
        theClone._sourceRange = self._sourceRange
        return theClone
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
        set {
            _value = newValue
        }
    }
    
    public init(name: String, value: String) {
        self._value = value
        super.init(name: name)
    }
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeInternalEntityDeclaration(internalEntityDeclaration: self)
    }
    
    public override var clone: XInternalEntityDeclaration {
        let theClone = XInternalEntityDeclaration(name: _name, value: _value)
        theClone._sourceRange = self._sourceRange
        return theClone
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
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeExternalEntityDeclaration(externalEntityDeclaration: self)
    }
    
    public override var clone: XExternalEntityDeclaration {
        let theClone = XExternalEntityDeclaration(name: _name, publicID: _publicID, systemID: _systemID)
        theClone._sourceRange = self._sourceRange
        return theClone
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
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeUnparsedEntityDeclaration(unparsedEntityDeclaration: self)
    }
    
    public override var clone: XUnparsedEntityDeclaration {
        let theClone = XUnparsedEntityDeclaration(name: _name, publicID: _publicID, systemID: _systemID, notationName: _notationName)
        theClone._sourceRange = self._sourceRange
        return theClone
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
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeNotationDeclaration(notationDeclaration: self)
    }
    
    public override var clone: XNotationDeclaration {
        let theClone = XNotationDeclaration(name: _name, publicID: _publicID, systemID: _systemID)
        theClone._sourceRange = self._sourceRange
        return theClone
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
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeElementDeclaration(elementDeclaration: self)
    }
    
    public override var clone: XElementDeclaration {
        let theClone = XElementDeclaration(name: _name, literal: _literal)
        theClone._sourceRange = self._sourceRange
        return theClone
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
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeAttributeListDeclaration(attributeListDeclaration: self)
    }
    
    public override var clone: XAttributeListDeclaration {
        let theClone = XAttributeListDeclaration(name: _name, literal: _literal)
        theClone._sourceRange = self._sourceRange
        return theClone
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
        set {
            _value = newValue
        }
    }
    
    public init(name: String, value: String) {
        self._value = value
        super.init(name: name)
    }
    
    override func produceEntering(activeProduction: XActiveProduction) throws {
        try activeProduction.writeParameterEntityDeclaration(parameterEntityDeclaration: self)
    }
    
    public override var clone: XParameterEntityDeclaration {
        let theClone = XParameterEntityDeclaration(name: _name, value: _value)
        theClone._sourceRange = self._sourceRange
        return theClone
    }
}
