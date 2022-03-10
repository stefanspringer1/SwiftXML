//
//  File.swift
//  
//
//  Created by Stefan Springer on 27.09.21.
//

import Foundation

extension XNode {
    
    public var ancestors: XElementSequence {
        get {
            return XAncestorsSequence(node: self)
        }
    }
    
    public var content: XNodeSequence {
        get {
            return XContentSequence(node: self)
        }
    }
    
    public var children: XElementSequence {
        get {
            return XChildrenSequence(node: self)
        }
    }
    
    public var next: XNodeSequence {
        get {
            return XNextSequence(node: self)
        }
    }
    
    public var previous: XNodeSequence {
        get {
            return XPreviousSequence(node: self)
        }
    }
    
    public var nextElements: XElementSequence {
        get {
            return XNextElementsSequence(node: self)
        }
    }
    
    public var previousElements: XElementSequence {
        get {
            return XPreviousElementsSequence(node: self)
        }
    }
    
    public var allContent: XNodeSequence {
        get {
            return XAllContentSequence(node: self)
        }
    }
    public var allContentIncludingSelf: XNodeSequence {
        get {
            return XAllContentIncludingSelfSequence(node: self)
        }
    }
    
    public var descendants: XElementSequence {
        get {
            return XDescendantsSequence(node: self)
        }
    }
}

extension XElement {
    
    public var descendantsIncludingSelf: XElementSequence {
        get {
            return XDescendantsIncludingSelfSequence(element: self)
        }
    }
    
}
