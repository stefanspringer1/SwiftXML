//
//  Nodes.swift
//
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation

protocol Named: AnyObject {
    associatedtype WithName
    var previousWithSameName: WithName? { get set }
    var nextWithSameName: WithName? { get set }
}

class OfEqualName<T: Named> where T.WithName == T {
    
    var name: String
    var first: T? = nil
    var last: T? = nil
    
    init(name: String) {
        self.name = name
    }
    
    func isEmpty() -> Bool {
        return first == nil
    }
    
    func add(named: T) {
        if let theLastElement = last {
            theLastElement.nextWithSameName = named
            named.previousWithSameName = theLastElement
        }
        else {
            first = named
        }
        last = named
    }
    
    func remove(named: T) {
        if first === named {
            first = named.nextWithSameName
        }
        else {
            if let thePrevious = named.previousWithSameName {
                thePrevious.nextWithSameName = named.nextWithSameName
            }
            if let theNext = named.nextWithSameName {
                theNext.previousWithSameName = named.previousWithSameName
            }
        }
        named.previousWithSameName = nil
        named.nextWithSameName = nil
    }
}

public class XMLNode {
    weak var parent: XMLElement? = nil
    
    weak var previous: XMLNode? = nil
    var next: XMLNode? = nil
    
    func traverse(down: @escaping (XMLNode) -> (), up: ((XMLBranch) -> ())? = nil) {
        var iterator = XMLTreeIterator(startNode: self) { node in
            down(node)
        } up: { branch in
            up?(branch)
        }
        while iterator.next() != nil {}
    }
    
    func produceEntering(production: XMLProduction) {
        // to be implemented by subclass
    }
    
    public func applyProduction(production: XMLProduction) {
        traverse { node in
            node.produceEntering(production: production)
        } up: { branch in
            branch.produceLeaving(production: production)
        }
    }
    
    public func write(toPath path: String, productionType: XMLProduction.Type = DefaultXMLProduction.self) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            fileManager.createFile(atPath: path,  contents:Data("".utf8), attributes: nil)
        }
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            let production = productionType.init(file: fileHandle)
            self.applyProduction(production: production)
            fileHandle.closeFile()
        }
        else {
            print("ERROR: cannot write to [\(path)]");
        }
    }
    
    public func write(production: XMLProduction) {
        self.applyProduction(production: production)
    }
    
    public func write(toFile file: FileHandle, productionType: XMLProduction.Type = DefaultXMLProduction.self) {
        let production = productionType.init(file: file)
        self.applyProduction(production: production)
    }
    
    public func write(productionType: XMLProduction.Type = DefaultXMLProduction.self) {
        write(toFile: FileHandle.standardOutput, productionType: productionType)
    }
}

public class XMLBranch: XMLNode {
    
    var firstChild: XMLNode? = nil
    var lastChild: XMLNode? = nil
    
    func add(_ node: XMLNode) {
        
        // remove from old chain:
        if let thePrevious = node.previous {
            thePrevious.next = node.next
        }
        if let theNext = node.next {
            theNext.previous = node.previous
        }
        if let theParent = node.parent {
            if theParent.firstChild === node {
                theParent.firstChild = node.next
            }
            if theParent.lastChild === self {
                theParent.lastChild = node.previous
            }
        }
        
        // insert into new chain:
        if let theLastChild = lastChild {
            theLastChild.next = node
            node.previous = theLastChild
        }
        else {
            firstChild = node
            node.previous = nil
        }
        lastChild = node
        node.next = nil
        
        // set parent:
        if let element = self as? XMLElement {
            node.parent = element
        }
        
        // set document:
        if let element = node as? XMLElement {
            element.setDocument(document: (self as? XMLElement)?.document ?? self as? XMLDocument)
        }
    }
    
    func produceLeaving(production: XMLProduction) {
        // to be implemented by subclass
    }
}

public class XMLAttribute: XMLNode, Named {
    
    var name: String
    var value: String
    var element: XMLElement?
    
    weak var previousWithSameName: XMLAttribute? = nil
    var nextWithSameName: XMLAttribute? = nil
    
    init(name: String, value: String, element: XMLElement? = nil) {
        self.name = name
        self.value = value
        self.element = element
    }
}

public class XMLElement: XMLBranch, Named {
    
    var document: XMLDocument? = nil
    var name: String
    var attributes: [String:XMLAttribute]? = nil
    
    weak var previousWithSameName: XMLElement? = nil
    var nextWithSameName: XMLElement? = nil
    
    init(name: String, document: XMLDocument? = nil) {
        self.name = name
        self.document = document
    }

    func setAttributes(attributes newAtttributeValues: [String:String]? = nil) {
        if self.attributes == nil {
            self.attributes = [String:XMLAttribute]()
        }
        newAtttributeValues?.forEach { name, value in
            if let existing = self.attributes?[name] {
                existing.value = value
            }
            else {
                let newAttribute = XMLAttribute(name: name, value: value, element: self)
                self.attributes?[name] = newAttribute
                document?.registerAttribute(attribute: newAttribute)
            }
        }
    }
    
    func rename(newName: String) {
        let elementToRename = self;
        document?.unregisterElement(element: elementToRename)
        self.name = newName
        document?.registerElement(element: elementToRename)
    }
    
