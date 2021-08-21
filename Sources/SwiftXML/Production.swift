//
//  File.swift
//  
//
//  Created by Stefan Springer on 20.08.21.
//

import Foundation
import SwiftXMLInterfaces

public protocol XMLFormatter: SwiftXMLInterfaces.XMLFormatter {
    
    func sortedDeclarationsInInternalSubset(document: XMLDocument) -> [XMLDeclarationInInternalSubset]
}

func sortByName(_ declarations: [String:XMLDeclarationInInternalSubset]) -> [XMLDeclarationInInternalSubset] {
    var sorted = [XMLDeclarationInInternalSubset]()
    declarations.keys.sorted().forEach { name in
        if let theDeclaration = declarations[name] {
            sorted.append(theDeclaration)
        }
    }
    return sorted
}

open class DefaultXMLFormatter: SwiftXMLInterfaces.DefaultXMLFormatter, XMLFormatter {
    
    open func sortedDeclarationsInInternalSubset(document: XMLDocument) -> [XMLDeclarationInInternalSubset] {
        var sorted = [XMLDeclarationInInternalSubset]()
        ([
            sortByName(document.internalEntityDeclarations),
            sortByName(document.externalEntityDeclarations),
            sortByName(document.notationDeclarations),
            sortByName(document.unparsedEntityDeclarations),
            sortByName(document.elementDeclarations),
            sortByName(document.attributeListDeclarations),
            sortByName(document.parameterEntityDeclarations)
        ]).forEach { declarations in
            declarations.forEach { declaration in
                sorted.append(declaration)
            }
        }
        return sorted
    }
}

public protocol XMLProduction: SwiftXMLInterfaces.XMLProduction {
    func set(formatter: XMLFormatter)
    func getFormatter() -> XMLFormatter
}

open class DefaultXMLProduction: SwiftXMLInterfaces.DefaultXMLProduction, XMLProduction {
 
    private var swiftXMLFormatter: XMLFormatter
    
    public func getFormatter() -> XMLFormatter {
        return swiftXMLFormatter
    }
    
    public func set(formatter: XMLFormatter) {
        super.set(formatter: formatter)
        swiftXMLFormatter = formatter
    }
    
    public init(file: FileHandle? = nil, formatter: XMLFormatter? = nil) {
        self.swiftXMLFormatter = formatter ?? DefaultXMLFormatter()
        super.init(file: file, formatter: formatter)
    }
}
