//
//  Production.swift
//  
//  Created 2021 by Stefan Springer, https://stefanspringer.com
//  License: Apache License 2.0

import Foundation
import SwiftXMLInterfaces

func sortByName(_ declarations: [String:XMLDeclarationInInternalSubset]) -> [XMLDeclarationInInternalSubset] {
    var sorted = [XMLDeclarationInInternalSubset]()
    declarations.keys.sorted().forEach { name in
        if let theDeclaration = declarations[name] {
            sorted.append(theDeclaration)
        }
    }
    return sorted
}

public protocol XMLProduction: SwiftXMLInterfaces.DefaultXMLProduction {
    func sortedDeclarationsInInternalSubset(document: XMLDocument) -> [XMLDeclarationInInternalSubset]
}

open class DefaultXMLProduction: SwiftXMLInterfaces.DefaultXMLProduction, XMLProduction {
    
    required public init(file: FileHandle) {
        super.init(file: file)
    }
    
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