    func setDocument(document newDocument: XMLDocument?) {
        if !(newDocument === document) {
            var node: XMLNode = self
            repeat {
                if let element = node as? XMLElement {
                    element.document?.unregisterElement(element: element)
                    element.document = newDocument
                    newDocument?.registerElement(element: element)
                }
                if let element = node as? XMLElement, let child = element.firstChild {
                    node = child
                }
                else if !(node === self) {
                    if let next = node.next {
                        node = next
                    }
                    else if let parent = node.parent {
                        node = parent
                    }
                }
                
            } while !(node === self)
        }
    }
    
    override func produceEntering(production: XMLProduction) {
        production.elementStartBeforeAttributes(name: name, hasAttributes: !(attributes?.isEmpty ?? true), isEmpty: firstChild == nil)
        if let theAttributes = attributes {
            production.sortedAttributeNames(attributeNames: Array(theAttributes.keys)).forEach { attributeName in
                if let theAttribute = theAttributes[attributeName] {
                    production.attribute(name: theAttribute.name, value: theAttribute.value)
                }
            }
        }
        production.elementStartAfterAttributes(name: name, hasAttributes: !(attributes?.isEmpty ?? true), isEmpty: firstChild == nil)
    }
    
    override func produceLeaving(production: XMLProduction) {
        production.elementEnd(name: name, hasAttributes: !(attributes?.isEmpty ?? true), isEmpty: firstChild == nil)
    }
}

public class XMLText: XMLNode {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    public override func produceEntering(production: XMLProduction) {
        production.text(text: text)
    }
}

public class XMLInternalEntity: XMLNode {
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    override func produceEntering(production: XMLProduction) {
        production.internalEntity(name: name)
    }
}

public class XMLExternalEntity: XMLNode {
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    override func produceEntering(production: XMLProduction) {
        production.externalEntity(name: name)
    }
}

public class XMLProcessingInstruction: XMLNode {
    var target: String
    var content: String?
    
    init(target: String, content: String?) {
        self.target = target
        self.content = content
    }
    
    override func produceEntering(production: XMLProduction) {
        production.processingInstruction(target: target, content: content)
    }
}

public class XMLComment: XMLNode {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    override func produceEntering(production: XMLProduction) {
        production.comment(text: text)
    }
}

public class XMLCDATASection: XMLNode {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    override func produceEntering(production: XMLProduction) {
        production.cdataSection(text: text)
    }
}

public class XMLDeclarationInInternalSubset {
    var name: String = ""
    
    public init(name: String) {
        self.name = name
    }
    
    func produceEntering(production: XMLProduction) {}
}

/**
 internal entity declaration
 */
public class XMLInternalEntityDeclaration: XMLDeclarationInInternalSubset {
    var value: String
    
    public init(name: String, value: String) {
        self.value = value
        super.init(name: name)
    }
    
    override func produceEntering(production: XMLProduction) {
        production.internalEntityDeclaration(name: name, value: value)
    }
}

/**
 parsed external entity declaration
 */
public class XMLExternalEntityDeclaration: XMLDeclarationInInternalSubset {
    var publicID: String?
    var systemID: String
    
    public init(name: String, publicID: String?, systemID: String) {
        self.publicID = publicID
        self.systemID = systemID
        super.init(name: name)
    }
    
    override func produceEntering(production: XMLProduction) {
        production.externalEntityDeclaration(name: name, publicID: publicID, systemID: systemID)
    }
}

/**
 unparsed external entity declaration
 */
public class XMLUnparsedEntityDeclaration: XMLDeclarationInInternalSubset {
    var publicID: String?
    var systemID: String
    var notationName: String
    
    public init(name: String, publicID: String?, systemID: String, notationName: String) {
        self.publicID = publicID
        self.systemID = systemID
        self.notationName = notationName
        super.init(name: name)
    }
    
    override func produceEntering(production: XMLProduction) {
        production.unparsedEntityDeclaration(name: name, publicID: publicID, systemID: systemID, notation: notationName)
    }
}

/**
 notation declaration
 */
public class XMLNotationDeclaration: XMLDeclarationInInternalSubset {
    var publicID: String?
    var systemID: String?
    
    public init(name: String, publicID: String?, systemID: String?) {
        self.publicID = publicID
        self.systemID = systemID
        super.init(name: name)
    }
    
    override func produceEntering(production: XMLProduction) {
        production.notationDeclaration(name: name, publicID: publicID, systemID: systemID)
    }
}

/**
 element declaration
 */
public class XMLElementDeclaration: XMLDeclarationInInternalSubset {
    var text: String
    
    public init(name: String, text: String) {
        self.text = text
        super.init(name: name)
    }
    
    override func produceEntering(production: XMLProduction) {
        production.elementDeclaration(name: name, text: text)
    }
}

/**
 attribute list declaration
 */
public class XMLAttributeListDeclaration: XMLDeclarationInInternalSubset {
    var text: String
    
    public init(name: String, text: String) {
        self.text = text
        super.init(name: name)
    }
    
    override func produceEntering(production: XMLProduction) {
        production.attributeListDeclaration(name: name, text: text)
    }
}

/**
 parameter entity declaration
 */
public class XMLParameterEntityDeclaration: XMLDeclarationInInternalSubset {
    var value: String
    
    public init(name: String, value: String) {
        self.value = value
        super.init(name: name)
    }
    
    override func produceEntering(production: XMLProduction) {
        production.parameterEntityDeclaration(name: name, value: value)
    }
}
